// lib/screens/notification_settings_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final NotificationPreferences _prefs = NotificationPreferences.instance;

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
                  _prefs.pushEnabled, (v) {
                _prefs.setPush(v);
                setState(() {});
              }),
              _switchTile('Email', 'Ringkasan & konfirmasi via email',
                  _prefs.emailEnabled, (v) {
                _prefs.setEmail(v);
                setState(() {});
              }),
            ]),
            const SizedBox(height: 16),
            _buildSection('Jenis Notifikasi', [
              _switchTile('Reminder Check-in', 'Pengingat H-1 sebelum jadwal',
                  _prefs.reminderEnabled, (v) {
                _prefs.setReminder(v);
                setState(() {});
              }),
              _switchTile(
                  'Update Shuttle',
                  'Status & ketersediaan shuttle jemputan',
                  _prefs.shuttleEnabled, (v) {
                _prefs.setShuttle(v);
                setState(() {});
              }),
              _switchTile(
                  'Booking & Overstay',
                  'Konfirmasi booking, check-in/out, dan peringatan biaya tambahan',
                  _prefs.bookingEnabled, (v) {
                _prefs.setBooking(v);
                setState(() {});
              }),
              _switchTile(
                  'Perubahan Penerbangan',
                  'Info delay/reschedule jadwal (Fase 2)',
                  _prefs.flightEnabled, (v) {
                _prefs.setFlight(v);
                setState(() {});
              }),
            ]),
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
                          'Notifikasi yang dinonaktifkan tidak akan muncul di menu Alerts maupun sebagai notifikasi melayang.',
                          style: TextStyle(fontSize: 11))),
                ],
              ),
            ),
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
