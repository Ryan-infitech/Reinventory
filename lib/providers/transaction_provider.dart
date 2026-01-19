import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/product_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load transactions for a user
  void loadTransactions(String userId) {
    _transactionService.getTransactionsStream(userId).listen((transactions) {
      _transactions = transactions;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });
  }

  // Add new transaction
  Future<bool> addTransaction({
    required TransactionModel transaction,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current product
      final product = await _productService.getProductById(transaction.productId);
      
      if (product == null) {
        throw Exception('Produk tidak ditemukan');
      }

      // Calculate new stock
      int newStock = product.stock;
      if (transaction.type == 'sale') {
        newStock -= transaction.quantity;
        if (newStock < 0) {
          throw Exception('Stok tidak mencukupi');
        }
      } else if (transaction.type == 'purchase') {
        newStock += transaction.quantity;
      }

      // Update product stock
      await _productService.updateProduct(
        product.copyWith(
          stock: newStock,
          updatedAt: DateTime.now(),
        ),
      );

      // Add transaction
      await _transactionService.addTransaction(transaction);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete transaction (for corrections)
  Future<bool> deleteTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current product
      final product = await _productService.getProductById(transaction.productId);
      
      if (product == null) {
        throw Exception('Produk tidak ditemukan');
      }

      // Reverse stock change
      int newStock = product.stock;
      if (transaction.type == 'sale') {
        newStock += transaction.quantity; // Add back
      } else if (transaction.type == 'purchase') {
        newStock -= transaction.quantity; // Remove
      }

      // Update product stock
      await _productService.updateProduct(
        product.copyWith(
          stock: newStock,
          updatedAt: DateTime.now(),
        ),
      );

      // Delete transaction
      await _transactionService.deleteTransaction(transaction.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _transactionService.getTransactionsByDateRange(
      userId,
      startDate,
      endDate,
    );
  }

  // Get sales summary
  Future<Map<String, dynamic>> getSalesSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await getTransactionsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    double totalSales = 0;
    double totalPurchases = 0;
    int totalItems = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'sale') {
        totalSales += transaction.total;
      } else if (transaction.type == 'purchase') {
        totalPurchases += transaction.total;
      }
      totalItems += transaction.quantity;
    }

    return {
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'totalItems': totalItems,
      'profit': totalSales - totalPurchases,
      'transactionCount': transactions.length,
    };
  }

  // Get daily sales for chart
  Future<Map<DateTime, double>> getDailySales({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await getTransactionsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    Map<DateTime, double> dailySales = {};

    for (var transaction in transactions) {
      if (transaction.type == 'sale') {
        final date = DateTime(
          transaction.createdAt.year,
          transaction.createdAt.month,
          transaction.createdAt.day,
        );
        dailySales[date] = (dailySales[date] ?? 0) + transaction.total;
      }
    }

    return dailySales;
  }
}
