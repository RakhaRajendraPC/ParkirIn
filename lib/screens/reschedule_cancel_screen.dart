import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_exception.dart';
import '../services/bookings_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_toast.dart';

class RescheduleCancelScreen extends StatefulWidget {
  final BookingModel booking;

  const RescheduleCancelScreen({super.key, required this.booking});

  @override
  State<RescheduleCancelScreen> createState() => _RescheduleCancelScreenState();
}

class _RescheduleCancelScreenState extends State<RescheduleCancelScreen> {
  final BookingsApiService _bookingsApi = BookingsApiService();
  late final Duration _originalDuration;
  late DateTime _newCheckIn;
  bool _isCancelling = false;
  bool _isRescheduling = false;

  DateTime get _newCheckOut => _newCheckIn.add(_originalDuration);

  @override
  void initState() {
    super.initState();
    _originalDuration =
        widget.booking.checkOut.difference(widget.booking.checkIn);
    _newCheckIn = widget.booking.checkIn;
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

  Future<void> _pickNewCheckIn() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _newCheckIn,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(_newCheckIn));
    if (time == null) return;
    setState(() {
      _newCheckIn =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _performReschedule() async {
    setState(() => _isRescheduling = true);
    try {
      await _bookingsApi.rescheduleBooking(
        widget.booking.bookingCode,
        newCheckInPlanned: _newCheckIn,
        newCheckOutPlanned: _newCheckOut,
      );
      if (!mounted) return;
      // Mutating the shared instance means BookingDetailScreen, still
      // holding this same BookingModel reference, reflects the new dates
      // immediately when revealed by the pop below.
      widget.booking.checkIn = _newCheckIn;
      widget.booking.checkOut = _newCheckOut;
      Navigator.pop(context);
      showAppToast(
        context,
        severity: AppSeverity.success,
        message: 'Jadwal booking berhasil diubah',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isRescheduling = false);
      String message;
      if (e.statusCode == 409) {
        message = 'Slot tidak tersedia di tanggal itu';
      } else if (e.statusCode == 400) {
        // Defensive — the UI no longer lets duration change, but the
        // backend is the final authority.
        message = 'Durasi menginap tidak boleh berubah saat reschedule';
      } else {
        message = e.message;
      }
      showAppToast(context, severity: AppSeverity.destructive, message: message);
    }
  }

  void _confirmCancel() {
    showAppSheet(
      context,
      severity: AppSeverity.destructive,
      icon: Icons.cancel_outlined,
      title: 'Batalkan Booking?',
      body: 'Yakin ingin membatalkan booking ini? Tindakan ini tidak dapat '
          'dibatalkan.',
      primaryLabel: 'Ya, Batalkan',
      onPrimary: () {
        Navigator.pop(context); // dismiss this confirmation sheet
        _performCancel();
      },
      secondaryLabel: 'Tidak Jadi',
      onSecondary: () => Navigator.pop(context),
    );
  }

  Future<void> _performCancel() async {
    setState(() => _isCancelling = true);
    try {
      await _bookingsApi.cancelBooking(widget.booking.bookingCode);
      if (!mounted) return;
      // Mutating the shared instance means BookingDetailScreen, still
      // holding this same BookingModel reference, reflects the new status
      // immediately when revealed by the pop below.
      widget.booking.status = BookingStatus.dibatalkan;
      Navigator.pop(context);
      showAppToast(
        context,
        severity: AppSeverity.neutral,
        message: 'Booking telah dibatalkan',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
              widget.booking.status == BookingStatus.dipesan
                  ? 'Reschedule / Batalkan'
                  : 'Batalkan Booking',
              style: const TextStyle(
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
            // Reschedule only applies to a confirmed (dipesan) booking — the
            // backend itself rejects it for any other status, and an unpaid
            // booking has no reason to shift dates rather than just being
            // cancelled outright.
            if (widget.booking.status == BookingStatus.dipesan) ...[
              const SizedBox(height: 20),
              const Text('Ubah Jadwal (Reschedule)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Durasi menginap tetap ${_originalDuration.inHours ~/ 24} malam — '
                'geser tanggal check-in, check-out menyesuaikan otomatis.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
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
                        onTap: _pickNewCheckIn),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1)),
                    _dateTile('Check-out Baru (otomatis)', _newCheckOut),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isRescheduling ? null : _performReschedule,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: _isRescheduling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan Jadwal Baru',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 32),
            const Text('Batalkan Booking',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.black54, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Booking akan dibatalkan dan slot parkir akan dilepaskan.',
                      style: TextStyle(fontSize: 12),
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
                onPressed: _isCancelling ? null : _confirmCancel,
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _isCancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.redAccent,
                        ),
                      )
                    : const Text('Batalkan Booking Ini',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 16, color: onTap != null ? AppColors.primary : Colors.grey.shade400),
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
          if (onTap != null)
            const Icon(Icons.edit, size: 14, color: Colors.black38),
        ],
      ),
    );
  }
}
