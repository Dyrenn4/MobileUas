import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/stock_history.dart';

class InventoryProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<StockHistory> _stockHistory = [];
  final _uuid = const Uuid();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<Product> get products {
    var filtered = _products;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    return filtered;
  }

  List<Product> get allProducts => _products;
  List<StockHistory> get stockHistory => _stockHistory;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;
  double get totalValue => _products.fold(0, (sum, p) => sum + (p.price * p.stock));

  int get stockInThisWeek {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _stockHistory
        .where((h) => h.type == StockChangeType.add && h.createdAt.isAfter(weekAgo))
        .fold(0, (sum, h) => sum + h.quantity);
  }

  int get stockOutThisWeek {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _stockHistory
        .where((h) => h.type == StockChangeType.remove && h.createdAt.isAfter(weekAgo))
        .fold(0, (sum, h) => sum + h.quantity);
  }

  InventoryProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    _products.addAll([
      Product(
        id: _uuid.v4(),
        name: 'Indomie Goreng',
        sku: 'MIE-001',
        category: 'Makanan',
        price: 3500,
        stock: 48,
        minStock: 24,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Aqua Gelas',
        sku: 'MNM-001',
        category: 'Minuman',
        price: 500,
        stock: 120,
        minStock: 48,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Aqua Botol 600ml',
        sku: 'MNM-002',
        category: 'Minuman',
        price: 3500,
        stock: 24,
        minStock: 12,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Teh Pucuk Harum',
        sku: 'MNM-003',
        category: 'Minuman',
        price: 4000,
        stock: 18,
        minStock: 12,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Pocari Sweat',
        sku: 'MNM-004',
        category: 'Minuman',
        price: 7500,
        stock: 8,
        minStock: 12,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Mie Sedaap Goreng',
        sku: 'MIE-002',
        category: 'Makanan',
        price: 3000,
        stock: 36,
        minStock: 24,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Chitato Original',
        sku: 'SNK-001',
        category: 'Snack',
        price: 10000,
        stock: 15,
        minStock: 10,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Tango Wafer Coklat',
        sku: 'SNK-002',
        category: 'Snack',
        price: 5000,
        stock: 20,
        minStock: 10,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Sabun Lifebuoy',
        sku: 'KBR-001',
        category: 'Kebersihan',
        price: 4500,
        stock: 12,
        minStock: 6,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Pasta Gigi Pepsodent',
        sku: 'KBR-002',
        category: 'Kebersihan',
        price: 12000,
        stock: 8,
        minStock: 5,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Rokok Surya 12',
        sku: 'RKK-001',
        category: 'Rokok',
        price: 18000,
        stock: 0,
        minStock: 10,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Beras 5kg',
        sku: 'SMB-001',
        category: 'Sembako',
        price: 65000,
        stock: 5,
        minStock: 3,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Minyak Goreng 1L',
        sku: 'SMB-002',
        category: 'Sembako',
        price: 18000,
        stock: 10,
        minStock: 5,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Gula Pasir 1kg',
        sku: 'SMB-003',
        category: 'Sembako',
        price: 15000,
        stock: 8,
        minStock: 5,
        createdAt: now,
        updatedAt: now,
      ),
      Product(
        id: _uuid.v4(),
        name: 'Kopi Kapal Api',
        sku: 'MNM-005',
        category: 'Minuman',
        price: 1500,
        stock: 50,
        minStock: 20,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    _stockHistory.addAll([
      StockHistory(
        id: _uuid.v4(),
        productId: _products[0].id,
        productName: 'Indomie Goreng',
        type: StockChangeType.add,
        quantity: 24,
        previousStock: 24,
        newStock: 48,
        notes: 'Restok dari supplier',
        createdAt: DateTime(2025, 12, 14),
      ),
      StockHistory(
        id: _uuid.v4(),
        productId: _products[1].id,
        productName: 'Aqua Gelas',
        type: StockChangeType.remove,
        quantity: 24,
        previousStock: 144,
        newStock: 120,
        notes: 'Terjual',
        createdAt: DateTime(2025, 12, 14),
      ),
      StockHistory(
        id: _uuid.v4(),
        productId: _products[4].id,
        productName: 'Pocari Sweat',
        type: StockChangeType.remove,
        quantity: 4,
        previousStock: 12,
        newStock: 8,
        notes: 'Terjual',
        createdAt: DateTime(2025, 12, 13),
      ),
    ]);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addProduct(Product product) {
    final newProduct = Product(
      id: _uuid.v4(),
      name: product.name,
      sku: product.sku,
      category: product.category,
      price: product.price,
      stock: product.stock,
      minStock: product.minStock,
      imageUrl: product.imageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _products.add(newProduct);
    _addStockHistory(newProduct, StockChangeType.add, product.stock, 0, 'Initial stock');
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      final oldProduct = _products[index];
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      _products[index] = updatedProduct;

      if (oldProduct.stock != product.stock) {
        final type = product.stock > oldProduct.stock ? StockChangeType.add : StockChangeType.remove;
        _addStockHistory(updatedProduct, type, (product.stock - oldProduct.stock).abs(), oldProduct.stock, 'Stock adjustment');
      }
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updateStock(String productId, int newStock, String? notes) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final oldProduct = _products[index];
      final updatedProduct = oldProduct.copyWith(stock: newStock, updatedAt: DateTime.now());
      _products[index] = updatedProduct;

      final type = newStock > oldProduct.stock ? StockChangeType.add : StockChangeType.remove;
      _addStockHistory(updatedProduct, type, (newStock - oldProduct.stock).abs(), oldProduct.stock, notes);
      notifyListeners();
    }
  }

  void _addStockHistory(Product product, StockChangeType type, int quantity, int previousStock, String? notes) {
    _stockHistory.insert(0, StockHistory(
      id: _uuid.v4(),
      productId: product.id,
      productName: product.name,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      newStock: product.stock,
      notes: notes,
      createdAt: DateTime.now(),
    ));
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
