import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../constants/app_constants.dart';
import '../../services/storage_service.dart';
import '../../widgets/barcode_scanner_screen.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product; // For edit mode

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _skuController;
  late TextEditingController _descriptionController;
  late TextEditingController _buyingPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  
  String _selectedCategory = AppConstants.productCategories[0];
  String _selectedUnit = AppConstants.productUnits[0];
  XFile? _imageFile;
  String? _existingImagePath;
  
  bool _isLoading = false;
  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    
    if (isEditMode) {
      final product = widget.product!;
      _nameController = TextEditingController(text: product.name);
      _barcodeController = TextEditingController(text: product.barcode ?? '');
      _skuController = TextEditingController(text: product.sku ?? '');
      _descriptionController = TextEditingController(text: product.description ?? '');
      _buyingPriceController = TextEditingController(text: product.buyingPrice.toString());
      _sellingPriceController = TextEditingController(text: product.sellingPrice.toString());
      _stockController = TextEditingController(text: product.stock.toString());
      _minStockController = TextEditingController(text: product.minStock.toString());
      _selectedCategory = product.category;
      _selectedUnit = product.unit;
      _existingImagePath = product.localImagePath;
    } else {
      _nameController = TextEditingController();
      _barcodeController = TextEditingController();
      _skuController = TextEditingController();
      _descriptionController = TextEditingController();
      _buyingPriceController = TextEditingController();
      _sellingPriceController = TextEditingController();
      _stockController = TextEditingController();
      _minStockController = TextEditingController(text: '5');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? image;
      if (source == ImageSource.camera) {
        image = await _storageService.pickImageFromCamera();
      } else {
        image = await _storageService.pickImageFromGallery();
      }
      
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    // Show options: Scan with camera or upload photo
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan dengan Kamera'),
              subtitle: const Text('Scan barcode secara langsung'),
              onTap: () async {
                final scannedCode = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerScreen(),
                  ),
                );
                if (scannedCode != null && context.mounted) {
                  Navigator.pop(context, scannedCode);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Upload Foto Barcode'),
              subtitle: const Text('Pilih foto barcode dari galeri'),
              onTap: () async {
                final scannedCode = await _scanBarcodeFromImage();
                if (scannedCode != null && context.mounted) {
                  Navigator.pop(context, scannedCode);
                } else if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  Future<String?> _scanBarcodeFromImage() async {
    try {
      // Pick image from gallery
      final XFile? image = await _storageService.pickImageFromGallery();
      
      if (image == null) return null;

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memindai barcode...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Scan barcode from image using mobile_scanner
      final MobileScannerController controller = MobileScannerController();
      
      // Analyze image
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      controller.dispose();

      if (capture != null && capture.barcodes.isNotEmpty) {
        final barcode = capture.barcodes.first;
        if (barcode.rawValue != null) {
          return barcode.rawValue;
        }
      }

      // No barcode found
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat mendeteksi barcode dari foto'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      
      return null;
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan')),
      );
      return;
    }

    try {
      final product = ProductModel(
        id: isEditMode ? widget.product!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        category: _selectedCategory,
        buyingPrice: double.parse(_buyingPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        stock: int.parse(_stockController.text),
        minStock: int.parse(_minStockController.text),
        unit: _selectedUnit,
        userId: authProvider.currentUser!.id,
        createdAt: isEditMode ? widget.product!.createdAt : DateTime.now(),
        // Preserve existing image paths when editing
        localImagePath: isEditMode ? widget.product!.localImagePath : null,
        imageUrl: isEditMode ? widget.product!.imageUrl : null,
      );

      bool success;
      if (isEditMode) {
        success = await productProvider.updateProduct(
          product: product,
          imageFile: _imageFile,
        );
      } else {
        success = await productProvider.addProduct(
          product: product,
          imageFile: _imageFile,
          userId: authProvider.currentUser!.id,
        );
      }

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Produk berhasil diupdate' : 'Produk berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.errorMessage ?? 'Gagal menyimpan produk'),
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
        title: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(File(_imageFile!.path)),
                          fit: BoxFit.cover,
                        )
                      : _existingImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_existingImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: _imageFile == null && _existingImagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk tambah foto',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Product name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk *',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama produk tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Barcode & SKU
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Barcode',
                      prefixIcon: const Icon(Icons.qr_code),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanBarcode,
                        tooltip: 'Scan Barcode',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: AppConstants.productCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Prices
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buyingPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga Beli *',
                      prefixIcon: Icon(Icons.shopping_cart_outlined),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellingPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual *',
                      prefixIcon: Icon(Icons.sell_outlined),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stock & Min Stock
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stok *',
                      prefixIcon: Icon(Icons.inventory_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minStockController,
                    decoration: const InputDecoration(
                      labelText: 'Min. Stok *',
                      prefixIcon: Icon(Icons.warning_amber_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Unit
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              decoration: const InputDecoration(
                labelText: 'Satuan *',
                prefixIcon: Icon(Icons.straighten_outlined),
              ),
              items: AppConstants.productUnits.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedUnit = value!);
              },
            ),
            const SizedBox(height: 32),

            // Save button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveProduct,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        isEditMode ? 'Update Produk' : 'Simpan Produk',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
