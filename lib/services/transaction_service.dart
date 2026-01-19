import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../constants/app_constants.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get transactions stream
  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _firestore
        .collection(AppConstants.transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data()))
            .toList());
  }

  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transaction.id)
          .set(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to add transaction: ${e.toString()}');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: ${e.toString()}');
    }
  }

  // Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions: ${e.toString()}');
    }
  }

  // Get transactions by type
  Stream<List<TransactionModel>> getTransactionsByType(
    String userId,
    String type,
  ) {
    return _firestore
        .collection(AppConstants.transactionsCollection)
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data()))
            .toList());
  }

  // Get daily sales
  Future<double> getDailySales(String userId, DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: AppConstants.transactionTypeSale)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        TransactionModel transaction = TransactionModel.fromMap(doc.data() as Map<String, dynamic>);
        total += transaction.total;
      }
      
      return total;
    } catch (e) {
      throw Exception('Failed to get daily sales: ${e.toString()}');
    }
  }

  // Get monthly sales
  Future<double> getMonthlySales(String userId, int year, int month) async {
    try {
      DateTime startOfMonth = DateTime(year, month, 1);
      DateTime endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: AppConstants.transactionTypeSale)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        TransactionModel transaction = TransactionModel.fromMap(doc.data() as Map<String, dynamic>);
        total += transaction.total;
      }
      
      return total;
    } catch (e) {
      throw Exception('Failed to get monthly sales: ${e.toString()}');
    }
  }

  // Get transactions by product
  Future<List<TransactionModel>> getTransactionsByProduct(
    String userId,
    String productId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get product transactions: ${e.toString()}');
    }
  }
}
