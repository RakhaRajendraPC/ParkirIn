// lib/widgets/stub_icon.dart
import 'package:flutter/material.dart';

/// Ikon "stub" — kotak dengan satu sudut dipotong miring, meniru gunting
/// di ujung tiket boarding pass. Dipakai di seluruh card sebagai identitas
/// visual yang konsisten, menggantikan pola lingkaran ikon generik.
class StubIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool onWhiteBase;

  const StubIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.onWhiteBase = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _StubClipper(),
      child: Container(
        width: size,
        height: size,
        color: onWhiteBase ? Colors.white : color,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 2, right: 2),
        child: Icon(icon,
            color: onWhiteBase ? color : Colors.white, size: size * 0.44),
      ),
    );
  }
}

class _StubClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final cut = size.width * 0.22;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Label kategori bergaya bar-aksen (garis vertikal + teks bold, tanpa
/// background pill) — dipakai berulang di notifikasi & card lain.
class BarAccentLabel extends StatelessWidget {
  final String text;
  final Color color;

  const BarAccentLabel({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 3, height: 11, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.6),
        ),
      ],
    );
  }
}

/// Panah navigasi diagonal minimal, menggantikan chevron_right generik.
class LinkArrow extends StatelessWidget {
  final Color color;

  const LinkArrow({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.north_east_rounded, size: 16, color: color);
  }
}

/// Garis perforasi putus-putus horizontal, meniru sobekan tiket.
class PerforationDivider extends StatelessWidget {
  final Color color;

  const PerforationDivider({super.key, this.color = const Color(0xFFE5E7EB)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: CustomPaint(painter: _DashPainter(color: color)),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
