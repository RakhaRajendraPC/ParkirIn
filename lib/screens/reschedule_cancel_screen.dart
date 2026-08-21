// lib/screens/reschedule_cancel_screen.dart
import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class RescheduleCancelScreen extends StatefulWidget {
  final BookingModel booking;

  const RescheduleCancelScreen({super.key, required this.booking});

  @override
  State<RescheduleCancelScreen> createState() => _RescheduleCancelScreenState();
}

class _RescheduleCancelScreenState extends State<RescheduleCancelScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  late DateTime _newCheckIn;
  late DateTime _newCheckOut;

  bool get _isFreeCancellation =>
      widget.booking.checkIn.difference(DateTime.now()).inHours >= 24;

  @override
  void initState() {
    super.initState();
    _newCheckIn = widget.booking.checkIn;
    _newCheckOut = widget.booking.checkOut;
  }

  String _fmt(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${d.day} ${months[d.month]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn ? _newCheckIn : _newCheckOut;
    final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return;
    setState(() {
      final combined =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isCheckIn) {
        _newCheckIn = combined;
      } else {
        _newCheckOut = combined;
      }
    });
  }

  void _confirmReschedule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Reschedule'),
        content: Text(
            'Jadwal booking akan diubah menjadi:\n${_fmt(_newCheckIn)} - ${_fmt(_newCheckOut)}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              setState(() {
                widget.booking.checkIn.isBefore(_newCheckIn);
              });
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Booking berhasil dijadwalkan ulang')));
            },
            style: FilledButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Booking?'),
        content: Text(_isFreeCancellation
            ? 'Anda dapat membatalkan booking ini secara gratis (free cancellation H-24). Dana akan dikembalikan 100%.'
            : 'Pembatalan sekarang dikenakan biaya karena kurang dari 24 jam sebelum check-in. Anda akan menerima refund sebagian sesuai kebijakan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak Jadi')),
          FilledButton(
            onPressed: () {
              widget.booking.status = BookingStatus.dibatalkan;
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking telah dibatalkan')));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Ya, Batalkan'),
          ),
        ],
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
          title: const Text('Reschedule / Batalkan',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: primaryBlue, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Text('Kode Booking: ',
                          style: TextStyle(fontSize: 12))),
                  Text(widget.booking.bookingCode,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Ubah Jadwal (Reschedule)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Column(
                children: [
                  _dateTile('Check-in Baru', _newCheckIn,
                      () => _pickDate(isCheckIn: true)),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1)),
                  _dateTile('Check-out Baru', _newCheckOut,
                      () => _pickDate(isCheckIn: false)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _confirmReschedule,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Simpan Jadwal Baru',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Batalkan Booking',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isFreeCancellation
                    ? Colors.green.withOpacity(0.06)
                    : Colors.orange.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                      _isFreeCancellation
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      color: _isFreeCancellation ? Colors.green : Colors.orange,
                      size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isFreeCancellation
                          ? 'Anda memenuhi syarat pembatalan gratis (H-24 sebelum check-in). Refund 100%.'
                          : 'Kurang dari 24 jam sebelum check-in. Pembatalan sekarang akan dikenakan biaya sesuai kebijakan refund.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: _confirmCancel,
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Batalkan Booking Ini',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                Text(_fmt(date),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.edit, size: 14, color: Colors.black38),
        ],
      ),
    );
  }
}
