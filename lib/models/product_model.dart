import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String? barcode;
  final String? sku;
  final String? description;
  final String category;
  final double buyingPrice;
  final double sellingPrice;
  final int stock;
  final int minStock;
  final String unit; // pcs, kg, liter, etc
  final String? imageUrl;
  final String? localImagePath;
  final String? supplierId;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.barcode,
    this.sku,
    this.description,
    required this.category,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.stock,
    this.minStock = 5,
    this.unit = 'pcs',
    this.imageUrl,
    this.localImagePath,
    this.supplierId,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  // Check if stock is low
  bool get isLowStock => stock <= minStock;

  // Calculate profit margin
  double get profitMargin => sellingPrice - buyingPrice;
  
  // Calculate profit percentage
  double get profitPercentage => 
      buyingPrice > 0 ? ((sellingPrice - buyingPrice) / buyingPrice) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'sku': sku,
      'description': description,
      'category': category,
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'stock': stock,
      'minStock': minStock,
      'unit': unit,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'supplierId': supplierId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      barcode: map['barcode'],
      sku: map['sku'],
      description: map['description'],
      category: map['category'] ?? '',
      buyingPrice: (map['buyingPrice'] ?? 0).toDouble(),
      sellingPrice: (map['sellingPrice'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      minStock: map['minStock'] ?? 5,
      unit: map['unit'] ?? 'pcs',
      imageUrl: map['imageUrl'],
      localImagePath: map['localImagePath'],
      supplierId: map['supplierId'],
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? barcode,
    String? sku,
    String? description,
    String? category,
    double? buyingPrice,
    double? sellingPrice,
    int? stock,
    int? minStock,
    String? unit,
    String? imageUrl,
    String? localImagePath,
    String? supplierId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      category: category ?? this.category,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      supplierId: supplierId ?? this.supplierId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
