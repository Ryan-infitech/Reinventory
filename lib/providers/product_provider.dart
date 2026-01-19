import 'package:flutter/material.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  
  List<ProductModel> _products = [];
  List<ProductModel> _lowStockProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<ProductModel> get lowStockProducts => _lowStockProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load products
  void loadProducts(String userId) {
    _productService.getProductsStream(userId).listen((products) {
      _products = products;
      notifyListeners();
    });
  }

  // Load low stock products
  void loadLowStockProducts(String userId) {
    _productService.getLowStockProducts(userId).listen((products) {
      _lowStockProducts = products;
      
      // Check for new low stock items and create alerts
      for (var product in products) {
        if (product.isLowStock) {
          _notificationService.createStockAlert(
            productId: product.id,
            productName: product.name,
            currentStock: product.stock,
            minStock: product.minStock,
            userId: userId,
          );
        }
      }
      
      notifyListeners();
    });
  }

  // Add product
  Future<bool> addProduct({
    required ProductModel product,
    XFile? imageFile,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String productId = const Uuid().v4();
      String? imageUrl;
      String? localImagePath;

      // Upload image if provided
      if (imageFile != null) {
        // Save locally first
        localImagePath = await _storageService.saveImageLocally(imageFile, productId);
        
        // Then upload to Firebase Storage
        try {
          imageUrl = await _storageService.uploadProductImage(
            File(imageFile.path),
            productId,
          );
        } catch (e) {
          // If upload fails, continue with local image only
          debugPrint('Failed to upload image to Firebase: $e');
        }
      }

      ProductModel newProduct = product.copyWith(
        id: productId,
        imageUrl: imageUrl,
        localImagePath: localImagePath,
        userId: userId,
        createdAt: DateTime.now(),
      );

      await _productService.addProduct(newProduct);
      
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

  // Update product
  Future<bool> updateProduct({
    required ProductModel product,
    XFile? imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl = product.imageUrl;
      String? localImagePath = product.localImagePath;

      // Upload new image if provided
      if (imageFile != null) {
        // Delete old images only if we have new image
        if (product.imageUrl != null) {
          try {
            await _storageService.deleteImage(product.imageUrl!);
          } catch (e) {
            debugPrint('Failed to delete old image: $e');
          }
        }
        if (product.localImagePath != null) {
          try {
            await _storageService.deleteLocalImage(product.localImagePath!);
          } catch (e) {
            debugPrint('Failed to delete old local image: $e');
          }
        }

        // Save new image
        localImagePath = await _storageService.saveImageLocally(imageFile, product.id);
        
        try {
          imageUrl = await _storageService.uploadProductImage(
            File(imageFile.path),
            product.id,
          );
        } catch (e) {
          debugPrint('Failed to upload image to Firebase: $e');
        }
      }
      // If no new image, keep the existing ones

      ProductModel updatedProduct = product.copyWith(
        imageUrl: imageUrl,
        localImagePath: localImagePath,
        updatedAt: DateTime.now(),
      );

      await _productService.updateProduct(updatedProduct);
      
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

  // Delete product
  Future<bool> deleteProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete images
      if (product.imageUrl != null) {
        try {
          await _storageService.deleteImage(product.imageUrl!);
        } catch (e) {
          debugPrint('Failed to delete image: $e');
        }
      }
      if (product.localImagePath != null) {
        try {
          await _storageService.deleteLocalImage(product.localImagePath!);
        } catch (e) {
          debugPrint('Failed to delete local image: $e');
        }
      }

      await _productService.deleteProduct(product.id);
      
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

  // Update stock
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      await _productService.updateStock(productId, newStock);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String userId, String query) async {
    try {
      return await _productService.searchProducts(userId, query);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get product by barcode
  Future<ProductModel?> getProductByBarcode(String userId, String barcode) async {
    try {
      return await _productService.getProductByBarcode(userId, barcode);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
