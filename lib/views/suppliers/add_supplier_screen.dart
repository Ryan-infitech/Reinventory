import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/supplier_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../constants/app_constants.dart';

class AddSupplierScreen extends StatefulWidget {
  final SupplierModel? supplier; // For edit mode

  const AddSupplierScreen({super.key, this.supplier});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  
  bool _isLoading = false;
  bool get isEditMode => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    
    if (isEditMode) {
      final supplier = widget.supplier!;
      _nameController = TextEditingController(text: supplier.name);
      _phoneController = TextEditingController(text: supplier.phoneNumber);
      _emailController = TextEditingController(text: supplier.email ?? '');
      _addressController = TextEditingController(text: supplier.address ?? '');
      _descriptionController = TextEditingController(text: supplier.description ?? '');
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
      _addressController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan')),
      );
      return;
    }

    try {
      final supplier = SupplierModel(
        id: isEditMode ? widget.supplier!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        userId: authProvider.currentUser!.id,
        createdAt: isEditMode ? widget.supplier!.createdAt : DateTime.now(),
        updatedAt: isEditMode ? DateTime.now() : null,
      );

      bool success;
      if (isEditMode) {
        success = await supplierProvider.updateSupplier(supplier);
      } else {
        success = await supplierProvider.addSupplier(supplier);
      }

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Supplier berhasil diupdate' : 'Supplier berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(supplierProvider.errorMessage ?? 'Gagal menyimpan supplier'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Supplier' : 'Tambah Supplier'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nama Supplier
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Supplier *',
                hintText: 'Masukkan nama supplier',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama supplier harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Nomor Telepon
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon *',
                hintText: 'Masukkan nomor telepon',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Masukkan email (opsional)',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('@')) {
                    return 'Format email tidak valid';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Alamat
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Alamat',
                hintText: 'Masukkan alamat (opsional)',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Masukkan deskripsi (opsional)',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSupplier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditMode ? 'Update Supplier' : 'Simpan Supplier',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
