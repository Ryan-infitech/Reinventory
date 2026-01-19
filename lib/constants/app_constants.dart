import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  
  static const Color border = Color(0xFFE5E7EB);
}

class AppConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String suppliersCollection = 'suppliers';
  static const String transactionsCollection = 'transactions';
  static const String stockAlertsCollection = 'stock_alerts';
  
  // Storage paths
  static const String productImagesPath = 'product_images';
  
  // Product categories
  static const List<String> productCategories = [
    'Makanan',
    'Minuman',
    'Elektronik',
    'Pakaian',
    'Kesehatan',
    'Kecantikan',
    'Rumah Tangga',
    'Olahraga',
    'Lainnya',
  ];
  
  // Product units
  static const List<String> productUnits = [
    'pcs',
    'box',
    'kg',
    'gram',
    'liter',
    'ml',
    'meter',
    'lusin',
  ];
  
  // Transaction types
  static const String transactionTypeSale = 'sale';
  static const String transactionTypePurchase = 'purchase';
  static const String transactionTypeAdjustment = 'adjustment';
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MMMM yyyy';
}
