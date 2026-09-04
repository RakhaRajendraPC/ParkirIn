import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/api_exception.dart';
import '../services/app_settings.dart';
import '../services/bookings_api_service.dart';
import '../services/notification_repository.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'ground_transport_screen.dart';
import 'overstay_payment_screen.dart';

enum _CheckoutPhase { loadingStatus, needsOverstayPayment, checkingOut, invoice, error }

class CheckoutScreen extends StatefulWidget {
  final BookingModel booking;

  const CheckoutScreen({super.key, required this.booking});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final BookingsApiService _bookingsApi = BookingsApiService();

  _CheckoutPhase _phase = _CheckoutPhase.loadingStatus;
  String? _errorMessage;
  double _overstayFee = 0;
  int _overstayHours = 0;
  BookingModel? _finalBooking;

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
    _loadCheckoutStatus();
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCheckoutStatus() async {
    setState(() {
      _phase = _CheckoutPhase.loadingStatus;
      _errorMessage = null;
    });
    try {
      final status =
          await _bookingsApi.getCheckoutStatus(widget.booking.bookingCode);
      if (!mounted) return;
      if (status['canCheckout'] == true) {
        await _performCheckout();
        return;
      }
      setState(() {
        _overstayFee = (status['overstayFee'] as num?)?.toDouble() ?? 0;
        _overstayHours = (status['overstayHours'] as num?)?.toInt() ?? 0;
        _phase = _CheckoutPhase.needsOverstayPayment;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _phase = _CheckoutPhase.error;
      });
    }
  }

  Future<void> _performCheckout() async {
    setState(() => _phase = _CheckoutPhase.checkingOut);
    try {
      await _bookingsApi.checkout(widget.booking.bookingCode);
      // Re-fetch fresh rather than assembling the invoice from partial
      // responses — by the time checkout succeeds, any overstay payment's
      // webhook has already baked overstayFee/total into the booking row,
      // so a full re-fetch is the correct source of truth for the invoice.
      final fresh = await _bookingsApi.getBooking(widget.booking.bookingCode);
      if (!mounted) return;
      final booking = BookingModel.fromApi(fresh);

      // Keep the shared instance in sync too, same reasoning as
      // CheckinScreen — a screen further back on the stack holding this
      // same BookingModel reference reflects the change on the next reveal.
      widget.booking.status = booking.status;
      widget.booking.overstayFee = booking.overstayFee;
      widget.booking.actualCheckoutTime = booking.actualCheckoutTime;

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
      // The overstay-specific notification is no longer fired here — the
      // real backend event it corresponded to already happened earlier, at
      // payment-creation time in OverstayPaymentScreen, not at checkout
      // completion. Firing a second "late fee charged" banner at this point
      // would be a stale duplicate of something the user already saw.

      setState(() {
        _finalBooking = booking;
        _phase = _CheckoutPhase.invoice;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 402) {
        // Race: an overstay fee became newly due between our last
        // checkout-status check and this call — re-check rather than
        // treating it as a hard error.
        await _loadCheckoutStatus();
        return;
      }
      setState(() {
        _errorMessage = e.message;
        _phase = _CheckoutPhase.error;
      });
    }
  }

  Future<void> _payOverstay() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OverstayPaymentScreen(
          bookingCode: widget.booking.bookingCode,
          bank: 'bca',
        ),
      ),
    );
    if (result == true && mounted) {
      await _loadCheckoutStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _CheckoutPhase.invoice) return _buildInvoice();

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
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _CheckoutPhase.loadingStatus:
      case _CheckoutPhase.checkingOut:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                AppStrings.t('checkout_status_checking'),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      case _CheckoutPhase.needsOverstayPayment:
        return _buildOverstayPrompt();
      case _CheckoutPhase.error:
        return _buildErrorView();
      case _CheckoutPhase.invoice:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverstayPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  size: 40, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.t('checkout_overstay_prompt_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.t('checkout_overstay_prompt_msg')
                  .replaceAll('{hours}', '$_overstayHours')
                  .replaceAll(
                      '{amount}', CurrencyFormatter.rupiah(_overstayFee)),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _payOverstay,
                icon: const Icon(Icons.payment, size: 18),
                label: Text(AppStrings.t('checkout_pay_overstay_btn')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              AppStrings.t('checkout_error_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _loadCheckoutStatus,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppStrings.t('waiting_retry_btn')),
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

  Widget _buildInvoice() {
    final b = _finalBooking!;
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
