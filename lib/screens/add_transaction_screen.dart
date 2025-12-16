import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/financial_provider.dart';
import '../providers/settings_provider.dart';
import '../models/financial_transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final FinancialTransaction? transaction; // For editing

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isIncome = true;
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  final List<String> _incomeCategories = ['Penjualan', 'Piutang Lunas', 'Lainnya'];
  final List<String> _expenseCategories = ['Pembelian Stok', 'Operasional', 'Listrik', 'Gaji', 'Sewa', 'Transport', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _isEditing = true;
      _isIncome = widget.transaction!.isIncome;
      _amountController.text = widget.transaction!.amount.toStringAsFixed(0);
      _descriptionController.text = widget.transaction!.description;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.createdAt;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate() && _selectedCategory.isNotEmpty) {
      final provider = context.read<FinancialProvider>();
      
      if (_isEditing && widget.transaction != null) {
        provider.updateTransaction(
          widget.transaction!.id,
          FinancialTransaction(
            id: widget.transaction!.id,
            type: _isIncome ? TransactionType.income : TransactionType.expense,
            amount: double.tryParse(_amountController.text) ?? 0,
            description: _descriptionController.text,
            category: _selectedCategory,
            createdAt: _selectedDate,
          ),
        );
      } else {
        provider.addTransaction(FinancialTransaction(
          id: '',
          type: _isIncome ? TransactionType.income : TransactionType.expense,
          amount: double.tryParse(_amountController.text) ?? 0,
          description: _descriptionController.text,
          category: _selectedCategory,
          createdAt: _selectedDate,
        ));
      }
      Navigator.pop(context);
    }
  }

  void _deleteTransaction() {
    if (widget.transaction != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus Transaksi'),
          content: const Text('Yakin ingin menghapus transaksi ini?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                context.read<FinancialProvider>().deleteTransaction(widget.transaction!.id);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final categories = _isIncome ? _incomeCategories : _expenseCategories;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(settings, isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeToggle(settings, isDark),
                    const SizedBox(height: 20),
                    _buildDatePicker(settings, isDark),
                    const SizedBox(height: 16),
                    _buildAmountField(settings, isDark),
                    const SizedBox(height: 16),
                    _buildDescriptionField(settings, isDark),
                    const SizedBox(height: 16),
                    _buildCategorySelector(categories, settings, isDark),
                    const SizedBox(height: 24),
                    _buildSaveButton(settings),
                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      _buildDeleteButton(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SettingsProvider settings, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[200]!))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _isEditing 
                ? (settings.isIndonesian ? 'Edit Transaksi' : 'Edit Transaction')
                : (settings.isIndonesian ? 'Tambah Transaksi' : 'Add Transaction'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(SettingsProvider settings, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() { _isIncome = true; _selectedCategory = ''; }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isIncome ? const Color(0xFF2ECC71) : (isDark ? const Color(0xFF3D3D3D) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_downward, color: _isIncome ? Colors.white : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(settings.isIndonesian ? 'Pemasukan' : 'Income', style: TextStyle(color: _isIncome ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() { _isIncome = false; _selectedCategory = ''; }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_isIncome ? const Color(0xFFE74C3C) : (isDark ? const Color(0xFF3D3D3D) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward, color: !_isIncome ? Colors.white : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(settings.isIndonesian ? 'Pengeluaran' : 'Expense', style: TextStyle(color: !_isIncome ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(SettingsProvider settings, bool isDark) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', settings.isIndonesian ? 'id_ID' : 'en_US');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.isIndonesian ? 'Tanggal' : 'Date', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3D3D3D) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(dateFormat.format(_selectedDate), style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                Icon(Icons.arrow_drop_down, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField(SettingsProvider settings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.isIndonesian ? 'Jumlah (Rp)' : 'Amount', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
          decoration: InputDecoration(
            hintText: '0',
            prefixText: 'Rp ',
            prefixStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
            filled: true,
            fillColor: isDark ? const Color(0xFF3D3D3D) : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildDescriptionField(SettingsProvider settings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.isIndonesian ? 'Keterangan' : 'Description', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: settings.isIndonesian ? 'Contoh: Beli stok indomie' : 'Enter description',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: isDark ? const Color(0xFF3D3D3D) : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildCategorySelector(List<String> categories, SettingsProvider settings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.isIndonesian ? 'Kategori' : 'Category', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) => GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedCategory == cat ? (_isIncome ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C)) : (isDark ? const Color(0xFF3D3D3D) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(cat, style: TextStyle(color: _selectedCategory == cat ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]), fontWeight: _selectedCategory == cat ? FontWeight.w600 : FontWeight.normal)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(SettingsProvider settings) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isIncome ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(_isEditing ? 'Update Transaksi' : 'Simpan Transaksi', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _deleteTransaction,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Hapus Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
