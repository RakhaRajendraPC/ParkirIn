import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/booking_repository.dart';
import '../services/notification_repository.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stub_icon.dart';
import 'ground_transport_screen.dart';

enum _GateStatus { waiting, validated }

class CheckoutScreen extends StatefulWidget {
  final BookingModel booking;

  const CheckoutScreen({super.key, required this.booking});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  _GateStatus _gateStatus = _GateStatus.waiting;
  Timer? _pollTimer;
  final List<bool> _photosTaken = [false, false, false, false];
  bool _showPhotoStep = false;

  List<String> get _photoLabels => [
        AppStrings.t('checkout_photo_depan'),
        AppStrings.t('checkout_photo_belakang'),
        AppStrings.t('checkout_photo_kiri'),
        AppStrings.t('checkout_photo_kanan'),
      ];

  double get _overstayFee {
    final now = DateTime.now();
    if (now.isAfter(widget.booking.checkOut)) {
      final extraHours = now.difference(widget.booking.checkOut).inHours;
      final extraBlocks = (extraHours / 1).ceil();
      return extraBlocks * 15000.0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);

    _pollTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _gateStatus = _GateStatus.validated;
        widget.booking.overstayFee = _overstayFee;
        widget.booking.actualCheckoutTime = DateTime.now();
        widget.booking.status = BookingStatus.checkOut;
      });

      NotificationRepository.instance.add(AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.checkoutConfirmation,
        title: AppStrings.t('checkout_notif_success_title'),
        description: AppStrings.t('checkout_notif_success_desc')
            .replaceAll('{plate}', widget.booking.vehiclePlate),
        timestamp: DateTime.now(),
        actionLabel: AppStrings.t('checkout_notif_success_action'),
        bookingCode: widget.booking.bookingCode,
      ));

      if (widget.booking.overstayFee > 0) {
        NotificationRepository.instance.add(AppNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch + 1}',
          type: NotificationType.overstayWarning,
          title: AppStrings.t('checkout_notif_overstay_title'),
          description: AppStrings.t('checkout_notif_overstay_desc')
              .replaceAll('{code}', widget.booking.bookingCode)
              .replaceAll('{amount}',
                  CurrencyFormatter.rupiah(widget.booking.overstayFee)),
          timestamp: DateTime.now(),
          actionLabel: AppStrings.t('checkout_notif_overstay_action'),
          bookingCode: widget.booking.bookingCode,
        ));
      }

      BookingRepository.instance.refresh();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_gateStatus == _GateStatus.validated) return _buildInvoice();

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(AppStrings.t('checkout_appbar_title'),
              style: const TextStyle(
                  color: Color(0xFF16181F),
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_overstayFee > 0) ...[
              _buildOverstayWarning(),
              const SizedBox(height: 16)
            ],
            Center(
              child: Column(
                children: [
                  Text(AppStrings.t('checkout_waiting_title'),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16181F))),
                  const SizedBox(height: 4),
                  Text(AppStrings.t('checkout_waiting_sub'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11.5, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildQrCard(),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => setState(() => _showPhotoStep = !_showPhotoStep),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      _showPhotoStep
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                      color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(AppStrings.t('checkout_photo_toggle'),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (_showPhotoStep) ...[
              const SizedBox(height: 12),
              _buildPhotoGrid()
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOverstayWarning() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withOpacity(0.07),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
                  AppStrings.t('checkout_overstay_warning').replaceAll(
                      '{amount}', CurrencyFormatter.rupiah(_overstayFee)),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF16181F), height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8))
            ]),
        child: Column(
          children: [
            QrImageView(
                data: widget.booking.bookingCode,
                version: QrVersions.auto,
                size: 180),
            const SizedBox(height: 14),
            Text(widget.booking.bookingCode,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    fontFamily: 'monospace',
                    color: Color(0xFF16181F))),
            const SizedBox(height: 16),
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary)),
            const SizedBox(height: 9),
            Text(AppStrings.t('checkout_waiting_qr_status'),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _photoLabels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3),
      itemBuilder: (context, index) {
        final done = _photosTaken[index];
        return InkWell(
          onTap: done ? null : () => setState(() => _photosTaken[index] = true),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: done
                  ? const Color(0xFF16A34A).withOpacity(0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: done ? const Color(0xFF16A34A) : Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.camera_alt_rounded,
                    color:
                        done ? const Color(0xFF16A34A) : Colors.grey.shade400,
                    size: 26),
                const SizedBox(height: 6),
                Text('${_photoLabels[index]}${done ? " ✓" : ""}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: done
                            ? const Color(0xFF15803D)
                            : Colors.grey.shade600)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoice() {
    final b = widget.booking;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(AppStrings.t('checkout_invoice_title'),
              style: const TextStyle(
                  color: Color(0xFF16181F),
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF16A34A), size: 42)),
            const SizedBox(height: 18),
            Text(AppStrings.t('checkout_success_title'),
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16181F),
                    letterSpacing: -0.3)),
            const SizedBox(height: 3),
            Text(AppStrings.t('checkout_success_sub'),
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.035),
                        blurRadius: 14,
                        offset: const Offset(0, 6))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.confirmation_num_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 5),
                      Text(
                          '${AppStrings.t('checkout_kode_booking')} ${b.bookingCode}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              fontFamily: 'monospace',
                              letterSpacing: 0.3)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(b.locationName,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 14),
                  const PerforationDivider(),
                  const SizedBox(height: 12),
                  _row(
                      '${AppStrings.t('checkout_tarif_dasar')} (${b.durationNights} ${AppStrings.t('checkout_malam')})',
                      b.subtotal),
                  _row(AppStrings.t('checkout_biaya_layanan'), b.serviceFee),
                  if (b.overstayFee > 0)
                    _row(AppStrings.t('checkout_biaya_keterlambatan'),
                        b.overstayFee,
                        isWarning: true),
                  const SizedBox(height: 6),
                  const PerforationDivider(),
                  const SizedBox(height: 10),
                  _row(AppStrings.t('checkout_total_akhir'), b.total,
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text(AppStrings.t('checkout_selesai_btn').toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, letterSpacing: 0.4)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GroundTransportScreen())),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.commute_rounded, size: 18),
                    const SizedBox(width: 7),
                    Text(AppStrings.t('checkout_transport_btn'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double amount,
      {bool isTotal = false, bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 14.5 : 12,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
                  color: isWarning
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16181F))),
          Text(CurrencyFormatter.rupiah(amount),
              style: TextStyle(
                  fontSize: isTotal ? 14.5 : 12,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                  color: isWarning
                      ? const Color(0xFFDC2626)
                      : (isTotal
                          ? AppColors.primary
                          : const Color(0xFF16181F)))),
        ],
      ),
    );
  }
}
