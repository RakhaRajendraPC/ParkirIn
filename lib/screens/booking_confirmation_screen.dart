import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/parking_location_model.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stub_icon.dart';
import 'bookings_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingCode;
  final ParkingLocation location;
  final DateTime checkIn;
  final DateTime checkOut;
  final double total;

  const BookingConfirmationScreen(
      {super.key,
      required this.bookingCode,
      required this.location,
      required this.checkIn,
      required this.checkOut,
      required this.total});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  @override
  void initState() {
    super.initState();
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

  String _fmtDate(DateTime d) {
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
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year}, $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 14),
            Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF16A34A), size: 42)),
            const SizedBox(height: 18),
            Text(AppStrings.t('confirm_title'),
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16181F),
                    letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text(AppStrings.t('confirm_subtitle'),
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 22,
                        offset: const Offset(0, 10))
                  ]),
              child: Column(
                children: [
                  QrImageView(
                      data: widget.bookingCode,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white),
                  const SizedBox(height: 14),
                  Text(widget.bookingCode,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          fontFamily: 'monospace',
                          color: Color(0xFF16181F))),
                  const SizedBox(height: 5),
                  Text(AppStrings.t('confirm_qr_note'),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.location.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF16181F))),
                  const SizedBox(height: 3),
                  Text(widget.location.address,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  const PerforationDivider(),
                  const SizedBox(height: 12),
                  _infoRow(
                      AppStrings.t('confirm_masuk'), _fmtDate(widget.checkIn)),
                  const SizedBox(height: 7),
                  _infoRow(AppStrings.t('confirm_keluar'),
                      _fmtDate(widget.checkOut)),
                  const SizedBox(height: 7),
                  _infoRow(AppStrings.t('confirm_total_dibayar'),
                      CurrencyFormatter.rupiah(widget.total),
                      highlight: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(AppStrings.t('confirm_reminder_note'),
                          style: const TextStyle(fontSize: 11.5))),
                ],
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BookingsScreen()),
                    (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text(
                    AppStrings.t('confirm_lihat_booking_btn').toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, letterSpacing: 0.3)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text(AppStrings.t('confirm_kembali_beranda_btn'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: highlight ? 14.5 : 12,
                fontWeight: FontWeight.w800,
                color:
                    highlight ? AppColors.primary : const Color(0xFF16181F))),
      ],
    );
  }
}
