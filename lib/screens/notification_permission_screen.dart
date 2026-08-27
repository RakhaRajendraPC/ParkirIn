// lib/screens/notification_permission_screen.dart
import 'package:flutter/material.dart';

class NotificationPermissionScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const NotificationPermissionScreen({super.key, required this.onContinue});

  static const Color primaryBlue = Color(0xFF1E5EFF);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.08),
                    shape: BoxShape.circle),
                child: const Icon(Icons.notifications_active_outlined,
                    color: primaryBlue, size: 56),
              ),
              const SizedBox(height: 24),
              const Text('Aktifkan Notifikasi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Kami akan mengingatkan Anda soal jadwal check-in, posisi shuttle, dan peringatan biaya tambahan agar tidak ada yang terlewat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 24),
              _benefitRow(
                  Icons.event_available, 'Reminder H-1 sebelum check-in'),
              _benefitRow(Icons.directions_bus_filled,
                  'Update posisi shuttle real-time'),
              _benefitRow(Icons.warning_amber_rounded,
                  'Peringatan sebelum biaya overstay berlaku'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Production: panggil permission_handler / firebase_messaging
                    // requestPermission() di sini sebelum lanjut.
                    onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Aktifkan Notifikasi',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onContinue,
                child: Text('Nanti Saja',
                    style: TextStyle(color: Colors.grey.shade600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 250,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              child: Icon(
                icon,
                size: 24,
                color: primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
