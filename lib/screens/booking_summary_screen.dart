import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../models/parking_slot_model.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/slot_lock_service.dart';
import '../services/booking_repository.dart';
import '../services/notification_repository.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'booking_confirmation_screen.dart';
import '../utils/currency_formatter.dart';

class BookingSummaryScreen extends StatefulWidget {
  final ParkingLocation location;
  final DateTime checkIn;
  final DateTime checkOut;
  final ParkingSlot? selectedSlot;
  final String driverName;
  final String driverPhone;
  final String vehiclePlate;
  final String vehicleBrand;
  final String vehicleType;

  const BookingSummaryScreen({
    super.key,
    required this.location,
    required this.checkIn,
    required this.checkOut,
    this.selectedSlot,
    this.driverName = '',
    this.driverPhone = '',
    this.vehiclePlate = '',
    this.vehicleBrand = '',
    this.vehicleType = '',
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  String _selectedPayment = 'QRIS';
  bool _isProcessing = false;

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

  int get _nights {
    final n = widget.checkOut.difference(widget.checkIn).inHours / 24;
    return n.ceil() < 1 ? 1 : n.ceil();
  }

  double get _pricePerNight =>
      widget.selectedSlot?.price ?? widget.location.pricePerNight;
  double get _subtotal => _pricePerNight * _nights;
  double get _serviceFee => 10000;
  double get _total => _subtotal + _serviceFee;

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
    return '${d.day} ${months[d.month]} · $hh:$mm';
  }

  Future<void> _pay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(
        const Duration(seconds: 2)); // simulasi payment gateway (PRD §9)
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final bookingCode = 'PKR-${DateTime.now().millisecondsSinceEpoch % 100000}';

    // Buat booking asli dan simpan ke sumber data tunggal, supaya langsung
    // muncul di Riwayat Booking dengan slotCode & data kendaraan yang benar.
    final newBooking = BookingModel(
      bookingCode: bookingCode,
      locationName: widget.location.name,
      locationAddress: widget.location.address,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      vehiclePlate: widget.vehiclePlate,
      slotCode: widget.selectedSlot?.code ?? '',
      basePrice: _pricePerNight,
      serviceFee: _serviceFee,
      shuttleFee: 0,
      status: BookingStatus.dipesan,
    );
    BookingRepository.instance.add(newBooking);
    SlotLockService.instance.release();

    NotificationRepository.instance.add(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.bookingConfirmation,
      title: AppStrings.t('summary_notif_title'),
      description:
          '${AppStrings.t('summary_notif_desc_prefix')} ${widget.selectedSlot?.code ?? '-'} di ${widget.location.name} ${AppStrings.t('summary_notif_desc_suffix')}',
      timestamp: DateTime.now(),
      actionLabel: AppStrings.t('summary_notif_action'),
      bookingCode: bookingCode,
    ));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          bookingCode: bookingCode,
          location: widget.location,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          total: _total,
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
            AppStrings.t('summary_appbar_title'),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBookingCard(),
            const SizedBox(height: 16),
            _buildCostBreakdown(),
            const SizedBox(height: 16),
            _buildPaymentMethod(),
            const SizedBox(height: 16),
            _buildOverstayNotice(),
            const SizedBox(height: 100),
          ],
        ),
        bottomNavigationBar: SafeArea(
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
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: AppStrings.t('summary_total_label'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                        TextSpan(
                          text: CurrencyFormatter.rupiah(_total),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppStrings.t('summary_bayar_sekarang'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.location.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.location.address,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t('summary_masuk'),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      _fmtDate(widget.checkIn),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.t('summary_keluar'),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      _fmtDate(widget.checkOut),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$_nights ${AppStrings.t('summary_malam')}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.selectedSlot != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_parking,
                  size: 13,
                  color: widget.selectedSlot!.tierColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${AppStrings.t('summary_slot_prefix')} ${widget.selectedSlot!.code} · ${widget.selectedSlot!.tierLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (widget.driverName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 13,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.driverName} · ${widget.vehiclePlate}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostBreakdown() {
    Widget row(String label, double amount, {bool isTotal = false}) {
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
              ),
            ),
            Text(
              CurrencyFormatter.rupiah(amount),
              style: TextStyle(
                fontSize: isTotal ? 14 : 12,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t('summary_rincian_biaya'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          row(
            '${AppStrings.t('summary_tarif_dasar')} (${CurrencyFormatter.rupiah(_pricePerNight)} × $_nights ${AppStrings.t('summary_malam')})',
            _subtotal,
          ),
          row(AppStrings.t('summary_biaya_layanan'), _serviceFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1),
          ),
          row(AppStrings.t('summary_total'), _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final methods = [
      ('QRIS', Icons.qr_code, false),
      ('Virtual Account BCA', Icons.account_balance_outlined, false),
      ('Virtual Account BRI', Icons.account_balance_outlined, false),
      ('E-Wallet', Icons.account_balance_wallet_outlined, true),
      ('Kartu Debit/Kredit', Icons.credit_card, true),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.t('summary_metode_pembayaran'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...methods.map((m) {
            final selected = _selectedPayment == m.$1;
            return RadioListTile<String>(
              value: m.$1,
              groupValue: _selectedPayment,
              onChanged: (v) => setState(() => _selectedPayment = v!),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Icon(
                    m.$2,
                    size: 18,
                    color: selected ? AppColors.primary : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    m.$1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (m.$3) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppStrings.t('summary_opsional_badge'),
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOverstayNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.t('summary_overstay_notice'),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
