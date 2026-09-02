import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../models/parking_slot_model.dart';
import '../services/api_exception.dart';
import '../services/app_settings.dart';
import '../services/locations_api_service.dart';
import '../services/slot_lock_service.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_toast.dart';
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
  final LocationsApiService _locationsApi = LocationsApiService();
  List<List<ParkingRow>> _rowGroups = [];
  ParkingSlot? _selected;
  bool _isLoading = true;
  bool _isLocking = false;

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
    _loadSlots();
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSlots() async {
    setState(() => _isLoading = true);
    try {
      final slotJson = await _locationsApi.getLocationSlots(widget.location.id);
      final slots = slotJson
          .map((json) => ParkingSlot.fromApi(
                json,
                basePrice: widget.location.pricePerNight,
              ))
          .toList();
      final rows = ParkingSlotGenerator.groupByRow(slots);
      if (!mounted) return;
      setState(() => _rowGroups = ParkingSlotGenerator.groupRows(rows));
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectSlot(ParkingSlot slot) {
    if (slot.availability != SlotAvailability.available) return;
    setState(() => _selected = slot);
  }

  Future<void> _continue() async {
    final slot = _selected;
    if (slot == null || _isLocking) return;

    setState(() => _isLocking = true);
    try {
      await SlotLockService.instance.lockSlot(
        slot.id,
        widget.checkIn,
        widget.checkOut,
      );
    } on SlotLockConflictException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.warning, message: e.message);
      setState(() {
        _isLocking = false;
        _selected = null;
      });
      // The slot's status changed server-side — refresh so it renders as
      // locked/occupied instead of leaving the stale "available" grid up.
      await _loadSlots();
      return;
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLocking = false);
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
      return;
    }

    if (!mounted) return;
    setState(() => _isLocking = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectVehicleScreen(
          location: widget.location,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          selectedSlot: slot,
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildLegend(),
                  Expanded(
                    child: InteractiveViewer(
                      minScale: 0.5,
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
                onPressed: (_selected == null || _isLocking) ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLocking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
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
          dot(AppColors.warningOrange, AppStrings.t('slot_legend_locked')),
          dot(Colors.blueGrey.shade300,
              AppStrings.t('slot_legend_out_of_service')),
        ],
      ),
    );
  }

  Widget _buildParkingLot() {
    return SizedBox(
      width: 1080,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_rowGroups.length * 2 - 1, (i) {
          if (i.isEven) {
            final group = _rowGroups[i ~/ 2];
            return _buildRowGroup(group);
          } else {
            return _buildHorizontalAksesJalan();
          }
        }),
      ),
    );
  }

  Widget _buildRowGroup(List<ParkingRow> group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: group.map((row) => _buildParkingRow(row)).toList(),
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
          for (int b = 0; b < row.blocks.length; b++) ...[
            Expanded(child: _buildSlotBlock(row.blocks[b])),
            if (b < row.blocks.length - 1) _buildVerticalAksesJalan(),
          ],
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
    final isSelected = _selected?.code == slot.code;

    Color borderColor;
    Color fillColor;
    IconData? icon;
    Color iconColor = Colors.grey.shade400;

    switch (slot.availability) {
      case SlotAvailability.occupied:
        borderColor = Colors.grey.shade300;
        fillColor = Colors.grey.shade100;
        icon = Icons.directions_car;
        break;
      case SlotAvailability.locked:
        // Someone else has an active, time-limited hold on this slot mid-
        // booking — distinct from a parked car (occupied), using the same
        // warning-orange tone as the slot-lock countdown banner elsewhere.
        borderColor = AppColors.warningOrange;
        fillColor = AppColors.warningOrange.withOpacity(0.1);
        icon = Icons.lock_clock_outlined;
        iconColor = AppColors.warningOrange;
        break;
      case SlotAvailability.outOfService:
        borderColor = Colors.blueGrey.shade200;
        fillColor = Colors.blueGrey.shade50;
        icon = Icons.block;
        iconColor = Colors.blueGrey.shade300;
        break;
      case SlotAvailability.available:
        if (isSelected) {
          borderColor = slot.tierColor;
          fillColor = slot.tierColor;
        } else {
          borderColor = slot.tierColor.withOpacity(0.55);
          fillColor = Colors.white;
        }
        break;
    }

    final isAvailable = slot.availability == SlotAvailability.available;

    return InkWell(
      onTap: isAvailable ? () => _selectSlot(slot) : null,
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
        child: icon != null
            ? Icon(icon, size: 16, color: iconColor)
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
