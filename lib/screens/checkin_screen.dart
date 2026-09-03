import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/booking_repository.dart';
import '../services/notification_repository.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../widgets/stub_icon.dart';
import 'shuttle_tracking_screen.dart';

enum _GateStatus { waiting, validated }

class CheckinScreen extends StatefulWidget {
  final BookingModel booking;

  const CheckinScreen({super.key, required this.booking});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  _GateStatus _gateStatus = _GateStatus.waiting;
  Timer? _pollTimer;
  final List<bool> _photosTaken = [false, false, false, false];
  bool _showPhotoStep = false;

  List<String> get _photoLabels => [
        AppStrings.t('checkin_photo_depan'),
        AppStrings.t('checkin_photo_belakang'),
        AppStrings.t('checkin_photo_kiri'),
        AppStrings.t('checkin_photo_kanan'),
      ];

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);

    _pollTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _gateStatus = _GateStatus.validated;
        widget.booking.status = BookingStatus.checkIn;
      });

      NotificationRepository.instance.add(AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.checkinConfirmation,
        title: AppStrings.t('checkin_notif_title'),
        description:
            '${AppStrings.t('checkin_notif_desc_prefix')} ${widget.booking.vehiclePlate} ${AppStrings.t('checkin_notif_desc_middle')} ${widget.booking.slotCode}.',
        timestamp: DateTime.now(),
        actionLabel: AppStrings.t('checkin_notif_action'),
        bookingCode: widget.booking.bookingCode,
      ));

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

  void _goToShuttle() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ShuttleTrackingScreen(
          bookingCode: widget.booking.bookingCode,
          pickupPointName: 'Titik Jemput A - ${widget.booking.locationName}',
          destinationName: 'Terminal Keberangkatan',
          userSlotCode: widget.booking.slotCode,
          venueAddress: widget.booking.locationAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validated = _gateStatus == _GateStatus.validated;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(AppStrings.t('checkin_appbar_title'),
              style: const TextStyle(
                  color: Color(0xFF16181F),
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBookingInfo(),
            const SizedBox(height: 22),
            Center(
              child: Column(
                children: [
                  Text(
                    validated
                        ? AppStrings.t('checkin_success_title')
                        : AppStrings.t('checkin_waiting_title'),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16181F)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    validated
                        ? AppStrings.t('checkin_success_sub')
                        : AppStrings.t('checkin_waiting_sub'),
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildQrCard(validated),
            const SizedBox(height: 20),
            if (validated) ...[
              _buildSuccessBanner(),
              const SizedBox(height: 16),
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
                    Text(AppStrings.t('checkin_photo_toggle'),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (_showPhotoStep) ...[
                const SizedBox(height: 6),
                Text(AppStrings.t('checkin_photo_note'),
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                _buildPhotoGrid(),
              ],
              const SizedBox(height: 100),
            ] else
              const SizedBox(height: 100),
          ],
        ),
        bottomNavigationBar: validated
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4))
                  ]),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _goToShuttle,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: Text(
                          AppStrings.t('checkin_lacak_shuttle_btn')
                              .toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)
          ]),
      child: Row(
        children: [
          StubIcon(
              icon: Icons.directions_car_filled_rounded,
              color: AppColors.primary,
              size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.booking.vehiclePlate,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF16181F))),
                const SizedBox(height: 2),
                Text(widget.booking.locationName,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(bool validated) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: validated
              ? Border.all(color: const Color(0xFF16A34A), width: 1.6)
              : Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
                color: (validated ? const Color(0xFF16A34A) : Colors.black)
                    .withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          children: [
            Opacity(
              opacity: validated ? 0.35 : 1,
              child: QrImageView(
                  data: widget.booking.bookingCode,
                  version: QrVersions.auto,
                  size: 180),
            ),
            const SizedBox(height: 14),
            Text(widget.booking.bookingCode,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    fontFamily: 'monospace',
                    color: Color(0xFF16181F))),
            if (!validated) ...[
              const SizedBox(height: 16),
              SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary)),
              const SizedBox(height: 9),
              Text(AppStrings.t('checkin_waiting_qr_status'),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withOpacity(0.08),
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(AppStrings.t('checkin_success_banner'),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700))),
        ],
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
}
