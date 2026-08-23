// lib/screens/theme_settings_screen.dart
import 'package:flutter/material.dart';
import '../services/app_settings.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final AppSettings _settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Tampilan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _optionTile('Terang', Icons.light_mode_outlined, ThemeMode.light),
            _optionTile('Gelap', Icons.dark_mode_outlined, ThemeMode.dark),
            _optionTile('Ikuti Sistem', Icons.brightness_auto_outlined,
                ThemeMode.system),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: primaryBlue),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Beberapa layar mungkin belum sepenuhnya menyesuaikan mode gelap.',
                          style: TextStyle(fontSize: 11))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(String label, IconData icon, ThemeMode mode) {
    final selected = _settings.themeMode == mode;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: selected ? primaryBlue : Colors.grey.shade300),
      ),
      child: RadioListTile<ThemeMode>(
        value: mode,
        groupValue: _settings.themeMode,
        onChanged: (v) {
          _settings.setThemeMode(v!);
          setState(() {});
        },
        activeColor: primaryBlue,
        secondary: Icon(icon, color: selected ? primaryBlue : Colors.grey),
        title: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
