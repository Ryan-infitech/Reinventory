import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_alert_model.dart';
import '../constants/app_constants.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize notifications
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  // Request permissions (for iOS)
  Future<bool> requestPermissions() async {
    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? false;
  }

  // Show notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'reinventory_channel',
      'Reinventory Notifications',
      channelDescription: 'Notifications for Reinventory app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  // Show low stock notification
  Future<void> showLowStockNotification(String productName, int currentStock) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Stok Menipis!',
      body: '$productName hanya tersisa $currentStock unit',
    );
  }

  // Create stock alert in Firestore
  Future<void> createStockAlert({
    required String productId,
    required String productName,
    required int currentStock,
    required int minStock,
    required String userId,
  }) async {
    try {
      String alertId = _firestore.collection(AppConstants.stockAlertsCollection).doc().id;
      
      StockAlertModel alert = StockAlertModel(
        id: alertId,
        productId: productId,
        productName: productName,
        currentStock: currentStock,
        minStock: minStock,
        userId: userId,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.stockAlertsCollection)
          .doc(alertId)
          .set(alert.toMap());

      // Show notification
      await showLowStockNotification(productName, currentStock);
    } catch (e) {
      throw Exception('Failed to create stock alert: ${e.toString()}');
    }
  }

  // Get stock alerts stream
  Stream<List<StockAlertModel>> getStockAlertsStream(String userId) {
    return _firestore
        .collection(AppConstants.stockAlertsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StockAlertModel.fromMap(doc.data()))
            .toList());
  }

  // Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await _firestore
          .collection(AppConstants.stockAlertsCollection)
          .doc(alertId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark alert as read: ${e.toString()}');
    }
  }

  // Delete old alerts
  Future<void> deleteOldAlerts(String userId, int daysOld) async {
    try {
      DateTime cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.stockAlertsCollection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete old alerts: ${e.toString()}');
    }
  }
}
