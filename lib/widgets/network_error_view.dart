import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Widget reusable untuk ditampilkan saat request gagal karena koneksi
/// (mis. hasil pencarian gagal load, riwayat booking gagal fetch, dsb).
/// Pakai di dalam body Scaffold mana pun yang butuh retry state.
///
/// Icon area uses the shared warning color (recoverable-failure severity)
/// so this reads as part of the same alert system as AppSheet/AppToast.
class NetworkErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  final String? title;
  final IconData? icon;

  const NetworkErrorView({
    super.key,
    required this.onRetry,
    this.message,
    this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.warningOrange.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(icon ?? Icons.wifi_off_rounded,
                  size: 40, color: AppColors.warningOrange),
            ),
            const SizedBox(height: 16),
            Text(title ?? 'Tidak Ada Koneksi Internet',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              message ?? 'Periksa koneksi internet Anda dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
