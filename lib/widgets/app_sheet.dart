// lib/widgets/app_sheet.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// One line item inside an [AppSheet]'s breakdown card, e.g. a cost
/// breakdown for a non-free cancellation. Set [isTotal] on the final row
/// to render it bold with a divider above it.
class AppSheetBreakdownItem {
  final String label;
  final String value;
  final bool isTotal;

  const AppSheetBreakdownItem({
    required this.label,
    required this.value,
    this.isTotal = false,
  });
}

/// The app's single reusable bottom-sheet alert surface (Direction B —
/// "Native Sheet"). Replaces AlertDialog for every blocking confirmation:
/// neutral confirmations, time-sensitive warnings, and destructive actions
/// (optionally with a cost breakdown, e.g. a cancellation fee).
class AppSheet extends StatelessWidget {
  final AppSeverity severity;
  final IconData icon;
  final String title;
  final String? body;
  final List<AppSheetBreakdownItem>? breakdown;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const AppSheet({
    super.key,
    required this.severity,
    required this.icon,
    required this.title,
    this.body,
    this.breakdown,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSeverity(severity);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (body != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    body!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.45,
                    ),
                  ),
                ],
                if (breakdown != null && breakdown!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Breakdown(items: breakdown!),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onPrimary,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        secondaryLabel!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  final List<AppSheetBreakdownItem> items;
  const _Breakdown({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (final item in items) ...[
            if (item.isTotal)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: item.isTotal ? 13 : 12,
                      fontWeight:
                          item.isTotal ? FontWeight.bold : FontWeight.normal,
                      color:
                          item.isTotal ? Colors.black87 : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: item.isTotal ? 13 : 12,
                      fontWeight:
                          item.isTotal ? FontWeight.bold : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows an [AppSheet] as a bottom sheet with an explicit slide-up +
/// backdrop-fade transition (280ms, decelerate) instead of Flutter's
/// default modal-bottom-sheet transition.
///
/// Call sites keep their exact existing button logic — pass the same
/// callback bodies (including any `Navigator.pop`, repository mutation,
/// or toast calls) as [onPrimary]/[onSecondary]; AppSheet does not pop
/// on their behalf.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required AppSeverity severity,
  required IconData icon,
  required String title,
  String? body,
  List<AppSheetBreakdownItem>? breakdown,
  required String primaryLabel,
  required VoidCallback onPrimary,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: title,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return AppSheet(
        severity: severity,
        icon: icon,
        title: title,
        body: body,
        breakdown: breakdown,
        primaryLabel: primaryLabel,
        onPrimary: onPrimary,
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.decelerate,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}
