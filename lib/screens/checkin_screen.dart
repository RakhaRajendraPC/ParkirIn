import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/api_exception.dart';
import '../services/notification_repository.dart';
import '../services/app_settings.dart';
import '../services/bookings_api_service.dart';
import '../utils/app_colors.dart';
import 'shuttle_tracking_screen.dart';

enum _GateStatus { waiting, validated }

class CheckinScreen extends StatefulWidget {
  final BookingModel booking;

  const CheckinScreen({super.key, required this.booking});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final BookingsApiService _bookingsApi = BookingsApiService();

  _GateStatus _gateStatus = _GateStatus.waiting;
  bool _hasError = false;
  String? _errorMessage;
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
    _performCheckin();
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _performCheckin() async {
    setState(() {
      _gateStatus = _GateStatus.waiting;
      _hasError = false;
    });
    try {
      await _bookingsApi.checkin(widget.booking.bookingCode);
      if (!mounted) return;
      setState(() {
        _gateStatus = _GateStatus.validated;
        // Mutating this shared instance means a screen further back on the
        // stack (e.g. BookingDetailScreen) that's still holding the same
        // BookingModel reference reflects the new status immediately when
        // revealed by a pop, without needing its own refetch.
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
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.message;
      });
    }
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.t('checkin_appbar_title'),
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
            _buildBookingInfo(),
            const SizedBox(height: 20),
            if (_hasError) ...[
              _buildErrorState(),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      _gateStatus == _GateStatus.waiting
                          ? AppStrings.t('checkin_waiting_title')
                          : AppStrings.t('checkin_success_title'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _gateStatus == _GateStatus.waiting
                          ? AppStrings.t('checkin_waiting_sub')
                          : AppStrings.t('checkin_success_sub'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildQrCard(),
              const SizedBox(height: 20),
              if (_gateStatus == _GateStatus.validated) ...[
                _buildSuccessBanner(),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showPhotoStep = !_showPhotoStep),
                  icon: Icon(
                    _showPhotoStep ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(
                    AppStrings.t('checkin_photo_toggle'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (_showPhotoStep) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.t('checkin_photo_note'),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 10),
                  _buildPhotoGrid(),
                ],
                const SizedBox(height: 100),
              ] else ...[
                const SizedBox(height: 100),
              ],
            ],
          ],
        ),
        bottomNavigationBar: _gateStatus == _GateStatus.validated
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _goToShuttle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppStrings.t('checkin_lacak_shuttle_btn'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              AppStrings.t('checkin_error_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _performCheckin,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(AppStrings.t('waiting_retry_btn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_car_filled, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.vehiclePlate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.booking.locationName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
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
          border: Border.all(
            color: _gateStatus == _GateStatus.validated
                ? Colors.green
                : Colors.grey.shade200,
            width: _gateStatus == _GateStatus.validated ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Opacity(
              opacity: _gateStatus == _GateStatus.validated ? 0.35 : 1,
              child: QrImageView(
                data: widget.booking.bookingCode,
                version: QrVersions.auto,
                size: 180,
              ),
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
            if (_gateStatus == _GateStatus.waiting) ...[
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
                AppStrings.t('checkin_waiting_qr_status'),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.t('checkin_success_banner'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
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
}
