import 'package:flutter/material.dart';
import '../services/api_exception.dart';
import '../services/app_settings.dart';
import '../services/user_session.dart';
import '../services/vehicles_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_toast.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final _vehiclesApiService = VehiclesApiService();

  List<SavedVehicle> _vehicles = [];
  bool _isLoading = true;
  String? _busyVehicleId;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
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

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _vehiclesApiService.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    }
  }

  Future<void> _setDefault(String id) async {
    setState(() => _busyVehicleId = id);
    try {
      await _vehiclesApiService.setDefaultVehicle(id);
      await _loadVehicles();
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    } finally {
      if (mounted) setState(() => _busyVehicleId = null);
    }
  }

  Future<void> _remove(String id) async {
    setState(() => _busyVehicleId = id);
    try {
      await _vehiclesApiService.deleteVehicle(id);
      await _loadVehicles();
    } on ApiException catch (e) {
      // e.g. "Cannot delete a vehicle with existing bookings" — the
      // backend's real message, shown as-is.
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    } finally {
      if (mounted) setState(() => _busyVehicleId = null);
    }
  }

  void _showAddDialog() {
    final plateCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.t('vehicles_dialog_title'),
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                  controller: plateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                      labelText: AppStrings.t('vehicles_plat_nomor'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 12),
              TextField(
                  controller: brandCtrl,
                  decoration: InputDecoration(
                      labelText: AppStrings.t('vehicles_merek_model'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: typeCtrl,
                          decoration: InputDecoration(
                              labelText: AppStrings.t('vehicles_tipe'),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextField(
                          controller: colorCtrl,
                          decoration: InputDecoration(
                              labelText: AppStrings.t('vehicles_warna'),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))))),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (plateCtrl.text.trim().isEmpty) return;
                          setSheetState(() => isSubmitting = true);
                          try {
                            await _vehiclesApiService.createVehicle(
                              plate: plateCtrl.text.trim(),
                              brand: brandCtrl.text.trim(),
                              type: typeCtrl.text.trim(),
                              color: colorCtrl.text.trim(),
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            await _loadVehicles();
                          } on ApiException catch (e) {
                            setSheetState(() => isSubmitting = false);
                            if (!context.mounted) return;
                            showAppToast(context,
                                severity: AppSeverity.destructive,
                                message: e.message);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(AppStrings.t('vehicles_simpan_btn')),
                ),
              ),
            ],
          ),
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
          title: Text(AppStrings.t('vehicles_appbar_title'),
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ..._vehicles.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCard(v),
                      )),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppStrings.t('vehicles_tambah_btn')),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard(SavedVehicle v) {
    final isBusy = _busyVehicleId == v.id;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: v.isDefault ? Border.all(color: AppColors.primary) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(Icons.directions_car_filled, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(v.plate,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    if (v.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(AppStrings.t('vehicles_utama_badge'),
                            style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  [v.brand, v.type, v.color]
                      .where((e) => e.isNotEmpty)
                      .join(' · '),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (isBusy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black38),
              onSelected: (val) {
                if (val == 'default') _setDefault(v.id);
                if (val == 'remove') _remove(v.id);
              },
              itemBuilder: (context) => [
                if (!v.isDefault)
                  PopupMenuItem(
                      value: 'default',
                      child: Text(AppStrings.t('vehicles_jadikan_utama'),
                          style: const TextStyle(fontSize: 13))),
                PopupMenuItem(
                    value: 'remove',
                    child: Text(AppStrings.t('vehicles_hapus'),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.redAccent))),
              ],
            ),
        ],
      ),
    );
  }
}
