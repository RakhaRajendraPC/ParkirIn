// lib/widgets/network_error_view.dart
import 'package:flutter/material.dart';

/// Widget reusable untuk ditampilkan saat request gagal karena koneksi
/// (mis. hasil pencarian gagal load, riwayat booking gagal fetch, dsb).
/// Pakai di dalam body Scaffold mana pun yang butuh retry state.
class NetworkErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const NetworkErrorView({super.key, required this.onRetry, this.message});

  static const Color primaryBlue = Color(0xFF1E5EFF);

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
                  color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.wifi_off_rounded,
                  size: 40, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            const Text('Tidak Ada Koneksi Internet',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                  backgroundColor: primaryBlue,
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
