// lib/widgets/quick_extend_sheet.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';

/// Bottom sheet ringan untuk menambah durasi booking aktif tanpa masuk
/// ke alur reschedule lengkap (tanggal baru, dsb) — cukup pilih tambahan
/// malam, sistem hitung biaya tambahan, konfirmasi sekali tap.
class QuickExtendSheet extends StatefulWidget {
  final BookingModel booking;

  const QuickExtendSheet({super.key, required this.booking});

  static Future<int?> show(BuildContext context, BookingModel booking) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => QuickExtendSheet(booking: booking),
    );
  }

  @override
  State<QuickExtendSheet> createState() => _QuickExtendSheetState();
}

class _QuickExtendSheetState extends State<QuickExtendSheet> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  int _extraNights = 1;

  double get _extraCost => widget.booking.basePrice * _extraNights;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Perpanjang Durasi Parkir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Kode booking: ${widget.booking.bookingCode}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          const Text('Tambah berapa malam?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              _stepperButton(Icons.remove, () {
                if (_extraNights > 1) setState(() => _extraNights--);
              }),
              Expanded(
                child: Center(
                  child: Text('$_extraNights malam',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              _stepperButton(Icons.add, () => setState(() => _extraNights++)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Biaya Tambahan', style: TextStyle(fontSize: 13)),
                Text('Rp ${_extraCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _extraNights),
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Bayar & Perpanjang',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration:
            BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
