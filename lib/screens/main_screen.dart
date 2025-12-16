import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'add_product_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void navigateToProducts() {
    setState(() => _currentIndex = 1);
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _showAddProductSheet();
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _showAddProductSheet({String? productId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProductScreen(productId: productId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    
    final screens = [
      HomeScreen(onNavigateToProducts: navigateToProducts, onEditProduct: (id) => _showAddProductSheet(productId: id)),
      ProductsScreen(onEditProduct: (id) => _showAddProductSheet(productId: id)),
      const SizedBox(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      body: screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductSheet(),
        backgroundColor: const Color(0xFF2ECC71),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, settings.tr('home'), isDark),
              _buildNavItem(1, Icons.inventory_2_outlined, Icons.inventory_2, settings.tr('products'), isDark),
              const SizedBox(width: 48),
              _buildNavItem(3, Icons.description_outlined, Icons.description, settings.tr('reports'), isDark),
              _buildNavItem(4, Icons.settings_outlined, Icons.settings, settings.tr('settings'), isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF2ECC71) : (isDark ? Colors.grey[400] : Colors.grey);
    
    return InkWell(
      onTap: () => _onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        ],
      ),
    );
  }
}
