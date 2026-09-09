import 'package:flutter/material.dart';
import '../widgets/stub_icon.dart';

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
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const StubIcon(
                  icon: Icons.notifications_active_rounded,
                  color: primaryBlue,
                  size: 84),
              const SizedBox(height: 26),
              const Text(
                'Aktifkan Notifikasi',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16181F),
                    letterSpacing: -0.3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Kami akan mengingatkan Anda soal jadwal check-in, posisi shuttle, dan peringatan biaya tambahan agar tidak ada yang terlewat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5, color: Colors.grey.shade600, height: 1.55),
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _benefitRow(Icons.event_available_rounded,
                        'Reminder H-1 sebelum check-in'),
                    const SizedBox(height: 12),
                    _benefitRow(Icons.directions_bus_filled_rounded,
                        'Update posisi shuttle real-time'),
                    const SizedBox(height: 12),
                    _benefitRow(Icons.warning_amber_rounded,
                        'Peringatan sebelum biaya overstay berlaku'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('AKTIFKAN NOTIFIKASI',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          letterSpacing: 0.4)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onContinue,
                child: Text('Nanti Saja',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StubIcon(icon: icon, color: primaryBlue, size: 34),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16181F))),
        ),
      ],
    );
  }
}
