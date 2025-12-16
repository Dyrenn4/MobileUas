import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(settings.tr('settings'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 20),
              _buildSection(settings.tr('appearance'), [
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: settings.tr('dark_mode'),
                  subtitle: settings.tr('enable_dark_theme'),
                  value: settings.isDarkMode,
                  onChanged: (value) => settings.setDarkMode(value),
                  isDark: isDark,
                ),
              ], isDark),
              const SizedBox(height: 16),
              _buildSection(settings.tr('language_setting'), [
                _buildLanguageTile(
                  icon: Icons.language,
                  title: settings.tr('language_setting'),
                  value: settings.language,
                  onChanged: (value) => settings.setLanguage(value ?? 'en'),
                  isDark: isDark,
                ),
              ], isDark),
              const SizedBox(height: 16),
              _buildSection(settings.tr('notifications'), [
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: settings.tr('low_stock_alerts'),
                  subtitle: settings.tr('get_notified'),
                  value: settings.lowStockAlerts,
                  onChanged: (value) => settings.setLowStockAlerts(value),
                  isDark: isDark,
                ),
              ], isDark),
              const SizedBox(height: 16),
              _buildSection(settings.tr('about'), [
                _buildInfoTile(icon: Icons.info, title: settings.tr('version'), value: '1.0.0', isDark: isDark),
                _buildInfoTile(icon: Icons.code, title: settings.tr('build'), value: '2025.12.13', isDark: isDark),
              ], isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF2D2D2D) : Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF2ECC71).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF2ECC71), size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xFF2ECC71).withValues(alpha: 0.5),
        activeThumbColor: const Color(0xFF2ECC71),
      ),
    );
  }

  Widget _buildLanguageTile({
    required IconData icon,
    required String title,
    required String value,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF2ECC71).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF2ECC71), size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3D3D3D) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: isDark ? const Color(0xFF3D3D3D) : Colors.white,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'id', child: Text('Indonesia')),
            ],
            onChanged: onChanged,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value, required bool isDark}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.grey[600], size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
      trailing: Text(value, style: TextStyle(color: Colors.grey[600])),
    );
  }
}
