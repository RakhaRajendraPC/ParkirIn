import 'package:flutter/material.dart';

/// Codepoints from the bundled Material Symbols Rounded variable font
/// (assets/fonts/MaterialSymbolsRounded.ttf), looked up from Google's
/// published `MaterialSymbolsRounded[FILL,GRAD,opsz,wght].codepoints`.
/// Only the glyphs actually used on the Home/Search Results redesign are
/// listed here — add more as needed rather than pulling in the full set.
class MSymbols {
  MSymbols._();

  static const int arrowBack = 0xe5c4;
  static const int search = 0xef7a;
  static const int localParking = 0xe54f;
  static const int verified = 0xef76;
  static const int flightTakeoff = 0xe905;
  static const int flightLand = 0xe904;
  static const int northEast = 0xf1e1;
  static const int verifiedUser = 0xf013;
  static const int payments = 0xef63;
  static const int directionsBusFilled = 0xeff6;
  static const int localTaxi = 0xe559;
  static const int accessible = 0xe914;
  static const int tune = 0xe429;
  static const int map = 0xe55b;
  static const int star = 0xf09a;
  static const int directionsCar = 0xeff7;
  static const int favorite = 0xe87e;
  static const int localOffer = 0xf05b;
  static const int notifications = 0xe7f5;
  static const int confirmationNumber = 0xe638;
  static const int person = 0xf0d3;
}

/// Renders a single glyph from the bundled Material Symbols Rounded
/// variable font (axes: FILL, GRAD, opsz, wght) — scoped to the
/// Home/Search Results redesign. Other screens keep using the classic
/// `Icon(Icons.*)` set from Flutter's built-in Material Icons; this widget
/// is not a replacement for [Icon] app-wide.
class MaterialSymbol extends StatelessWidget {
  final int codepoint;
  final double size;
  final Color color;
  final double weight;
  final bool filled;

  const MaterialSymbol(
    this.codepoint, {
    super.key,
    this.size = 20,
    required this.color,
    this.weight = 300,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      String.fromCharCode(codepoint),
      style: TextStyle(
        fontFamily: 'Material Symbols Rounded',
        fontSize: size,
        color: color,
        height: 1,
        fontVariations: [
          FontVariation('FILL', filled ? 1 : 0),
          FontVariation('wght', weight),
          FontVariation('opsz', size.clamp(20, 48)),
          const FontVariation('GRAD', 0),
        ],
      ),
    );
  }
}
