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
          title: Text(
            AppStrings.t('checkout_appbar_title'),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_overstayFee > 0) ...[
              _buildOverstayWarning(),
              const SizedBox(height: 16),
            ],
            Center(
              child: Column(
                children: [
                  Text(
                    AppStrings.t('checkout_waiting_title'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.t('checkout_waiting_sub'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildQrCard(),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => setState(() => _showPhotoStep = !_showPhotoStep),
              icon: Icon(
                _showPhotoStep ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: Text(
                AppStrings.t('checkout_photo_toggle'),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (_showPhotoStep) ...[
              const SizedBox(height: 10),
              _buildPhotoGrid(),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildOverstayWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.t('checkout_overstay_warning').replaceAll(
                  '{amount}', CurrencyFormatter.rupiah(_overstayFee)),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            QrImageView(
              data: widget.booking.bookingCode,
              version: QrVersions.auto,
              size: 180,
            ),
            const SizedBox(height: 12),
            Text(
              widget.booking.bookingCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.t('checkout_waiting_qr_status'),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
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
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final done = _photosTaken[index];
        return InkWell(
          onTap: done ? null : () => setState(() => _photosTaken[index] = true),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: done ? Colors.green.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: done ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.camera_alt_outlined,
                  color: done ? Colors.green : Colors.grey.shade400,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  '${_photoLabels[index]} ${done ? "✓" : ""}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: done ? Colors.green.shade800 : Colors.grey.shade600,
                  ),
                ),
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
          title: Text(
            AppStrings.t('checkout_invoice_title'),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.t('checkout_success_title'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              AppStrings.t('checkout_success_sub'),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.t('checkout_kode_booking')} ${b.bookingCode}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    b.locationName,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _row(
                      '${AppStrings.t('checkout_tarif_dasar')} (${b.durationNights} ${AppStrings.t('checkout_malam')})',
                      b.subtotal),
                  _row(AppStrings.t('checkout_biaya_layanan'), b.serviceFee),
                  if (b.overstayFee > 0)
                    _row(AppStrings.t('checkout_biaya_keterlambatan'),
                        b.overstayFee,
                        isWarning: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(height: 1),
                  ),
                  _row(AppStrings.t('checkout_total_akhir'), b.total,
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.t('checkout_selesai_btn'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroundTransportScreen(),
                  ),
                ),
                icon: const Icon(Icons.commute, size: 18),
                label: Text(AppStrings.t('checkout_transport_btn')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    double amount, {
    bool isTotal = false,
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isWarning ? Colors.redAccent : Colors.black87,
            ),
          ),
          Text(
            CurrencyFormatter.rupiah(amount),
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isWarning ? Colors.redAccent : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
