import 'package:flutter/material.dart';
import '../services/app_settings.dart';

/// Small "Segera Hadir" pill — the same disabled-tile treatment first used
/// for QRIS/E-Wallet in BookingSummaryScreen, reused wherever an action
/// exists in the UI but isn't wired to a real backend endpoint yet.
class ComingSoonBadge extends StatelessWidget {
  const ComingSoonBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        AppStrings.t('summary_method_coming_soon_badge'),
        style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
      ),
    );
  }
}
