import 'package:cloud_firestore/cloud_firestore.dart';

class StockAlertModel {
  final String id;
  final String productId;
  final String productName;
  final int currentStock;
  final int minStock;
  final bool isRead;
  final String userId;
  final DateTime createdAt;

  StockAlertModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    this.isRead = false,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'currentStock': currentStock,
      'minStock': minStock,
      'isRead': isRead,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StockAlertModel.fromMap(Map<String, dynamic> map) {
    return StockAlertModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      currentStock: map['currentStock'] ?? 0,
      minStock: map['minStock'] ?? 0,
      isRead: map['isRead'] ?? false,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  StockAlertModel copyWith({
    String? id,
    String? productId,
    String? productName,
    int? currentStock,
    int? minStock,
    bool? isRead,
    String? userId,
    DateTime? createdAt,
  }) {
    return StockAlertModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
