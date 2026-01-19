import 'package:flutter/material.dart';
import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class SupplierProvider with ChangeNotifier {
  final SupplierService _supplierService = SupplierService();
  
  List<SupplierModel> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SupplierModel> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load suppliers
  void loadSuppliers(String userId) {
    _supplierService.getSuppliersStream(userId).listen(
      (suppliers) {
        _suppliers = suppliers;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Add supplier
  Future<bool> addSupplier(SupplierModel supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.addSupplier(supplier);
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

  // Update supplier
  Future<bool> updateSupplier(SupplierModel supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.updateSupplier(supplier);
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

  // Delete supplier
  Future<bool> deleteSupplier(SupplierModel supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.deleteSupplier(supplier.id);
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

  // Search suppliers
  List<SupplierModel> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;
    
    return _suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(query.toLowerCase()) ||
             supplier.phoneNumber.toLowerCase().contains(query.toLowerCase()) ||
             (supplier.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}
