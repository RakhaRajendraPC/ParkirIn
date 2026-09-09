import 'package:flutter/material.dart';
import '../services/app_settings.dart';

/// Severity levels shared by every alert surface (AppSheet, AppToast, and
/// persistent banners like NetworkErrorView/SlotLockBanner) so they all
/// pull from the same color logic instead of each file picking its own
/// red/blue/green.
enum AppSeverity { neutral, warning, destructive, success }

/// Pengganti pola `static const Color primaryBlue = Color(0xFF1E5EFF);`
/// yang selama ini hardcode di tiap layar. Dengan helper ini, warna
/// brand ikut berubah saat toggle Kontras Tinggi diaktifkan, tanpa
/// perlu context (karena AppSettings singleton ChangeNotifier).
class AppColors {
  static Color get primary => AppSettings.instance.highContrast
      ? const Color(0xFF0033CC)
      : const Color(0xFF1E5EFF);

  static Color get primaryLight => primary.withOpacity(0.1);

  /// Time-sensitive / urgency states (slot-lock countdown, non-free
  /// cancellation window, etc.) — never used for pure destructive actions.
  static const Color warningOrange = Color(0xFFFF8A00);

  /// Reserved for irreversible, high-consequence actions only (delete
  /// account, cancel booking, SOS) — not used for validation errors or
  /// generic failures, which use [warningOrange] instead.
  static const Color danger = Color(0xFFD92D20);

  /// Success toasts / positive confirmations only.
  static const Color success = Color(0xFF16A34A);

  /// Neutral surface for breakdown/line-item cards inside AppSheet.
  static const Color surface1 = Color(0xFFF3F4F6);

  /// Drag-handle / strong-border gray used across sheets and toasts.
  static const Color borderStrong = Color(0xFFD0D5DD);

  // Home / Search Results design-sync tokens (target: Parkirin Home /
  // Search Results canvas files) — additive only, not used outside those
  // two screens yet.
  static const Color ink = Color(0xFF0D2A45);
  static const Color body = Color(0xFF5F6979);
  static const Color label = Color(0xFF5D6779);
  static const Color inactiveNav = Color(0xFF667283);
  static const Color hairline = Color(0xFFD8DCE4);
  static const Color paper = Color(0xFFFCFCFB);
  static const Color canvas = Color(0xFFF4F5F7);

  static Color forSeverity(AppSeverity severity) {
    switch (severity) {
      case AppSeverity.neutral:
        return primary;
      case AppSeverity.warning:
        return warningOrange;
      case AppSeverity.destructive:
        return danger;
      case AppSeverity.success:
        return success;
    }
  }
}
