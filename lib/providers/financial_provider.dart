import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/financial_transaction.dart';

class FinancialProvider with ChangeNotifier {
  final List<FinancialTransaction> _transactions = [];
  final _uuid = const Uuid();

  List<FinancialTransaction> get transactions => _transactions;

  FinancialProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    _transactions.addAll([
      FinancialTransaction(
        id: _uuid.v4(),
        type: TransactionType.income,
        amount: 150000,
        description: 'Penjualan Indomie 10 pcs',
        category: 'Penjualan',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      FinancialTransaction(
        id: _uuid.v4(),
        type: TransactionType.income,
        amount: 85000,
        description: 'Penjualan minuman',
        category: 'Penjualan',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      FinancialTransaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 500000,
        description: 'Kulakan sembako',
        category: 'Pembelian Stok',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      FinancialTransaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 50000,
        description: 'Listrik toko',
        category: 'Operasional',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      FinancialTransaction(
        id: _uuid.v4(),
        type: TransactionType.income,
        amount: 200000,
        description: 'Penjualan rokok',
        category: 'Penjualan',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ]);
    notifyListeners();
  }

  // Get transactions for specific month
  List<FinancialTransaction> getTransactionsForMonth(int year, int month) {
    return _transactions.where((t) => 
      t.createdAt.year == year && t.createdAt.month == month
    ).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get total income for month
  double getIncomeForMonth(int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Get total expense for month
  double getExpenseForMonth(int year, int month) {
    return getTransactionsForMonth(year, month)
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Get profit for month
  double getProfitForMonth(int year, int month) {
    return getIncomeForMonth(year, month) - getExpenseForMonth(year, month);
  }

  // Get weekly data for chart (last 4 weeks)
  List<Map<String, dynamic>> getWeeklyData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> weeklyData = [];
    
    for (int i = 3; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      final weekTransactions = _transactions.where((t) =>
        t.createdAt.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        t.createdAt.isBefore(weekEnd.add(const Duration(days: 1)))
      ).toList();
      
      final income = weekTransactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
      final expense = weekTransactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
      
      weeklyData.add({
        'week': 'W${4 - i}',
        'income': income,
        'expense': expense,
      });
    }
    
    return weeklyData;
  }

  // Add transaction
  void addTransaction(FinancialTransaction transaction) {
    final newTransaction = FinancialTransaction(
      id: _uuid.v4(),
      type: transaction.type,
      amount: transaction.amount,
      description: transaction.description,
      category: transaction.category,
      createdAt: transaction.createdAt,
      productId: transaction.productId,
    );
    _transactions.insert(0, newTransaction);
    notifyListeners();
  }

  // Add income from sale (auto)
  void addSaleIncome(double amount, String productName) {
    addTransaction(FinancialTransaction(
      id: '',
      type: TransactionType.income,
      amount: amount,
      description: 'Penjualan $productName',
      category: 'Penjualan',
      createdAt: DateTime.now(),
    ));
  }

  // Update transaction
  void updateTransaction(String id, FinancialTransaction updated) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = FinancialTransaction(
        id: id,
        type: updated.type,
        amount: updated.amount,
        description: updated.description,
        category: updated.category,
        createdAt: updated.createdAt,
        productId: updated.productId,
      );
      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  // Delete transaction
  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Get transaction by ID
  FinancialTransaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get today's totals
  double get todayIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.isIncome && _isSameDay(t.createdAt, now))
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get todayExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.isExpense && _isSameDay(t.createdAt, now))
        .fold(0, (sum, t) => sum + t.amount);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get current month totals
  double get currentMonthIncome {
    final now = DateTime.now();
    return getIncomeForMonth(now.year, now.month);
  }

  double get currentMonthExpense {
    final now = DateTime.now();
    return getExpenseForMonth(now.year, now.month);
  }

  double get currentMonthProfit {
    return currentMonthIncome - currentMonthExpense;
  }
}
