import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_repository.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_toast.dart';

class RescheduleCancelScreen extends StatefulWidget {
  final BookingModel booking;

  const RescheduleCancelScreen({super.key, required this.booking});

  @override
  State<RescheduleCancelScreen> createState() => _RescheduleCancelScreenState();
}

class _RescheduleCancelScreenState extends State<RescheduleCancelScreen> {
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
    showAppSheet(
      context,
      severity: AppSeverity.neutral,
      icon: Icons.event_available_outlined,
      title: 'Konfirmasi Reschedule',
      body:
          'Jadwal booking akan diubah menjadi:\n${_fmt(_newCheckIn)} - ${_fmt(_newCheckOut)}',
      primaryLabel: 'Konfirmasi',
      onPrimary: () {
        setState(() {
          widget.booking.checkIn = _newCheckIn;
          widget.booking.checkOut = _newCheckOut;
        });
        BookingRepository.instance.refresh();
        Navigator.pop(context);
        Navigator.pop(context);
        showAppToast(
          context,
          severity: AppSeverity.success,
          message: 'Booking berhasil dijadwalkan ulang',
        );
      },
      secondaryLabel: 'Batal',
      onSecondary: () => Navigator.pop(context),
    );
  }

  void _confirmCancel() {
    final subtotal = widget.booking.subtotal;
    final cancellationFee = subtotal * 0.2;
    final refund = subtotal - cancellationFee;

    showAppSheet(
      context,
      severity: AppSeverity.destructive,
      icon: Icons.cancel_outlined,
      title: 'Batalkan Booking?',
      body: _isFreeCancellation
          ? 'Anda dapat membatalkan booking ini secara gratis (free cancellation H-24). Dana akan dikembalikan 100%.'
          : 'Pembatalan sekarang dikenakan biaya karena kurang dari 24 jam sebelum check-in.',
      breakdown: _isFreeCancellation
          ? null
          : [
              AppSheetBreakdownItem(
                label: 'Total dibayar',
                value: CurrencyFormatter.rupiah(subtotal),
              ),
              AppSheetBreakdownItem(
                label: 'Biaya pembatalan (20%)',
                value: '- ${CurrencyFormatter.rupiah(cancellationFee)}',
              ),
              AppSheetBreakdownItem(
                label: 'Refund diterima',
                value: CurrencyFormatter.rupiah(refund),
                isTotal: true,
              ),
            ],
      primaryLabel: 'Ya, Batalkan',
      onPrimary: () {
        widget.booking.status = BookingStatus.dibatalkan;
        BookingRepository.instance.refresh();
        Navigator.pop(context);
        Navigator.pop(context);
        showAppToast(
          context,
          severity: AppSeverity.neutral,
          message: 'Booking telah dibatalkan',
        );
      },
      secondaryLabel: 'Tidak Jadi',
      onSecondary: () => Navigator.pop(context),
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
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 18),
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
                    backgroundColor: AppColors.primary,
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
          Icon(Icons.calendar_today_outlined,
              size: 16, color: AppColors.primary),
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
