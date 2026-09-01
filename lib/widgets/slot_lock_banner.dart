import 'dart:async';
import 'package:flutter/material.dart';
import '../services/slot_lock_service.dart';
import '../utils/app_colors.dart';

/// Banner countdown yang ditampilkan di halaman Pilih Kendaraan dan
/// Ringkasan & Pembayaran, mengingatkan user berapa lama slot masih
/// dikunci untuknya. Memanggil [onExpired] sekali saat waktu habis.
///
/// Uses the shared severity colors: warning while there's still time,
/// escalating to danger under 2 minutes remaining.
class SlotLockBanner extends StatefulWidget {
  final VoidCallback onExpired;

  const SlotLockBanner({super.key, required this.onExpired});

  @override
  State<SlotLockBanner> createState() => _SlotLockBannerState();
}

class _SlotLockBannerState extends State<SlotLockBanner> {
  late StreamSubscription<Duration> _sub;
  Duration _remaining = SlotLockService.instance.remaining;
  bool _hasExpired = false;

  @override
  void initState() {
    super.initState();
    _sub = SlotLockService.instance.countdown.listen((d) {
      if (!mounted) return;
      setState(() => _remaining = d);
      if (d == Duration.zero && !_hasExpired) {
        _hasExpired = true;
        widget.onExpired();
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _remaining.inMinutes < 2;
    final color = isUrgent ? AppColors.danger : AppColors.warningOrange;
    final m = _remaining.inMinutes;
    final s = _remaining.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Slot ini dikunci untuk Anda selama ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUrgent ? color : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
