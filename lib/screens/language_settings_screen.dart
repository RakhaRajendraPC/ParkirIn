// lib/screens/language_settings_screen.dart
import 'package:flutter/material.dart';
import '../services/app_settings.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final AppSettings _settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Bahasa',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _langTile('Bahasa Indonesia', AppLanguage.id),
            _langTile('English', AppLanguage.en),
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
                          'Saat ini terjemahan baru mencakup navigasi utama dan sebagian halaman.',
                          style: TextStyle(fontSize: 11))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langTile(String label, AppLanguage lang) {
    final selected = _settings.language == lang;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: selected ? primaryBlue : Colors.grey.shade300),
      ),
      child: RadioListTile<AppLanguage>(
        value: lang,
        groupValue: _settings.language,
        onChanged: (v) {
          _settings.setLanguage(v!);
          setState(() {});
        },
        activeColor: primaryBlue,
        title: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
