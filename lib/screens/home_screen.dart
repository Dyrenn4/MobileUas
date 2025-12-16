import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../providers/financial_provider.dart';
import '../providers/settings_provider.dart';
import '../models/product.dart';
import 'update_stock_screen.dart';
import 'add_product_screen.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToProducts;
  final Function(String) onEditProduct;

  const HomeScreen({super.key, required this.onNavigateToProducts, required this.onEditProduct});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          final lowStockProducts = provider.allProducts.where((p) => p.isLowStock || p.isOutOfStock).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider, settings, isDark),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTodaySummary(context, settings, isDark),
                      const SizedBox(height: 16),
                      _buildQuickActions(context, settings, isDark),
                      const SizedBox(height: 16),
                      if (lowStockProducts.isNotEmpty) _buildLowStockAlert(context, lowStockProducts.length, settings, isDark),
                      const SizedBox(height: 16),
                      _buildRecentProducts(context, provider, settings, isDark),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InventoryProvider provider, SettingsProvider settings, bool isDark) {
    final now = DateTime.now();
    final dateFormat = settings.isIndonesian
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID')
        : DateFormat('EEEE, d MMMM yyyy', 'en_US');

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 16, right: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF2ECC71),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateFormat.format(now), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(settings.tr('retail_store_inventory'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.store, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(Icons.inventory_2, settings.tr('total'), provider.totalProducts.toString(), const Color(0xFF2ECC71)),
              const SizedBox(width: 12),
              _buildStatCard(Icons.warning_amber, settings.tr('low_stock'), provider.lowStockCount.toString(), const Color(0xFFF39C12)),
              const SizedBox(width: 12),
              _buildStatCard(Icons.attach_money, settings.tr('sales'), settings.formatPrice(provider.totalValue), const Color(0xFF2ECC71)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color iconBgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: iconBgColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconBgColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, SettingsProvider settings, bool isDark) {
    return Consumer<FinancialProvider>(
      builder: (context, financial, _) {
        final todayIncome = financial.todayIncome;
        final todayExpense = financial.todayExpense;
        final todayProfit = todayIncome - todayExpense;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(settings.isIndonesian ? 'Keuangan Hari Ini' : 'Today\'s Finance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AddTransactionScreen(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF2ECC71), borderRadius: BorderRadius.circular(20)),
                      child: Text(settings.isIndonesian ? '+ Transaksi' : '+ Transaction', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFinanceItem(Icons.arrow_downward, settings.isIndonesian ? 'Masuk' : 'In', settings.formatPrice(todayIncome), const Color(0xFF2ECC71), isDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFinanceItem(Icons.arrow_upward, settings.isIndonesian ? 'Keluar' : 'Out', settings.formatPrice(todayExpense), const Color(0xFFE74C3C), isDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFinanceItem(Icons.account_balance_wallet, settings.isIndonesian ? 'Laba' : 'Profit', settings.formatPrice(todayProfit), todayProfit >= 0 ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C), isDark),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinanceItem(IconData icon, String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, SettingsProvider settings, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.tr('quick_actions'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(context, Icons.add, settings.tr('add_product'), const Color(0xFF2ECC71), () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddProductScreen(),
              );
            }),
            const SizedBox(width: 24),
            _buildActionButton(context, Icons.qr_code_scanner, settings.tr('scan_barcode'), const Color(0xFFF39C12), () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(settings.isIndonesian ? 'Fitur scan barcode akan segera hadir' : 'Barcode scanner coming soon')),
              );
            }),
            const SizedBox(width: 24),
            _buildActionButton(context, Icons.refresh, settings.tr('update_stock'), const Color(0xFF2ECC71), () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const UpdateStockScreen(),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(BuildContext context, int count, SettingsProvider settings, bool isDark) {
    final alertText = settings.tr('low_stock_alert').replaceAll('{count}', count.toString());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3D3520) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE69C)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFF39C12), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alertText, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onNavigateToProducts,
                  child: Text(settings.tr('view_products'), style: const TextStyle(color: Color(0xFFF39C12), fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProducts(BuildContext context, InventoryProvider provider, SettingsProvider settings, bool isDark) {
    final recentProducts = provider.allProducts.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(settings.tr('recent_products'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
            TextButton(
              onPressed: onNavigateToProducts,
              child: Text(settings.tr('view_all'), style: const TextStyle(color: Color(0xFF2ECC71))),
            ),
          ],
        ),
        ...recentProducts.map((product) => _buildProductCard(product, settings, isDark)),
      ],
    );
  }

  Widget _buildProductCard(Product product, SettingsProvider settings, bool isDark) {
    String statusText;
    Color statusColor;
    Color statusBgColor;

    if (product.isOutOfStock) {
      statusText = settings.tr('out');
      statusColor = const Color(0xFFE74C3C);
      statusBgColor = isDark ? const Color(0xFF3D2020) : const Color(0xFFFDEDED);
    } else if (product.isLowStock) {
      statusText = settings.tr('low');
      statusColor = const Color(0xFFF39C12);
      statusBgColor = isDark ? const Color(0xFF3D3520) : const Color(0xFFFFF3CD);
    } else {
      statusText = settings.tr('in_stock');
      statusColor = const Color(0xFF2ECC71);
      statusBgColor = isDark ? const Color(0xFF203D28) : const Color(0xFFE8F8F0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                Text(settings.formatPrice(product.price), style: const TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Qty: ${product.stock}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
