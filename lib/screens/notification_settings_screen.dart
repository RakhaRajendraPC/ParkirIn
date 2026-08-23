// lib/screens/notification_settings_screen.dart
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  bool _reminder = true;
  bool _shuttle = true;
  bool _promo = true;
  bool _booking = true;
  bool _flight = false;
  bool _emailNotif = true;
  bool _pushNotif = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Pengaturan Notifikasi',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Saluran Notifikasi', [
              _switchTile('Push Notification', 'Notifikasi langsung di HP Anda',
                  _pushNotif, (v) => setState(() => _pushNotif = v)),
              _switchTile('Email', 'Ringkasan & konfirmasi via email',
                  _emailNotif, (v) => setState(() => _emailNotif = v)),
            ]),
            const SizedBox(height: 16),
            _buildSection('Jenis Notifikasi', [
              _switchTile('Reminder Check-in', 'Pengingat H-1 sebelum jadwal',
                  _reminder, (v) => setState(() => _reminder = v)),
              _switchTile('Update Shuttle', 'Status & ETA shuttle jemputan',
                  _shuttle, (v) => setState(() => _shuttle = v)),
              _switchTile(
                  'Booking & Overstay',
                  'Konfirmasi booking dan peringatan biaya tambahan',
                  _booking,
                  (v) => setState(() => _booking = v)),
              _switchTile(
                  'Perubahan Penerbangan',
                  'Info delay/reschedule jadwal (Fase 2)',
                  _flight,
                  (v) => setState(() => _flight = v)),
              _switchTile(
                  'Promo & Voucher',
                  'Info diskon dan penawaran spesial',
                  _promo,
                  (v) => setState(() => _promo = v)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 8),
            child: Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 8)
                ]),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: primaryBlue,
      title: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    );
  }
}
