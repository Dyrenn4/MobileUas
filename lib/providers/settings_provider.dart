import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _currency = 'IDR';
  bool _lowStockAlerts = true;
  int _defaultMinStock = 10;
  String _language = 'id';

  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  bool get lowStockAlerts => _lowStockAlerts;
  int get defaultMinStock => _defaultMinStock;
  String get language => _language;
  bool get isIndonesian => _language == 'id';

  String get currencySymbol {
    switch (_currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'IDR':
        return 'Rp';
      default:
        return 'Rp';
    }
  }

  String formatPrice(double price) {
    if (_currency == 'IDR') {
      return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }
    return '$currencySymbol${price.toStringAsFixed(2)}';
  }

  // Translations
  String tr(String key) {
    final translations = {
      'en': {
        'home': 'Home',
        'products': 'Products',
        'reports': 'Reports',
        'settings': 'Settings',
        'retail_store_inventory': 'Retail Store Inventory',
        'total': 'Total',
        'low_stock': 'Low Stock',
        'sales': 'Value',
        'quick_actions': 'Quick Actions',
        'add_product': 'Add\nProduct',
        'scan_barcode': 'Scan\nBarcode',
        'update_stock': 'Update\nStock',
        'recent_products': 'Recent Products',
        'view_all': 'View All',
        'view_products': 'View Products →',
        'low_stock_alert': 'You have {count} products with low or no stock.',
        'in_stock': 'In Stock',
        'low': 'Low',
        'out': 'Out',
        'stock': 'Stock',
        'search_products': 'Search products...',
        'add_product_title': 'Add Product',
        'edit_product': 'Edit Product',
        'product_image': 'Product Image',
        'upload_image': 'Upload Image',
        'click_to_browse': 'Click to browse',
        'product_name': 'Product Name',
        'enter_product_name': 'Enter product name',
        'sku': 'SKU',
        'enter_sku': 'Enter SKU',
        'price': 'Price',
        'quantity': 'Quantity',
        'category': 'Category',
        'select_category': 'Select category',
        'save_product': 'Save Product',
        'update_product': 'Update Product',
        'stock_reports': 'Stock Reports',
        'stock_in': 'Stock In',
        'stock_out': 'Stock Out',
        'this_week': 'This week',
        'items': 'items',
        'stock_movement': 'Stock Movement',
        'recent_transactions': 'Recent Transactions',
        'no_transactions': 'No transactions yet',
        'appearance': 'Appearance',
        'dark_mode': 'Dark Mode',
        'enable_dark_theme': 'Enable dark theme',
        'notifications': 'Notifications',
        'low_stock_alerts': 'Low Stock Alerts',
        'get_notified': 'Get notified when stock is low',
        'language_setting': 'Language',
        'select_language': 'Select language',
        'about': 'About',
        'version': 'Version',
        'build': 'Build',
        'delete': 'Delete',
        'cancel': 'Cancel',
        'confirm_delete': 'Are you sure you want to delete this product?',
      },
      'id': {
        'home': 'Beranda',
        'products': 'Produk',
        'reports': 'Laporan',
        'settings': 'Pengaturan',
        'retail_store_inventory': 'Toko Kelontong',
        'total': 'Total',
        'low_stock': 'Stok Tipis',
        'sales': 'Nilai',
        'quick_actions': 'Aksi Cepat',
        'add_product': 'Tambah\nProduk',
        'scan_barcode': 'Scan\nBarcode',
        'update_stock': 'Update\nStok',
        'recent_products': 'Produk Terbaru',
        'view_all': 'Lihat Semua',
        'view_products': 'Lihat Produk →',
        'low_stock_alert': 'Ada {count} produk dengan stok tipis atau habis.',
        'in_stock': 'Ada',
        'low': 'Tipis',
        'out': 'Habis',
        'stock': 'Stok',
        'search_products': 'Cari produk...',
        'add_product_title': 'Tambah Produk',
        'edit_product': 'Edit Produk',
        'product_image': 'Gambar Produk',
        'upload_image': 'Unggah Gambar',
        'click_to_browse': 'Klik untuk memilih',
        'product_name': 'Nama Produk',
        'enter_product_name': 'Masukkan nama produk',
        'sku': 'Kode',
        'enter_sku': 'Masukkan kode produk',
        'price': 'Harga',
        'quantity': 'Jumlah',
        'category': 'Kategori',
        'select_category': 'Pilih kategori',
        'save_product': 'Simpan Produk',
        'update_product': 'Perbarui Produk',
        'stock_reports': 'Laporan Stok',
        'stock_in': 'Stok Masuk',
        'stock_out': 'Stok Keluar',
        'this_week': 'Minggu ini',
        'items': 'item',
        'stock_movement': 'Pergerakan Stok',
        'recent_transactions': 'Transaksi Terbaru',
        'no_transactions': 'Belum ada transaksi',
        'appearance': 'Tampilan',
        'dark_mode': 'Mode Gelap',
        'enable_dark_theme': 'Aktifkan tema gelap',
        'notifications': 'Notifikasi',
        'low_stock_alerts': 'Peringatan Stok Tipis',
        'get_notified': 'Notifikasi saat stok menipis',
        'language_setting': 'Bahasa',
        'select_language': 'Pilih bahasa',
        'about': 'Tentang',
        'version': 'Versi',
        'build': 'Build',
        'delete': 'Hapus',
        'cancel': 'Batal',
        'confirm_delete': 'Yakin ingin menghapus produk ini?',
      },
    };
    return translations[_language]?[key] ?? key;
  }

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _currency = prefs.getString('currency') ?? 'IDR';
    _lowStockAlerts = prefs.getBool('lowStockAlerts') ?? true;
    _defaultMinStock = prefs.getInt('defaultMinStock') ?? 10;
    _language = prefs.getString('language') ?? 'id';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', value);
    notifyListeners();
  }

  Future<void> setLowStockAlerts(bool value) async {
    _lowStockAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lowStockAlerts', value);
    notifyListeners();
  }

  Future<void> setDefaultMinStock(int value) async {
    _defaultMinStock = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultMinStock', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    notifyListeners();
  }
}
