// lib/widgets/hero_banner_carousel.dart
import 'dart:async';
import 'package:flutter/material.dart';

class BannerSlide {
  final String? imagePath;
  final String badgeText;
  final IconData? badgeIcon;
  final String title;
  final String subtitle;
  final Color accent;

  const BannerSlide({
    this.imagePath,
    required this.badgeText,
    this.badgeIcon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

class HeroBannerCarousel extends StatefulWidget {
  final List<BannerSlide> slides;

  /// When true, the banner's bottom corners are squared off so it can
  /// sit flush against a card directly beneath it (e.g. active booking).
  final bool flushBottom;

  const HeroBannerCarousel({
    super.key,
    required this.slides,
    this.flushBottom = false,
  });

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  static const double _bannerHeight = 180;
  static const Duration _autoScrollInterval = Duration(seconds: 6);
  static const Duration _pageAnimDuration = Duration(milliseconds: 600);

  static const double _padH = 18;
  static const double _badgeTop = 14;
  static const double _titleTop = 52;
  static const double _titleBlockH = 62;
  static const double _subtitleTop = _titleTop + _titleBlockH + 4;
  static const double _topRadius = 18;

  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    if (widget.slides.length < 2) return;
    _autoTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.slides.length;
      _controller.animateToPage(
        next,
        duration: _pageAnimDuration,
        curve: Curves.easeInOutQuad,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(_topRadius),
      topRight: const Radius.circular(_topRadius),
      bottomLeft: Radius.circular(widget.flushBottom ? 0 : _topRadius),
      bottomRight: Radius.circular(widget.flushBottom ? 0 : _topRadius),
    );

    return SizedBox(
      height: _bannerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: radius,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) => _buildSlide(widget.slides[i]),
            ),
          ),
          _buildIndicators(),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Positioned(
      bottom: 12,
      right: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.slides.length, (i) {
          final active = i == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(left: 4),
            width: active ? 16 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white.withOpacity(0.45),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSlide(BannerSlide slide) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background
        slide.imagePath != null
            ? Image.asset(
                slide.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackBackground(slide),
              )
            : _buildFallbackBackground(slide),

        // 2. Gradient overlay for legibility
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.68),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // 3. Watermark icon
        if (slide.badgeIcon != null)
          Positioned(
            top: -14,
            right: -14,
            child: Icon(
              slide.badgeIcon,
              size: 108,
              color: Colors.white.withOpacity(0.08),
            ),
          ),

        // 4. Badge — icon in its own square, text in a separate pill
        Positioned(
          top: _badgeTop,
          left: _padH,
          right: _padH,
          child: _buildBadge(slide),
        ),

        // 5. Title
        Positioned(
          top: _titleTop,
          left: _padH,
          right: 56,
          height: _titleBlockH,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              slide.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.14,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),

        // 6. Subtitle — lighter weight, slightly muted
        Positioned(
          top: _subtitleTop,
          left: _padH,
          right: 56,
          bottom: 16,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              slide.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(BannerSlide slide) {
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (slide.badgeIcon != null) ...[
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                slide.badgeIcon,
                size: 13,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 1,
                ),
              ),
              child: Text(
                slide.badgeText.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.92),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBackground(BannerSlide slide) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            slide.accent.withOpacity(0.85),
            slide.accent.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
