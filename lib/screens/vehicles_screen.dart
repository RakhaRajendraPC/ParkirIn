import 'package:flutter/material.dart';
import '../services/user_session.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final UserSession _session = UserSession.instance;

  void _setDefault(String id) => setState(() => _session.setDefaultVehicle(id));
  void _remove(String id) => setState(() => _session.removeVehicle(id));

  void _showAddDialog() {
    final plateCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final colorCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Kendaraan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
                controller: plateCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                    labelText: 'Plat Nomor',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            TextField(
                controller: brandCtrl,
                decoration: InputDecoration(
                    labelText: 'Merek & Model',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: typeCtrl,
                        decoration: InputDecoration(
                            labelText: 'Tipe (SUV/MPV)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: colorCtrl,
                        decoration: InputDecoration(
                            labelText: 'Warna',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  if (plateCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _session.addVehicle(SavedVehicle(
                      id: 'v${DateTime.now().millisecondsSinceEpoch}',
                      plate: plateCtrl.text.trim(),
                      brand: brandCtrl.text.trim(),
                      type: typeCtrl.text.trim(),
                      color: colorCtrl.text.trim(),
                    ));
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Simpan Kendaraan'),
              ),
            ),
          ],
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
          title: const Text('Kendaraan Saya',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._session.vehicles.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCard(v),
                )),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Kendaraan'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(color: primaryBlue),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: v.isDefault ? Border.all(color: primaryBlue) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.directions_car_filled, color: primaryBlue),
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
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('UTAMA',
                            style: TextStyle(
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black38),
            onSelected: (val) {
              if (val == 'default') _setDefault(v.id);
              if (val == 'remove') _remove(v.id);
            },
            itemBuilder: (context) => [
              if (!v.isDefault)
                const PopupMenuItem(
                    value: 'default',
                    child:
                        Text('Jadikan Utama', style: TextStyle(fontSize: 13))),
              const PopupMenuItem(
                  value: 'remove',
                  child: Text('Hapus',
                      style: TextStyle(fontSize: 13, color: Colors.redAccent))),
            ],
          ),
        ],
      ),
    );
  }
}
