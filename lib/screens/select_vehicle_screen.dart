import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../models/parking_slot_model.dart';
import '../services/api_exception.dart';
import '../services/slot_lock_service.dart';
import '../services/user_session.dart';
import '../services/vehicles_api_service.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/slot_lock_banner.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_toast.dart';
import 'booking_summary_screen.dart';
import 'vehicles_screen.dart';

class SelectVehicleScreen extends StatefulWidget {
  final ParkingLocation location;
  final DateTime checkIn;
  final DateTime checkOut;
  final ParkingSlot selectedSlot;

  const SelectVehicleScreen({
    super.key,
    required this.location,
    required this.checkIn,
    required this.checkOut,
    required this.selectedSlot,
  });

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  final UserSession _session = UserSession.instance;
  final _vehiclesApiService = VehiclesApiService();

  List<SavedVehicle> _vehicles = [];
  bool _isLoading = true;
  SavedVehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    // Fires whenever this screen leaves the stack for any reason: the user
    // backs out to re-pick a slot (the actual bug this fixes — the old
    // slot's lock would otherwise linger until its TTL expired), the
    // successful-payment flow's pushAndRemoveUntil sweeps it away (lock
    // already released by then, so this safely no-ops), or the 409-conflict
    // handler pops it (lock already invalid, also a no-op). Fire-and-forget
    // — dispose() can't be async.
    SlotLockService.instance.release();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  SavedVehicle? _defaultOf(List<SavedVehicle> vehicles) {
    if (vehicles.isEmpty) return null;
    return vehicles
        .firstWhere((v) => v.isDefault, orElse: () => vehicles.first);
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _vehiclesApiService.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
        // Keep the current selection if it still exists, otherwise fall
        // back to the default vehicle.
        final stillExists =
            vehicles.any((v) => v.id == _selectedVehicle?.id);
        _selectedVehicle =
            stillExists ? _selectedVehicle : _defaultOf(vehicles);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    }
  }

  Future<void> _goToVehiclesScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VehiclesScreen()),
    );
    if (!mounted) return;
    await _loadVehicles();
  }

  void _continue() {
    if (_selectedVehicle == null) return;
    final v = _selectedVehicle!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSummaryScreen(
          location: widget.location,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          selectedSlot: widget.selectedSlot,
          driverName: _session.name,
          driverPhone: _session.phone,
          vehicleId: v.id,
          vehiclePlate: v.plate,
          vehicleBrand: v.brand,
          vehicleType: v.type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.selectedSlot;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.t('vehicle_appbar_title'),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SlotLockBanner(
              onExpired: () {
                showAppSheet(
                  context,
                  severity: AppSeverity.warning,
                  icon: Icons.timer_off_outlined,
                  title: AppStrings.t('vehicle_lock_expired_title'),
                  body: AppStrings.t('vehicle_lock_expired_msg'),
                  barrierDismissible: false,
                  primaryLabel: AppStrings.t('vehicle_back_home_btn'),
                  onPrimary: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: slot.tierColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_parking, color: slot.tierColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${AppStrings.t('vehicle_slot_prefix')} ${slot.code} · ${slot.tierLabel} · ${CurrencyFormatter.rupiah(slot.price)}${AppStrings.t('vehicle_per_malam')}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/100?img=12'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _session.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _session.phone,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.verified, size: 16, color: Colors.green.shade600),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.t('vehicle_pilih_title'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _goToVehiclesScreen,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(AppStrings.t('vehicle_tambah_btn'),
                      style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_vehicles.isEmpty)
              _buildEmptyVehicleState()
            else
              ..._vehicles.map(
                (v) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildVehicleTile(v),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedVehicle == null ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.t('vehicle_lanjut_btn'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTile(SavedVehicle v) {
    final selected = _selectedVehicle?.id == v.id;
    return InkWell(
      onTap: () => setState(() => _selectedVehicle = v),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Radio<String>(
              value: v.id,
              groupValue: _selectedVehicle?.id,
              onChanged: (_) => setState(() => _selectedVehicle = v),
              activeColor: AppColors.primary,
            ),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_filled,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        v.plate,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (v.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppStrings.t('vehicle_utama_badge'),
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${v.brand} · ${v.type}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVehicleState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 36,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.t('vehicle_empty_title'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _goToVehiclesScreen,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
            child: Text(AppStrings.t('vehicle_empty_btn'),
                style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
