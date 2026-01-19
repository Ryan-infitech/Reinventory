import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier_model.dart';
import '../constants/app_constants.dart';

class SupplierService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get suppliers stream
  Stream<List<SupplierModel>> getSuppliersStream(String userId) {
    return _firestore
        .collection(AppConstants.suppliersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupplierModel.fromMap(doc.data()))
            .toList());
  }

  // Get single supplier
  Future<SupplierModel?> getSupplier(String supplierId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.suppliersCollection)
          .doc(supplierId)
          .get();
      
      if (doc.exists) {
        return SupplierModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get supplier: ${e.toString()}');
    }
  }

  // Add supplier
  Future<void> addSupplier(SupplierModel supplier) async {
    try {
      await _firestore
          .collection(AppConstants.suppliersCollection)
          .doc(supplier.id)
          .set(supplier.toMap());
    } catch (e) {
      throw Exception('Failed to add supplier: ${e.toString()}');
    }
  }

  // Update supplier
  Future<void> updateSupplier(SupplierModel supplier) async {
    try {
      await _firestore
          .collection(AppConstants.suppliersCollection)
          .doc(supplier.id)
          .update(supplier.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw Exception('Failed to update supplier: ${e.toString()}');
    }
  }

  // Delete supplier
  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _firestore
          .collection(AppConstants.suppliersCollection)
          .doc(supplierId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete supplier: ${e.toString()}');
    }
  }

  // Search suppliers
  Future<List<SupplierModel>> searchSuppliers(String userId, String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.suppliersCollection)
          .where('userId', isEqualTo: userId)
          .get();

      List<SupplierModel> suppliers = snapshot.docs
          .map((doc) => SupplierModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return suppliers.where((supplier) {
        return supplier.name.toLowerCase().contains(query.toLowerCase()) ||
            (supplier.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            supplier.phoneNumber.contains(query);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search suppliers: ${e.toString()}');
    }
  }
}
