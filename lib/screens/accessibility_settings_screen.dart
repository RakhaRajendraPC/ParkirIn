// lib/screens/accessibility_settings_screen.dart
import 'package:flutter/material.dart';
import '../services/app_settings.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final AppSettings _settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Aksesibilitas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ukuran Teks',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Contoh teks pada ukuran ini',
                      style: TextStyle(fontSize: 14 * _settings.textScale)),
                  Slider(
                    value: _settings.textScale,
                    min: 0.9,
                    max: 1.4,
                    divisions: 5,
                    activeColor: primaryBlue,
                    label: '${(_settings.textScale * 100).round()}%',
                    onChanged: (v) {
                      _settings.setTextScale(v);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: SwitchListTile(
                value: _settings.highContrast,
                onChanged: (v) {
                  _settings.setHighContrast(v);
                  setState(() {});
                },
                activeColor: primaryBlue,
                title: const Text('Kontras Tinggi',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text(
                    'Mempertajam warna utama agar lebih mudah dibaca',
                    style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
