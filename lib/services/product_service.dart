import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../constants/app_constants.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get products stream for real-time updates
  Stream<List<ProductModel>> getProductsStream(String userId) {
    return _firestore
        .collection(AppConstants.productsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }

  // Get single product
  Future<ProductModel?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();
      
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  // Alias for getProduct
  Future<ProductModel?> getProductById(String productId) async {
    return getProduct(productId);
  }

  // Add product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .set(product.toMap());
    } catch (e) {
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(product.id)
          .update(product.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  // Update stock
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
        'stock': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update stock: ${e.toString()}');
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String userId, String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      List<ProductModel> products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by query
      return products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            (product.barcode?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (product.sku?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  // Get low stock products
  Stream<List<ProductModel>> getLowStockProducts(String userId) {
    return _firestore
        .collection(AppConstants.productsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<ProductModel> products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
      
      return products.where((product) => product.isLowStock).toList();
    });
  }

  // Get product by barcode
  Future<ProductModel?> getProductByBarcode(String userId, String barcode) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('userId', isEqualTo: userId)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ProductModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product by barcode: ${e.toString()}');
    }
  }

  // Get products by category
  Stream<List<ProductModel>> getProductsByCategory(String userId, String category) {
    return _firestore
        .collection(AppConstants.productsCollection)
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }
}
