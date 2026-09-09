// lib/widgets/parkirin_header_bar.dart
import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'app_logo_badge.dart';

/// Shared header AppBar — logo mark + "Inapandara" wordmark, transparent
/// background, 160px leading width. Reused identically across Home,
/// Bookings, Notifications, and Profile; extracted after that exact block
/// was found copy-pasted across all 4 (and briefly drifted out of sync when
/// the wordmark was added to some but not others).
class ParkirInHeaderBar extends StatelessWidget
    implements PreferredSizeWidget {
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  const ParkirInHeaderBar({super.key, required this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogoBadge(height: 38),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                AppStrings.t('search_appbar_title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.32,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
      leadingWidth: 160,
      title: null,
      centerTitle: true,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
