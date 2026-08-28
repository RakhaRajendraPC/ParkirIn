// lib/widgets/app_toast.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Shared animated frame behind every top-anchored transient surface in the
/// app: [showAppToast] (plain severity-coded messages, replacing
/// ScaffoldMessenger SnackBars) and NotificationBannerHost (richer
/// notification banners). Keeping the motion/dismiss mechanics here means
/// both surfaces enter, exit, and auto-dismiss identically instead of each
/// reinventing its own animation.
class AnimatedToastFrame extends StatefulWidget {
  final Widget content;
  final Duration duration;
  final VoidCallback onDismissed;
  final VoidCallback? onTap;
  final Color accentColor;
  final bool showProgress;
  final bool showCloseButton;

  const AnimatedToastFrame({
    super.key,
    required this.content,
    required this.duration,
    required this.onDismissed,
    required this.accentColor,
    this.onTap,
    this.showProgress = true,
    this.showCloseButton = false,
  });

  @override
  State<AnimatedToastFrame> createState() => _AnimatedToastFrameState();
}

class _AnimatedToastFrameState extends State<AnimatedToastFrame>
    with TickerProviderStateMixin {
  late final AnimationController _motion;
  late final AnimationController _progress;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _progress = AnimationController(vsync: this, duration: widget.duration);
    _motion.forward();
    _progress.forward();
    _progress.addStatusListener((status) {
      if (status == AnimationStatus.completed) _dismiss();
    });
  }

  void _dismiss() {
    if (_dismissing) return;
    _dismissing = true;
    _progress.stop();
    _motion.reverse().whenComplete(widget.onDismissed);
  }

  @override
  void dispose() {
    _motion.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _motion, curve: Curves.decelerate);
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap == null
                  ? null
                  : () {
                      widget.onTap!();
                      _dismiss();
                    },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < 0) {
                  _dismiss();
                }
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: widget.content),
                          if (widget.showCloseButton)
                            IconButton(
                              onPressed: _dismiss,
                              icon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                    if (widget.showProgress)
                      AnimatedBuilder(
                        animation: _progress,
                        builder: (context, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (1 - _progress.value).clamp(0.0, 1.0),
                            child: Container(
                              height: 2.5,
                              color: widget.accentColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconForSeverity(AppSeverity severity) {
  switch (severity) {
    case AppSeverity.success:
      return Icons.check_circle;
    case AppSeverity.warning:
      return Icons.warning_amber_rounded;
    case AppSeverity.destructive:
      return Icons.error;
    case AppSeverity.neutral:
      return Icons.info;
  }
}

/// Shows a top-anchored, severity-coded transient message. Replaces every
/// `ScaffoldMessenger.of(context).showSnackBar(...)` call in the app with a
/// consistent surface that carries a visible accent color, an icon, and a
/// countdown progress bar instead of a silent fixed-duration timer.
void showAppToast(
  BuildContext context, {
  required AppSeverity severity,
  required String message,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  final color = AppColors.forSeverity(severity);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => AnimatedToastFrame(
      accentColor: color,
      duration: duration,
      onDismissed: () {
        if (entry.mounted) entry.remove();
      },
      content: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(icon ?? _iconForSeverity(severity), color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  overlay.insert(entry);
}
