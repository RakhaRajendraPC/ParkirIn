import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../models/parking_location_model.dart';
import '../services/api_exception.dart';
import '../services/app_settings.dart';
import '../services/booking_repository.dart';
import '../services/bookings_api_service.dart';
import '../services/notification_repository.dart';
import '../services/slot_lock_service.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_toast.dart';
import '../widgets/slot_lock_banner.dart';
import 'booking_confirmation_screen.dart';

/// Fourth step of the real booking flow, after BookingSummaryScreen commits
/// to a booking: initiates the VA charge, shows the virtual account number,
/// and polls until the webhook-driven payment confirmation lands — then
/// hands off to BookingConfirmationScreen. A booking (menunggu_pembayaran)
/// and a real, extended slot lock both exist for the whole time this screen
/// is up, so it owns its own back-navigation guard rather than reusing
/// BookingSummaryScreen's simpler exit behavior.
class PaymentWaitingScreen extends StatefulWidget {
  final String bookingCode;
  final String bank;
  final ParkingLocation location;
  final DateTime checkIn;
  final DateTime checkOut;
  final DateTime lockExpiresAt;
  final String vehiclePlate;
  final String slotCode;
  final double basePrice;
  final double serviceFee;
  final double total;

  const PaymentWaitingScreen({
    super.key,
    required this.bookingCode,
    required this.bank,
    required this.location,
    required this.checkIn,
    required this.checkOut,
    required this.lockExpiresAt,
    required this.vehiclePlate,
    required this.slotCode,
    required this.basePrice,
    required this.serviceFee,
    required this.total,
  });

  @override
  State<PaymentWaitingScreen> createState() => _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends State<PaymentWaitingScreen> {
  static const int _maxPollAttempts = 90; // ~6 minutes at 4s intervals
  static const int _maxConsecutiveFailures = 3;
  static const Duration _pollInterval = Duration(seconds: 4);

  final BookingsApiService _bookingsApi = BookingsApiService();

  bool _isInitiating = true;
  String? _initiateError;
  String _vaBank = '';
  String _vaNumber = '';

  Timer? _pollTimer;
  int _pollAttempts = 0;
  int _consecutiveFailures = 0;
  bool _pollTimedOut = false;
  bool _connectionLost = false;
  bool _leavingForConfirmation = false;

  @override
  void initState() {
    super.initState();
    // The backend just extended the lock to a fresh payment window when it
    // created this booking — resync the local countdown to that real value
    // instead of leaving it counting down from the original, now-stale,
    // 10-minute slot-selection expiry.
    SlotLockService.instance.updateExpiresAt(widget.lockExpiresAt);
    _initiatePayment();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    setState(() {
      _isInitiating = true;
      _initiateError = null;
    });
    try {
      final result = await _bookingsApi.initiatePayment(
        widget.bookingCode,
        method: 'va',
        bank: widget.bank,
      );
      final vaNumbers = result['vaNumbers'] as List<dynamic>?;
      final first = (vaNumbers != null && vaNumbers.isNotEmpty)
          ? vaNumbers.first as Map<String, dynamic>
          : null;
      final number = first?['va_number']?.toString() ?? '';
      if (!mounted) return;
      if (number.isEmpty) {
        setState(() {
          _isInitiating = false;
          _initiateError = 'Nomor Virtual Account tidak diterima dari server.';
        });
        return;
      }
      setState(() {
        _vaBank = (first?['bank']?.toString() ?? widget.bank).toUpperCase();
        _vaNumber = number;
        _isInitiating = false;
      });
      _startPolling();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitiating = false;
        _initiateError = e.message;
      });
    }
  }

  void _startPolling() {
    _pollAttempts = 0;
    _consecutiveFailures = 0;
    _pollTimedOut = false;
    _connectionLost = false;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (_leavingForConfirmation) return;
    _pollAttempts++;
    try {
      final booking = await _bookingsApi.getBooking(widget.bookingCode);
      _consecutiveFailures = 0;
      if (booking['status'] == 'dipesan') {
        await _onPaymentConfirmed();
        return;
      }
    } on ApiException {
      _consecutiveFailures++;
      if (_consecutiveFailures >= _maxConsecutiveFailures) {
        _pollTimer?.cancel();
        if (mounted) setState(() => _connectionLost = true);
        return;
      }
    }

    if (_pollAttempts >= _maxPollAttempts) {
      _pollTimer?.cancel();
      if (mounted) setState(() => _pollTimedOut = true);
    }
  }

  Future<void> _onPaymentConfirmed() async {
    _leavingForConfirmation = true;
    _pollTimer?.cancel();

    // Best-effort — harmless if the webhook already released this
    // server-side (release()'s DELETE call absorbs a 404 silently).
    await SlotLockService.instance.release();

    BookingRepository.instance.add(BookingModel(
      bookingCode: widget.bookingCode,
      locationName: widget.location.name,
      locationAddress: widget.location.address,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      vehiclePlate: widget.vehiclePlate,
      slotCode: widget.slotCode,
      basePrice: widget.basePrice,
      serviceFee: widget.serviceFee,
      shuttleFee: 0,
      status: BookingStatus.dipesan,
    ));

    NotificationRepository.instance.add(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.bookingConfirmation,
      title: AppStrings.t('summary_notif_title'),
      description:
          '${AppStrings.t('summary_notif_desc_prefix')} ${widget.slotCode} di ${widget.location.name} ${AppStrings.t('summary_notif_desc_suffix')}',
      timestamp: DateTime.now(),
      actionLabel: AppStrings.t('summary_notif_action'),
      bookingCode: widget.bookingCode,
    ));

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          bookingCode: widget.bookingCode,
          location: widget.location,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          total: widget.total,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _resumePolling() {
    setState(() {
      _pollTimedOut = false;
      _connectionLost = false;
    });
    _startPolling();
  }

  Future<bool> _confirmLeave() async {
    final result = await showAppSheet<bool>(
      context,
      severity: AppSeverity.warning,
      icon: Icons.warning_amber_rounded,
      title: AppStrings.t('waiting_leave_title'),
      body: AppStrings.t('waiting_leave_msg'),
      primaryLabel: AppStrings.t('waiting_leave_stay_btn'),
      onPrimary: () => Navigator.of(context).pop(false),
      secondaryLabel: AppStrings.t('waiting_leave_confirm_btn'),
      onSecondary: () => Navigator.of(context).pop(true),
    );
    return result ?? false;
  }

  void _onLockExpired() {
    _pollTimer?.cancel();
    showAppSheet(
      context,
      severity: AppSeverity.warning,
      icon: Icons.timer_off_outlined,
      title: AppStrings.t('waiting_lock_expired_title'),
      body: AppStrings.t('waiting_lock_expired_msg'),
      barrierDismissible: false,
      primaryLabel: AppStrings.t('waiting_lock_expired_btn'),
      onPrimary: () => Navigator.of(context).popUntil((r) => r.isFirst),
    );
  }

  Future<void> _copyVaNumber() async {
    await Clipboard.setData(ClipboardData(text: _vaNumber));
    if (!mounted) return;
    showAppToast(
      context,
      severity: AppSeverity.success,
      message: AppStrings.t('waiting_copy_success'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _confirmLeave();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () async {
                if (await _confirmLeave() && mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            title: Text(
              AppStrings.t('waiting_appbar_title'),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isInitiating && _initiateError == null)
                  SlotLockBanner(onExpired: _onLockExpired),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isInitiating) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_initiateError != null) {
      return _buildInitiateErrorView();
    }
    if (_connectionLost) {
      return _buildRetryView(
        icon: Icons.wifi_off_rounded,
        title: AppStrings.t('waiting_connection_lost_title'),
        message: AppStrings.t('waiting_connection_lost_msg'),
        buttonLabel: AppStrings.t('waiting_retry_btn'),
        onRetry: _resumePolling,
      );
    }
    if (_pollTimedOut) {
      return _buildRetryView(
        icon: Icons.hourglass_bottom_rounded,
        title: AppStrings.t('waiting_timeout_title'),
        message: AppStrings.t('waiting_timeout_msg'),
        buttonLabel: AppStrings.t('waiting_check_now_btn'),
        onRetry: _resumePolling,
      );
    }
    return _buildWaitingView();
  }

  Widget _buildInitiateErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              AppStrings.t('waiting_initiate_error_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _initiateError ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _initiatePayment,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppStrings.t('waiting_initiate_retry_btn')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryView({
    required IconData icon,
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.warningOrange),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.t('waiting_va_instruction'),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.t('waiting_va_bank_label'),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  _vaBank,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.t('waiting_va_number_label'),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _vaNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _copyVaNumber,
                      icon: Icon(Icons.copy_outlined, color: AppColors.primary),
                      tooltip: AppStrings.t('waiting_copy_btn'),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.t('summary_total'),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    Text(
                      CurrencyFormatter.rupiah(widget.total),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.t('waiting_status_checking'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.t('waiting_status_sub'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
