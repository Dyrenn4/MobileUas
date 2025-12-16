import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/settings_provider.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final String? productId;

  const AddProductScreen({super.key, this.productId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController(text: '0.00');
  final _quantityController = TextEditingController(text: '0');
  String _selectedCategory = '';
  bool _isEditing = false;

  final List<String> _categories = ['Makanan', 'Minuman', 'Snack', 'Sembako', 'Kebersihan', 'Rokok', 'Obat', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<InventoryProvider>();
        final product = provider.getProductById(widget.productId!);
        if (product != null) {
          _nameController.text = product.name;
          _skuController.text = product.sku;
          _priceController.text = product.price.toStringAsFixed(2);
          _quantityController.text = product.stock.toString();
          setState(() => _selectedCategory = product.category);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<InventoryProvider>();

      if (_isEditing && widget.productId != null) {
        final existingProduct = provider.getProductById(widget.productId!);
        if (existingProduct != null) {
          final updatedProduct = existingProduct.copyWith(
            name: _nameController.text,
            sku: _skuController.text,
            category: _selectedCategory.isEmpty ? 'Uncategorized' : _selectedCategory,
            price: double.tryParse(_priceController.text) ?? 0,
            stock: int.tryParse(_quantityController.text) ?? 0,
          );
          provider.updateProduct(updatedProduct);
        }
      } else {
        final product = Product(
          id: '',
          name: _nameController.text,
          sku: _skuController.text,
          category: _selectedCategory.isEmpty ? 'Uncategorized' : _selectedCategory,
          price: double.tryParse(_priceController.text) ?? 0,
          stock: int.tryParse(_quantityController.text) ?? 0,
          minStock: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        provider.addProduct(product);
      }
      Navigator.pop(context);
    }
  }

  void _deleteProduct() {
    if (widget.productId != null) {
      final settings = context.read<SettingsProvider>();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(settings.tr('delete')),
          content: Text(settings.tr('confirm_delete')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(settings.tr('cancel'))),
            TextButton(
              onPressed: () {
                context.read<InventoryProvider>().deleteProduct(widget.productId!);
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(settings.tr('delete'), style: const TextStyle(color: Colors.red)),
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                    _buildImageUpload(settings, isDark),
                    const SizedBox(height: 20),
                    _buildTextField(settings.tr('product_name'), settings.tr('enter_product_name'), _nameController, isDark),
                    const SizedBox(height: 16),
                    _buildTextField(settings.tr('sku'), settings.tr('enter_sku'), _skuController, isDark),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(settings.tr('price'), '0.00', _priceController, isDark, isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(settings.tr('quantity'), '0', _quantityController, isDark, isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(settings, isDark),
                    const SizedBox(height: 24),
                    _buildSaveButton(settings),
                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      _buildDeleteButton(settings),
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
            _isEditing ? settings.tr('edit_product') : settings.tr('add_product_title'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildImageUpload(SettingsProvider settings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.tr('product_image'), style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(settings.tr('upload_image'), style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
              Text(settings.tr('click_to_browse'), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isDark, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: isDark ? const Color(0xFF3D3D3D) : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2ECC71))),
          ),
          validator: (value) {
            if (!isNumber && (value == null || value.isEmpty)) return 'Required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(SettingsProvider settings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.tr('category'), style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
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
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              hint: Text(settings.tr('select_category'), style: TextStyle(color: Colors.grey[400])),
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF3D3D3D) : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white : Colors.black),
              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: TextStyle(color: isDark ? Colors.white : Colors.black)))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(SettingsProvider settings) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ECC71),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(_isEditing ? settings.tr('update_product') : settings.tr('save_product'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDeleteButton(SettingsProvider settings) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _deleteProduct,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(settings.tr('delete'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
