import 'package:flutter/material.dart';

enum SlotAvailability { available, occupied }

enum SlotTier { premium, standard, economy }

class ParkingSlot {
  final String code;
  final String rowLabel;
  final int col;
  final double distanceFromEntrance;
  final double price;
  final SlotAvailability availability;

  const ParkingSlot({
    required this.code,
    required this.rowLabel,
    required this.col,
    required this.distanceFromEntrance,
    required this.price,
    required this.availability,
  });

  SlotTier get tier {
    if (distanceFromEntrance < 20) return SlotTier.premium;
    if (distanceFromEntrance < 45) return SlotTier.standard;
    return SlotTier.economy;
  }

  Color get tierColor {
    switch (tier) {
      case SlotTier.premium:
        return const Color(0xFFFFB800);
      case SlotTier.standard:
        return const Color(0xFF1E5EFF);
      case SlotTier.economy:
        return const Color(0xFF2FAE60);
    }
  }

  String get tierLabel {
    switch (tier) {
      case SlotTier.premium:
        return 'Premium';
      case SlotTier.standard:
        return 'Standar';
      case SlotTier.economy:
        return 'Ekonomis';
    }
  }
}

class ParkingRow {
  final String label;
  final List<ParkingSlot> leftBlock;
  final List<ParkingSlot> rightBlock;

  const ParkingRow(
      {required this.label, required this.leftBlock, required this.rightBlock});
}

class ParkingSlotGenerator {
  static List<ParkingRow> generate({
    required double basePrice,
    int totalRows = 4,
    int leftCols = 8,
    int rightCols = 4,
  }) {
    final List<ParkingRow> rows = [];
    final rowLabels =
        List.generate(totalRows, (i) => String.fromCharCode(65 + i));

    for (int r = 0; r < totalRows; r++) {
      final distance = (r * 18) + 10.0;

      double multiplier;
      if (distance < 20) {
        multiplier = 1.35;
      } else if (distance < 45) {
        multiplier = 1.10;
      } else {
        multiplier = 0.85;
      }
      final price = (basePrice * multiplier / 1000).round() * 1000.0;

      List<ParkingSlot> buildBlock(int cols, int colOffset) {
        return List.generate(cols, (c) {
          final code = '${rowLabels[r]}${c + 1 + colOffset}';
          final seed = r * (leftCols + rightCols) + c + colOffset;
          final isOccupied =
              seed % 7 == 0 || (r == 1 && c == 2 && colOffset == 0);
          return ParkingSlot(
            code: code,
            rowLabel: rowLabels[r],
            col: c + colOffset,
            distanceFromEntrance: distance,
            price: price,
            availability: isOccupied
                ? SlotAvailability.occupied
                : SlotAvailability.available,
          );
        });
      }

      rows.add(ParkingRow(
        label: rowLabels[r],
        leftBlock: buildBlock(leftCols, 0),
        rightBlock: buildBlock(rightCols, leftCols),
      ));
    }
    return rows;
  }
}
