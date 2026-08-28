// lib/screens/referral_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_toast.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static const String referralCode = 'BUDI2026';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Undang Teman',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Icon(Icons.card_giftcard,
                  size: 64, color: AppColors.primary.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            const Text('Ajak Teman, Dapatkan Rp 25.000',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Bagikan kode referral Anda. Teman Anda dapat diskon Rp 25.000 untuk booking pertama, dan Anda mendapat saldo Rp 25.000 setelah booking mereka selesai.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary, style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(referralCode,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                  ),
                  IconButton(
                    onPressed: () {
                      showAppToast(
                        context,
                        severity: AppSeverity.success,
                        message: 'Kode referral disalin',
                      );
                    },
                    icon: Icon(Icons.copy, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Bagikan Kode',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Cara Kerja',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _stepTile('1', 'Bagikan kode referral Anda ke teman'),
            _stepTile('2', 'Teman menggunakan kode saat booking pertama'),
            _stepTile('3',
                'Anda dapat saldo Rp 25.000 setelah booking mereka selesai'),
          ],
        ),
      ),
    );
  }

  Widget _stepTile(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primary,
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
