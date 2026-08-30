// lib/models/parking_slot_model.dart
import 'package:flutter/material.dart';

enum SlotAvailability { available, occupied }

enum SlotTier { premium, standard, economy }

class ParkingSlot {
  final String code; // contoh: A1, A2, B15, dst
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

/// Satu baris parkir, terdiri dari beberapa blok slot (mis. 3 blok)
/// yang dipisah "Akses Jalan" vertikal di dalam baris itu sendiri —
/// sesuai denah lahan parkir sungguhan yang lebar.
class ParkingRow {
  final String label; // A, B, C, D, ...
  final List<List<ParkingSlot>> blocks;

  const ParkingRow({required this.label, required this.blocks});
}

/// Generator layout parkir sesuai denah asli:
/// - Tiap baris terdiri dari beberapa blok (dipisah Akses Jalan vertikal).
/// - Baris disusun berkelompok: baris pertama berdiri sendiri (menempel
///   tembok/batas atas), lalu 2 baris berikutnya saling membelakangi
///   tanpa jarak (dempet), diulang seterusnya — pola [1, 2, 2, 1, 2, 2, ...].
/// - "Akses Jalan" horizontal hanya muncul di ANTARA kelompok baris,
///   bukan di antara 2 baris yang saling membelakangi.
class ParkingSlotGenerator {
  static List<ParkingRow> generate({
    required double basePrice,
    int totalRows = 6,
    int blocksPerRow = 3,
    int colsPerBlock = 8,
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

      final List<List<ParkingSlot>> blocks = [];
      int slotCounter = 1;
      for (int b = 0; b < blocksPerRow; b++) {
        final blockSlots = List.generate(colsPerBlock, (c) {
          final code = '${rowLabels[r]}$slotCounter';
          final seed =
              r * (blocksPerRow * colsPerBlock) + (b * colsPerBlock) + c;
          final isOccupied = seed % 7 == 0 || (r == 1 && b == 1 && c == 2);
          slotCounter++;
          return ParkingSlot(
            code: code,
            rowLabel: rowLabels[r],
            col: b * colsPerBlock + c,
            distanceFromEntrance: distance,
            price: price,
            availability: isOccupied
                ? SlotAvailability.occupied
                : SlotAvailability.available,
          );
        });
        blocks.add(blockSlots);
      }

      rows.add(ParkingRow(label: rowLabels[r], blocks: blocks));
    }
    return rows;
  }

  /// Mengelompokkan baris sesuai pola denah asli: [1, 2, 2, 1, 2, 2, ...].
  /// Baris pertama tiap siklus berdiri sendiri, dua baris berikutnya
  /// dipasangkan saling membelakangi (dempet, tanpa Akses Jalan di antaranya).
  static List<List<ParkingRow>> groupRows(List<ParkingRow> rows) {
    final List<List<ParkingRow>> groups = [];
    int i = 0;
    int cycleIndex = 0; // 0 = solo, 1 = pasangan pertama, 2 = pasangan kedua
    while (i < rows.length) {
      if (cycleIndex % 3 == 0) {
        groups.add([rows[i]]);
        i += 1;
      } else {
        if (i + 1 < rows.length) {
          groups.add([rows[i], rows[i + 1]]);
          i += 2;
        } else {
          groups.add([rows[i]]);
          i += 1;
        }
      }
      cycleIndex++;
    }
    return groups;
  }
}
