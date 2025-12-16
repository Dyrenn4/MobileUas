import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/inventory_provider.dart';
import '../providers/financial_provider.dart';
import '../providers/settings_provider.dart';
import '../models/stock_history.dart';
import '../models/financial_transaction.dart';
import '../services/pdf_service.dart';
import 'add_transaction_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update FAB visibility
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(settings.tr('stock_reports'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  IconButton(
                    onPressed: () => _showPrintDialog(context, settings, isDark),
                    icon: Icon(Icons.print, color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2ECC71),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF2ECC71),
                tabs: [
                  Tab(text: settings.isIndonesian ? 'Stok' : 'Stock'),
                  Tab(text: settings.isIndonesian ? 'Keuangan' : 'Financial'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStockReport(context, settings, isDark),
                  _buildFinancialReport(context, settings, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 1 ? FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddTransactionScreen(),
        ),
        backgroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildStockReport(BuildContext context, SettingsProvider settings, bool isDark) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStockSummaryCards(provider, settings, isDark),
              const SizedBox(height: 20),
              _buildStockMovementChart(provider, settings, isDark),
              const SizedBox(height: 20),
              _buildRecentStockTransactions(provider, settings, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialReport(BuildContext context, SettingsProvider settings, bool isDark) {
    return Consumer<FinancialProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMonthSelector(settings, isDark),
              const SizedBox(height: 16),
              _buildFinancialSummaryCards(provider, settings, isDark),
              const SizedBox(height: 20),
              _buildFinancialChart(provider, settings, isDark),
              const SizedBox(height: 20),
              _buildFinancialTransactions(provider, settings, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector(SettingsProvider settings, bool isDark) {
    final monthFormat = DateFormat('MMMM yyyy', settings.isIndonesian ? 'id_ID' : 'en_US');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
          ),
          Text(
            monthFormat.format(_selectedMonth),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSummaryCards(InventoryProvider provider, SettingsProvider settings, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard(Icons.trending_up, const Color(0xFF2ECC71), settings.tr('stock_in'), '${provider.stockInThisWeek} ${settings.tr('items')}', settings.tr('this_week'), const Color(0xFF2ECC71), isDark)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard(Icons.trending_down, const Color(0xFFE74C3C), settings.tr('stock_out'), '${provider.stockOutThisWeek} ${settings.tr('items')}', settings.tr('this_week'), const Color(0xFFE74C3C), isDark)),
      ],
    );
  }

  Widget _buildFinancialSummaryCards(FinancialProvider provider, SettingsProvider settings, bool isDark) {
    final income = provider.getIncomeForMonth(_selectedMonth.year, _selectedMonth.month);
    final expense = provider.getExpenseForMonth(_selectedMonth.year, _selectedMonth.month);
    final profit = income - expense;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard(Icons.arrow_downward, const Color(0xFF2ECC71), settings.isIndonesian ? 'Pemasukan' : 'Income', settings.formatPrice(income), '', const Color(0xFF2ECC71), isDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(Icons.arrow_upward, const Color(0xFFE74C3C), settings.isIndonesian ? 'Pengeluaran' : 'Expense', settings.formatPrice(expense), '', const Color(0xFFE74C3C), isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: profit >= 0 ? const Color(0xFF2ECC71).withValues(alpha: 0.1) : const Color(0xFFE74C3C).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: profit >= 0 ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C)),
          ),
          child: Column(
            children: [
              Text(settings.isIndonesian ? 'Laba/Rugi Bulan Ini' : 'Profit/Loss This Month', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
              const SizedBox(height: 4),
              Text(
                settings.formatPrice(profit),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: profit >= 0 ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(IconData icon, Color iconColor, String title, String value, String subtitle, Color subtitleColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12))),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: subtitleColor, fontSize: 12)),
        ],
      ),
    );
  }


  Widget _buildStockMovementChart(InventoryProvider provider, SettingsProvider settings, bool isDark) {
    final now = DateTime.now();
    final stockInData = <int, int>{};
    final stockOutData = <int, int>{};
    
    for (int i = 0; i < 7; i++) {
      stockInData[i] = 0;
      stockOutData[i] = 0;
    }
    
    for (final history in provider.stockHistory) {
      final daysAgo = now.difference(history.createdAt).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        final dayIndex = 6 - daysAgo;
        if (history.type == StockChangeType.add) {
          stockInData[dayIndex] = (stockInData[dayIndex] ?? 0) + history.quantity;
        } else {
          stockOutData[dayIndex] = (stockOutData[dayIndex] ?? 0) + history.quantity;
        }
      }
    }
    
    final stockInSpots = stockInData.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
    final stockOutSpots = stockOutData.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
    final allValues = [...stockInData.values, ...stockOutData.values];
    final maxY = allValues.isEmpty ? 10.0 : (allValues.reduce((a, b) => a > b ? a : b).toDouble() * 1.2).clamp(10.0, double.infinity);
    final dayLabels = List.generate(7, (i) => DateFormat('E').format(now.subtract(Duration(days: 6 - i))));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.tr('stock_movement'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          Row(children: [
            _buildLegendItem(settings.tr('stock_in'), const Color(0xFF2ECC71)),
            const SizedBox(width: 16),
            _buildLegendItem(settings.tr('stock_out'), const Color(0xFFE74C3C)),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, horizontalInterval: maxY / 4, getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.grey[700]! : Colors.grey[200]!, strokeWidth: 1)),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, interval: maxY / 4, getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: TextStyle(color: Colors.grey[600], fontSize: 10)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => value.toInt() < dayLabels.length ? Text(dayLabels[value.toInt()], style: TextStyle(color: Colors.grey[600], fontSize: 10)) : const Text(''))),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0, maxX: 6, minY: 0, maxY: maxY,
              lineBarsData: [
                LineChartBarData(spots: stockInSpots, isCurved: true, color: const Color(0xFF2ECC71), barWidth: 3, dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 4, color: const Color(0xFF2ECC71), strokeWidth: 2, strokeColor: Colors.white))),
                LineChartBarData(spots: stockOutSpots, isCurved: true, color: const Color(0xFFE74C3C), barWidth: 3, dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 4, color: const Color(0xFFE74C3C), strokeWidth: 2, strokeColor: Colors.white))),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialChart(FinancialProvider provider, SettingsProvider settings, bool isDark) {
    final weeklyData = provider.getWeeklyData();
    final maxValue = weeklyData.fold<double>(0, (max, d) => [max, d['income'] as double, d['expense'] as double].reduce((a, b) => a > b ? a : b));
    final maxY = maxValue == 0 ? 100000.0 : maxValue * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.isIndonesian ? 'Grafik Mingguan' : 'Weekly Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          Row(children: [
            _buildLegendItem(settings.isIndonesian ? 'Pemasukan' : 'Income', const Color(0xFF2ECC71)),
            const SizedBox(width: 16),
            _buildLegendItem(settings.isIndonesian ? 'Pengeluaran' : 'Expense', const Color(0xFFE74C3C)),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barGroups: weeklyData.asMap().entries.map((e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(toY: e.value['income'], color: const Color(0xFF2ECC71), width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                  BarChartRodData(toY: e.value['expense'], color: const Color(0xFFE74C3C), width: 12, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                ],
              )).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (value, meta) => Text(_formatShortPrice(value), style: TextStyle(color: Colors.grey[600], fontSize: 10)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(weeklyData[value.toInt()]['week'], style: TextStyle(color: Colors.grey[600], fontSize: 10)))),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: true, getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.grey[700]! : Colors.grey[200]!, strokeWidth: 1)),
              borderData: FlBorderData(show: false),
            )),
          ),
        ],
      ),
    );
  }

  String _formatShortPrice(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}jt';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}rb';
    return value.toStringAsFixed(0);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    ]);
  }

  Widget _buildRecentStockTransactions(InventoryProvider provider, SettingsProvider settings, bool isDark) {
    final transactions = provider.stockHistory.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.tr('recent_transactions'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 16),
          if (transactions.isEmpty) Center(child: Text(settings.tr('no_transactions'), style: const TextStyle(color: Colors.grey)))
          else ...transactions.map((t) => _buildStockTransactionItem(t, isDark)),
        ],
      ),
    );
  }

  Widget _buildStockTransactionItem(StockHistory transaction, bool isDark) {
    final isStockIn = transaction.type == StockChangeType.add;
    final color = isStockIn ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(isStockIn ? Icons.trending_up : Icons.trending_down, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(transaction.productName, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
          Text(DateFormat('yyyy-MM-dd').format(transaction.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ])),
        Text('${isStockIn ? '+' : '-'}${transaction.quantity}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    );
  }

  Widget _buildFinancialTransactions(FinancialProvider provider, SettingsProvider settings, bool isDark) {
    final transactions = provider.getTransactionsForMonth(_selectedMonth.year, _selectedMonth.month).take(10).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(settings.isIndonesian ? 'Transaksi Bulan Ini' : 'This Month Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 16),
          if (transactions.isEmpty) Center(child: Text(settings.tr('no_transactions'), style: const TextStyle(color: Colors.grey)))
          else ...transactions.map((t) => _buildFinancialTransactionItem(t, settings, isDark)),
        ],
      ),
    );
  }

  Widget _buildFinancialTransactionItem(FinancialTransaction transaction, SettingsProvider settings, bool isDark) {
    final color = transaction.isIncome ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3D3D3D) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(transaction.description, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
            Text('${transaction.category} • ${DateFormat('dd MMM').format(transaction.createdAt)}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${transaction.isIncome ? '+' : '-'}${settings.formatPrice(transaction.amount)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Icon(Icons.edit, size: 14, color: Colors.grey[400]),
          ]),
        ]),
      ),
    );
  }

  void _showPrintDialog(BuildContext context, SettingsProvider settings, bool isDark) {
    final inventoryProvider = context.read<InventoryProvider>();
    final financialProvider = context.read<FinancialProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        title: Text(settings.isIndonesian ? 'Cetak Laporan' : 'Print Report', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPrintOption(ctx, Icons.inventory_2, settings.isIndonesian ? 'Laporan Stok' : 'Stock Report', () async {
              Navigator.pop(ctx);
              await PdfService.printStockReport(
                products: inventoryProvider.allProducts,
                stockHistory: inventoryProvider.stockHistory,
                stockIn: inventoryProvider.stockInThisWeek,
                stockOut: inventoryProvider.stockOutThisWeek,
              );
            }, isDark),
            _buildPrintOption(ctx, Icons.account_balance_wallet, settings.isIndonesian ? 'Laporan Keuangan Bulanan' : 'Monthly Financial Report', () async {
              Navigator.pop(ctx);
              await PdfService.printFinancialReport(
                transactions: financialProvider.getTransactionsForMonth(_selectedMonth.year, _selectedMonth.month),
                totalIncome: financialProvider.getIncomeForMonth(_selectedMonth.year, _selectedMonth.month),
                totalExpense: financialProvider.getExpenseForMonth(_selectedMonth.year, _selectedMonth.month),
                year: _selectedMonth.year,
                month: _selectedMonth.month,
              );
            }, isDark),
            _buildPrintOption(ctx, Icons.summarize, settings.isIndonesian ? 'Laporan Lengkap' : 'Complete Report', () async {
              Navigator.pop(ctx);
              await PdfService.printCompleteReport(
                products: inventoryProvider.allProducts,
                stockHistory: inventoryProvider.stockHistory,
                transactions: financialProvider.getTransactionsForMonth(_selectedMonth.year, _selectedMonth.month),
                stockIn: inventoryProvider.stockInThisWeek,
                stockOut: inventoryProvider.stockOutThisWeek,
                totalIncome: financialProvider.getIncomeForMonth(_selectedMonth.year, _selectedMonth.month),
                totalExpense: financialProvider.getExpenseForMonth(_selectedMonth.year, _selectedMonth.month),
                year: _selectedMonth.year,
                month: _selectedMonth.month,
              );
            }, isDark),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(settings.tr('cancel')))],
      ),
    );
  }

  Widget _buildPrintOption(BuildContext ctx, IconData icon, String title, VoidCallback onTap, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2ECC71)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      onTap: onTap,
    );
  }
}
