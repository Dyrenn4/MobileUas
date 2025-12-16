import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/settings_provider.dart';
import '../models/product.dart';

class UpdateStockScreen extends StatefulWidget {
  const UpdateStockScreen({super.key});

  @override
  State<UpdateStockScreen> createState() => _UpdateStockScreenState();
}

class _UpdateStockScreenState extends State<UpdateStockScreen> {
  String? _selectedProductId;
  final _quantityController = TextEditingController();
  bool _isAdding = true; // true = stock in, false = stock out

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Product? _getSelectedProduct(InventoryProvider provider) {
    if (_selectedProductId == null) return null;
    return provider.getProductById(_selectedProductId!);
  }

  void _updateStock() {
    if (_selectedProductId == null) return;
    final qty = int.tryParse(_quantityController.text) ?? 0;
    if (qty <= 0) return;

    final provider = context.read<InventoryProvider>();
    final product = provider.getProductById(_selectedProductId!);
    if (product == null) return;

    final newStock = _isAdding 
        ? product.stock + qty 
        : (product.stock - qty).clamp(0, product.stock);
    
    provider.updateStock(
      _selectedProductId!, 
      newStock, 
      _isAdding ? 'Stock In' : 'Stock Out'
    );
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAdding ? 'Stock added successfully' : 'Stock removed successfully'),
        backgroundColor: const Color(0xFF2ECC71),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final provider = context.watch<InventoryProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock In / Stock Out Toggle
                  _buildStockTypeToggle(settings, isDark),
                  const SizedBox(height: 20),
                  
                  // Product Selector
                  _buildProductSelector(provider, settings, isDark),
                  const SizedBox(height: 16),
                  
                  // Current Stock Display
                  if (_selectedProductId != null) _buildCurrentStock(provider, settings, isDark),
                  const SizedBox(height: 16),
                  
                  // Quantity Input
                  _buildQuantityInput(settings, isDark),
                  const SizedBox(height: 24),
                  
                  // Update Button
                  _buildUpdateButton(settings),
                ],
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
            settings.tr('update_stock').replaceAll('\n', ' '),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStockTypeToggle(SettingsProvider settings, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAdding = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _isAdding ? const Color(0xFF2ECC71) : (isDark ? const Color(0xFF3D3D3D) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: _isAdding ? Colors.white : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    settings.tr('stock_in'),
                    style: TextStyle(
                      color: _isAdding ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAdding = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !_isAdding ? const Color(0xFFE74C3C) : (isDark ? const Color(0xFF3D3D3D) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_circle, color: !_isAdding ? Colors.white : Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    settings.tr('stock_out'),
                    style: TextStyle(
                      color: !_isAdding ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]
    );
  }

  Widget _buildProductSelector(InventoryProvider provider, SettingsProvider settings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.tr('products'), style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF3D3D3D) : Colors.grey[50],
            border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProductId,
              hint: Text(settings.isIndonesian ? 'Pilih produk' : 'Select product', style: TextStyle(color: Colors.grey[400])),
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF3D3D3D) : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white : Colors.black),
              items: provider.allProducts.map((product) => DropdownMenuItem<String>(
                value: product.id,
                child: Text('${product.name} (${product.sku})', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              )).toList(),
              onChanged: (value) => setState(() => _selectedProductId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStock(InventoryProvider provider, SettingsProvider settings, bool isDark) {
    final product = _getSelectedProduct(provider);
    if (product == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            settings.isIndonesian ? 'Stok Saat Ini' : 'Current Stock',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          Text(
            '${product.stock}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput(SettingsProvider settings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.tr('quantity'), style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: isDark ? const Color(0xFF3D3D3D) : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _isAdding ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C))),
            prefixIcon: Icon(_isAdding ? Icons.add : Icons.remove, color: _isAdding ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C)),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(SettingsProvider settings) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedProductId != null ? _updateStock : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isAdding ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _isAdding 
              ? (settings.isIndonesian ? 'Tambah Stok' : 'Add Stock')
              : (settings.isIndonesian ? 'Kurangi Stok' : 'Remove Stock'),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
