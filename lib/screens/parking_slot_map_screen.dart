// lib/screens/parking_slot_map_screen.dart
import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../models/parking_slot_model.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'select_vehicle_screen.dart';

class ParkingSlotMapScreen extends StatefulWidget {
  final ParkingLocation location;
  final DateTime checkIn;
  final DateTime checkOut;

  const ParkingSlotMapScreen({
    super.key,
    required this.location,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<ParkingSlotMapScreen> createState() => _ParkingSlotMapScreenState();
}

class _ParkingSlotMapScreenState extends State<ParkingSlotMapScreen> {
  late final List<ParkingRow> _rows;
  ParkingSlot? _selected;

  @override
  void initState() {
    super.initState();
    _rows =
        ParkingSlotGenerator.generate(basePrice: widget.location.pricePerNight);
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _selectSlot(ParkingSlot slot) {
    if (slot.availability == SlotAvailability.occupied) return;
    setState(() => _selected = slot);
  }

  void _continue() {
    if (_selected == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectVehicleScreen(
          location: widget.location,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          selectedSlot: _selected!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.t('slot_map_title'),
                  style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(widget.location.name,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildLegend(),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.6,
                maxScale: 2.5,
                boundaryMargin: const EdgeInsets.all(80),
                constrained: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildParkingLot(),
                ),
              ),
            ),
            if (_selected != null) _buildSelectedPreview(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2))
            ]),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selected == null ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _selected == null
                      ? AppStrings.t('slot_select_first')
                      : '${AppStrings.t('slot_continue_with')} ${_selected!.code}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    Widget dot(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          dot(const Color(0xFFFFB800), AppStrings.t('slot_legend_premium')),
          dot(AppColors.primary, AppStrings.t('slot_legend_standard')),
          dot(const Color(0xFF2FAE60), AppStrings.t('slot_legend_economy')),
          dot(Colors.grey.shade400, AppStrings.t('slot_legend_occupied')),
        ],
      ),
    );
  }

  Widget _buildParkingLot() {
    return SizedBox(
      width: 720,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_rows.length * 2 - 1, (i) {
          if (i.isEven) {
            final row = _rows[i ~/ 2];
            return _buildParkingRow(row);
          } else {
            return _buildHorizontalAksesJalan();
          }
        }),
      ),
    );
  }

  Widget _buildParkingRow(ParkingRow row) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            child: Center(
              child: Text(row.label,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ),
          ),
          Expanded(flex: 2, child: _buildSlotBlock(row.leftBlock)),
          _buildVerticalAksesJalan(),
          Expanded(flex: 1, child: _buildSlotBlock(row.rightBlock)),
        ],
      ),
    );
  }

  Widget _buildSlotBlock(List<ParkingSlot> slots) {
    return Column(
      children: [
        _hatchBar(),
        Row(
            children:
                slots.map((s) => Expanded(child: _buildSlotCell(s))).toList()),
        _hatchBar(),
      ],
    );
  }

  Widget _hatchBar() {
    return SizedBox(
      height: 6,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }

  Widget _buildSlotCell(ParkingSlot slot) {
    final isOccupied = slot.availability == SlotAvailability.occupied;
    final isSelected = _selected?.code == slot.code;

    Color borderColor;
    Color fillColor;
    if (isOccupied) {
      borderColor = Colors.grey.shade300;
      fillColor = Colors.grey.shade100;
    } else if (isSelected) {
      borderColor = slot.tierColor;
      fillColor = slot.tierColor;
    } else {
      borderColor = slot.tierColor.withOpacity(0.55);
      fillColor = Colors.white;
    }

    return InkWell(
      onTap: () => _selectSlot(slot),
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: fillColor,
          border: Border(
            left: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
            right: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
          ),
        ),
        child: isOccupied
            ? Icon(Icons.directions_car, size: 16, color: Colors.grey.shade400)
            : Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  slot.code,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHorizontalAksesJalan() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: Center(
              child: Text(AppStrings.t('slot_akses_jalan'),
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalAksesJalan() {
    return SizedBox(
      width: 44,
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(AppStrings.t('slot_akses_jalan'),
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic)),
        ),
      ),
    );
  }

  Widget _buildSelectedPreview() {
    final slot = _selected!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: slot.tierColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: slot.tierColor.withOpacity(0.15),
                shape: BoxShape.circle),
            child: Icon(Icons.local_parking, color: slot.tierColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Slot ${slot.code}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: slot.tierColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(slot.tierLabel,
                          style: TextStyle(
                              fontSize: 9,
                              color: slot.tierColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(
                    '${AppStrings.t('slot_baris_label')} ${slot.rowLabel} · ± ${slot.distanceFromEntrance.toStringAsFixed(0)} ${AppStrings.t('slot_dari_pintu_masuk')}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(
              '${CurrencyFormatter.rupiah(slot.price)}${AppStrings.t('slot_per_malam')}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: slot.tierColor)),
        ],
      ),
    );
  }
}

/// Garis putus-putus abu-abu tebal, meniru marka batas parkir pada referensi.
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.butt;
    const dashWidth = 10.0;
    const dashSpace = 4.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
