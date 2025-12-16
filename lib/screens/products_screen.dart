import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/settings_provider.dart';
import '../models/product.dart';

class ProductsScreen extends StatelessWidget {
  final Function(String) onEditProduct;

  const ProductsScreen({super.key, required this.onEditProduct});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(settings.tr('products'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 16),
                  _buildSearchBar(context, settings, isDark),
                ],
              ),
            ),
            Expanded(
              child: Consumer<InventoryProvider>(
                builder: (context, provider, _) {
                  final products = provider.products;
                  if (products.isEmpty) {
                    return Center(child: Text('No products found', style: TextStyle(color: isDark ? Colors.grey : Colors.black54)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) => _buildProductCard(context, products[index], settings, isDark),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, SettingsProvider settings, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              onChanged: (value) => context.read<InventoryProvider>().setSearchQuery(value),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: settings.tr('search_products'),
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.tune, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, SettingsProvider settings, bool isDark) {
    String statusText;
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    if (product.isOutOfStock) {
      statusText = settings.tr('out');
      statusColor = const Color(0xFFE74C3C);
      statusBgColor = isDark ? const Color(0xFF3D2020) : const Color(0xFFFDEDED);
      statusIcon = Icons.close;
    } else if (product.isLowStock) {
      statusText = settings.tr('low');
      statusColor = const Color(0xFFF39C12);
      statusBgColor = isDark ? const Color(0xFF3D3520) : const Color(0xFFFFF3CD);
      statusIcon = Icons.warning_amber;
    } else {
      statusText = settings.tr('stock');
      statusColor = const Color(0xFF2ECC71);
      statusBgColor = isDark ? const Color(0xFF203D28) : const Color(0xFFE8F8F0);
      statusIcon = Icons.check;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.image, color: Colors.grey, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(product.sku, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(settings.formatPrice(product.price), style: const TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Text('Qty: ${product.stock}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => onEditProduct(product.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF2ECC71), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
