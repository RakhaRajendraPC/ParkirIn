import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/api_exception.dart';
import '../services/app_settings.dart';
import '../services/bookings_api_service.dart';
import '../services/notification_repository.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/stub_icon.dart';
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
          title: Text(AppStrings.t('checkout_appbar_title'),
              style: const TextStyle(
                  color: Color(0xFF16181F),
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
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
            StubIcon(
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFDC2626),
                size: 64),
            const SizedBox(height: 18),
            Text(
              AppStrings.t('checkout_overstay_prompt_title'),
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16181F)),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.t('checkout_overstay_prompt_msg')
                  .replaceAll('{hours}', '$_overstayHours')
                  .replaceAll(
                      '{amount}', CurrencyFormatter.rupiah(_overstayFee)),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _payOverstay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.payment_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(AppStrings.t('checkout_pay_overstay_btn'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
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
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _loadCheckoutStatus,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppStrings.t('waiting_retry_btn')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: isTotal ? 14.5 : 12,
                    fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal,
                    color: isWarning
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16181F))),
          ),
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
