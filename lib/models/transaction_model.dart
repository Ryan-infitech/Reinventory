import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String productId;
  final String productName;
  final String type; // sale, purchase, adjustment
  final int quantity;
  final double price;
  final double total;
  final String? customerName;
  final String? notes;
  final String userId;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.price,
    required this.total,
    this.customerName,
    this.notes,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type,
      'quantity': quantity,
      'price': price,
      'total': total,
      'customerName': customerName,
      'notes': notes,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      type: map['type'] ?? 'sale',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      customerName: map['customerName'],
      notes: map['notes'],
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
