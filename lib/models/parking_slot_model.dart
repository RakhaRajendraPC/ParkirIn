import 'package:flutter/material.dart';

/// 'locked' means someone else has an active, time-limited hold on the slot
/// mid-booking (not yet paid) — distinct from 'occupied' (a parked vehicle)
/// and 'outOfService' (closed for maintenance by the operator).
enum SlotAvailability { available, locked, occupied, outOfService }

enum SlotTier { premium, standard, economy }

class ParkingSlot {
  final String id;
  final String code;
  final String rowLabel;
  final int col;
  final double distanceFromEntrance;
  final double price;
  final SlotTier tier;
  final SlotAvailability availability;

  const ParkingSlot({
    this.id = '',
    required this.code,
    required this.rowLabel,
    required this.col,
    required this.distanceFromEntrance,
    required this.price,
    required this.tier,
    required this.availability,
  });

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

  /// Maps a `/locations/:id/slots` JSON object to this model. The backend
  /// doesn't return a per-slot price — only the location's starting price —
  /// so it's derived the same way the old mock data did: a tier multiplier
  /// applied to [basePrice].
  factory ParkingSlot.fromApi(
    Map<String, dynamic> json, {
    required double basePrice,
  }) {
    final tier = _tierFromApi(json['tier'] as String);
    return ParkingSlot(
      id: json['id'] as String,
      code: json['code'] as String,
      rowLabel: json['rowLabel'] as String,
      col: json['col'] as int,
      distanceFromEntrance: (json['distanceFromEntrance'] as num).toDouble(),
      price: _priceForTier(tier, basePrice),
      tier: tier,
      availability: _availabilityFromApi(json['status'] as String),
    );
  }

  static SlotTier _tierFromApi(String raw) {
    switch (raw) {
      case 'premium':
        return SlotTier.premium;
      case 'standard':
        return SlotTier.standard;
      default:
        return SlotTier.economy;
    }
  }

  static SlotAvailability _availabilityFromApi(String raw) {
    switch (raw) {
      case 'available':
        return SlotAvailability.available;
      case 'locked':
        return SlotAvailability.locked;
      case 'occupied':
        return SlotAvailability.occupied;
      default:
        return SlotAvailability.outOfService;
    }
  }

  static double _priceForTier(SlotTier tier, double basePrice) {
    final double multiplier;
    switch (tier) {
      case SlotTier.premium:
        multiplier = 1.35;
        break;
      case SlotTier.standard:
        multiplier = 1.10;
        break;
      case SlotTier.economy:
        multiplier = 0.85;
        break;
    }
    return (basePrice * multiplier / 1000).round() * 1000.0;
  }
}

class ParkingRow {
  final String label;
  final List<List<ParkingSlot>> blocks;

  const ParkingRow({required this.label, required this.blocks});
}

class ParkingSlotGenerator {
  /// Groups a flat, already row/col-sorted slot list (as returned by
  /// `/locations/:id/slots`) into [ParkingRow]s for the slot map grid. The
  /// backend doesn't provide sub-row block boundaries, so each row renders
  /// as a single block.
  static List<ParkingRow> groupByRow(List<ParkingSlot> slots) {
    final Map<String, List<ParkingSlot>> byRow = {};
    for (final slot in slots) {
      byRow.putIfAbsent(slot.rowLabel, () => []).add(slot);
    }
    return byRow.entries
        .map((e) => ParkingRow(label: e.key, blocks: [e.value]))
        .toList();
  }

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
