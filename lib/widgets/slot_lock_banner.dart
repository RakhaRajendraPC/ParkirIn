import 'dart:async';
import 'package:flutter/material.dart';
import '../services/slot_lock_service.dart';

class SlotLockBanner extends StatefulWidget {
  final VoidCallback onExpired;

  const SlotLockBanner({super.key, required this.onExpired});

  @override
  State<SlotLockBanner> createState() => _SlotLockBannerState();
}

class _SlotLockBannerState extends State<SlotLockBanner> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
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
    final m = _remaining.inMinutes;
    final s = _remaining.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withOpacity(0.08)
            : primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined,
              size: 18, color: isUrgent ? Colors.redAccent : primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Slot ini dikunci untuk Anda selama ${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUrgent ? Colors.redAccent : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
