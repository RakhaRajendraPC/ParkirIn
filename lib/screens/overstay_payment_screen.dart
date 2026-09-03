import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_exception.dart';
import '../services/app_settings.dart';
import '../services/bookings_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_sheet.dart';
import '../widgets/va_payment_card.dart';

/// Pushed from CheckoutScreen when an overstay fee is due. Its only job is
/// getting that fee paid — it initiates the VA charge, shows it, and polls
/// checkout-status until canCheckout flips true, then pops back with
/// `true`. It deliberately does NOT call the checkout endpoint itself and
/// has no slot-lock involvement at all (unlike PaymentWaitingScreen, there
/// is nothing locked during checkout — the slot is actively occupied).
class OverstayPaymentScreen extends StatefulWidget {
  final String bookingCode;
  final String bank;

  const OverstayPaymentScreen({
    super.key,
    required this.bookingCode,
    required this.bank,
  });

  @override
  State<OverstayPaymentScreen> createState() => _OverstayPaymentScreenState();
}

class _OverstayPaymentScreenState extends State<OverstayPaymentScreen> {
  static const int _maxPollAttempts = 90; // ~6 minutes at 4s intervals
  static const int _maxConsecutiveFailures = 3;
  static const Duration _pollInterval = Duration(seconds: 4);

  final BookingsApiService _bookingsApi = BookingsApiService();

  bool _isInitiating = true;
  String? _initiateError;
  String _vaBank = '';
  String _vaNumber = '';
  double _amount = 0;

  Timer? _pollTimer;
  int _pollAttempts = 0;
  int _consecutiveFailures = 0;
  bool _pollTimedOut = false;
  bool _connectionLost = false;
  bool _leavingWithResult = false;

  @override
  void initState() {
    super.initState();
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
      final result = await _bookingsApi.createOverstayPayment(
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
      // grossAmount comes straight from Midtrans's own charge response —
      // the backend "freezes" the overstay fee at charge time, so this is
      // the authoritative amount actually being charged, not a re-estimate.
      final grossAmount = result['grossAmount'];
      setState(() {
        _vaBank = (first?['bank']?.toString() ?? widget.bank).toUpperCase();
        _vaNumber = number;
        _amount = grossAmount != null
            ? double.tryParse(grossAmount.toString()) ?? 0
            : 0;
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
    if (_leavingWithResult) return;
    _pollAttempts++;
    try {
      final status = await _bookingsApi.getCheckoutStatus(widget.bookingCode);
      _consecutiveFailures = 0;
      if (status['canCheckout'] == true) {
        _leavingWithResult = true;
        _pollTimer?.cancel();
        if (mounted) Navigator.of(context).pop(true);
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
      title: AppStrings.t('overstay_leave_title'),
      body: AppStrings.t('overstay_leave_msg'),
      primaryLabel: AppStrings.t('waiting_leave_stay_btn'),
      onPrimary: () => Navigator.of(context).pop(false),
      secondaryLabel: AppStrings.t('waiting_leave_confirm_btn'),
      onSecondary: () => Navigator.of(context).pop(true),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _confirmLeave();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop(false);
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
                  Navigator.of(context).pop(false);
                }
              },
            ),
            title: Text(
              AppStrings.t('overstay_appbar_title'),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBody(),
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
          VaPaymentCard(
            instruction: AppStrings.t('overstay_va_instruction'),
            bank: _vaBank,
            vaNumber: _vaNumber,
            amount: _amount,
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
            AppStrings.t('overstay_status_sub'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
