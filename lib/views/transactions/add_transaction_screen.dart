import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/product_model.dart';
import '../../constants/app_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _quantityController;
  late TextEditingController _customerNameController;
  late TextEditingController _notesController;
  
  ProductModel? _selectedProduct;
  String _selectedType = 'sale';
  bool _isLoading = false;
  
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _customerNameController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _total {
    if (_selectedProduct == null) return 0;
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double price = _selectedType == 'sale' 
        ? _selectedProduct!.sellingPrice 
        : _selectedProduct!.buyingPrice;
    return quantity * price;
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih produk terlebih dahulu'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan')),
      );
      return;
    }

    try {
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        type: _selectedType,
        quantity: int.parse(_quantityController.text),
        price: _selectedType == 'sale' 
            ? _selectedProduct!.sellingPrice 
            : _selectedProduct!.buyingPrice,
        total: _total,
        customerName: _customerNameController.text.trim().isEmpty 
            ? null 
            : _customerNameController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        userId: authProvider.currentUser!.id,
        createdAt: DateTime.now(),
      );

      bool success = await transactionProvider.addTransaction(
        transaction: transaction,
        userId: authProvider.currentUser!.id,
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil ditambahkan'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transactionProvider.errorMessage ?? 'Gagal menambahkan transaksi'),
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
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transaction type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipe Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Penjualan'),
                            value: 'sale',
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Pembelian'),
                            value: 'purchase',
                            groupValue: _selectedType,
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Product selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(_selectedProduct?.name ?? 'Pilih Produk'),
                subtitle: _selectedProduct != null
                    ? Text(
                        '${_selectedType == 'sale' ? 'Harga Jual' : 'Harga Beli'}: ${currencyFormat.format(_selectedType == 'sale' ? _selectedProduct!.sellingPrice : _selectedProduct!.buyingPrice)}\n'
                        'Stok: ${_selectedProduct!.stock} ${_selectedProduct!.unit}',
                      )
                    : const Text('Tap untuk memilih produk'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final selected = await showDialog<ProductModel>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Pilih Produk'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: products.isEmpty
                            ? const Center(child: Text('Belum ada produk'))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return ListTile(
                                    title: Text(product.name),
                                    subtitle: Text(
                                      '${currencyFormat.format(product.sellingPrice)} - Stok: ${product.stock}',
                                    ),
                                    onTap: () => Navigator.pop(context, product),
                                  );
                                },
                              ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                      ],
                    ),
                  );
                  
                  if (selected != null) {
                    setState(() {
                      _selectedProduct = selected;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah harus diisi';
                }
                int? qty = int.tryParse(value);
                if (qty == null || qty <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }
                if (_selectedType == 'sale' && _selectedProduct != null && qty > _selectedProduct!.stock) {
                  return 'Stok tidak mencukupi (tersedia: ${_selectedProduct!.stock})';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // Update total
              },
            ),

            const SizedBox(height: 16),

            // Customer name (optional for sales)
            if (_selectedType == 'sale')
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),

            if (_selectedType == 'sale') const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // Total
            Card(
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currencyFormat.format(_total),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
                    : const Text(
                        'Simpan Transaksi',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
