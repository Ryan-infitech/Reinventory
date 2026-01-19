import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../constants/app_constants.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'all'; // all, sale, purchase

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions(authProvider.currentUser!.id);
    }
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> transactions) {
    if (_selectedFilter == 'all') return transactions;
    return transactions.where((t) => t.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final allTransactions = transactionProvider.transactions;
    final transactions = _getFilteredTransactions(allTransactions);
    
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Semua'),
              ),
              const PopupMenuItem(
                value: 'sale',
                child: Text('Penjualan'),
              ),
              const PopupMenuItem(
                value: 'purchase',
                child: Text('Pembelian'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Penjualan', 'sale'),
                const SizedBox(width: 8),
                _buildFilterChip('Pembelian', 'purchase'),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada transaksi',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap tombol + untuk menambah transaksi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _loadTransactions(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildTransactionCard(transaction, currencyFormat);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          
          if (result == true && mounted) {
            _loadTransactions();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Transaksi'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction, NumberFormat currencyFormat) {
    final isSale = transaction.type == 'sale';
    final color = isSale ? AppColors.success : AppColors.info;
    final icon = isSale ? Icons.sell : Icons.shopping_cart;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.productName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${transaction.quantity} item × ${currencyFormat.format(transaction.price)}'),
            const SizedBox(height: 2),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(transaction.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (transaction.customerName != null) ...[
              const SizedBox(height: 2),
              Text(
                'Pelanggan: ${transaction.customerName}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (transaction.notes != null) ...[
              const SizedBox(height: 2),
              Text(
                transaction.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(transaction.total),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isSale ? 'Jual' : 'Beli',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        onLongPress: () => _showDeleteDialog(transaction),
      ),
    );
  }

  void _showDeleteDialog(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text(
          'Menghapus transaksi akan mengembalikan stok produk. '
          'Apakah Anda yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final transactionProvider = Provider.of<TransactionProvider>(
                context,
                listen: false,
              );
              bool success = await transactionProvider.deleteTransaction(transaction);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaksi berhasil dihapus'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      transactionProvider.errorMessage ?? 'Gagal menghapus transaksi',
                    ),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
