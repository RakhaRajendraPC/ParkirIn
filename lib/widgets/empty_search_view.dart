import 'package:flutter/material.dart';

class EmptySearchView extends StatelessWidget {
  final VoidCallback onResetFilter;
  final String? message;

  const EmptySearchView({super.key, required this.onResetFilter, this.message});

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
                  color: primaryBlue.withOpacity(0.06), shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded,
                  size: 40, color: primaryBlue),
            ),
            const SizedBox(height: 16),
            const Text('Tidak Ada Slot Parkir Ditemukan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              message ?? 'Coba ubah filter, tanggal, atau bandara tujuan Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onResetFilter,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Reset Filter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: const BorderSide(color: primaryBlue),
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
