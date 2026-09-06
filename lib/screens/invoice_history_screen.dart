import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_exception.dart';
import '../services/bookings_api_service.dart';
import '../services/receipt_generator.dart';
import '../utils/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/network_error_view.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  final _bookingsApi = BookingsApiService();
  List<BookingModel> _invoices = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final json = await _bookingsApi.getBookings();
      final invoices = json
          .map(BookingModel.fromApi)
          .where((b) =>
              b.status != BookingStatus.dibatalkan &&
              b.status != BookingStatus.menungguPembayaran)
          .toList();
      if (!mounted) return;
      setState(() => _invoices = invoices);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadReceipt(BookingModel booking) async {
    try {
      await ReceiptGenerator.shareOrPrintReceipt(booking);
    } catch (_) {
      if (!mounted) return;
      showAppToast(
        context,
        severity: AppSeverity.destructive,
        message: 'Gagal membuat invoice PDF',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Riwayat Invoice',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return NetworkErrorView(onRetry: _loadInvoices, message: _errorMessage);
    }
    if (_invoices.isEmpty) {
      return Center(
        child: Text('Belum ada invoice',
            style: TextStyle(color: Colors.grey.shade500)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadInvoices,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _invoices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildInvoiceCard(context, _invoices[index]),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, BookingModel b) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle),
            child:
                Icon(Icons.receipt_long_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.locationName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                    '${b.bookingCode} · ${b.checkIn.day}/${b.checkIn.month}/${b.checkIn.year}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rp ${b.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _downloadReceipt(b),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, size: 12, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text('Unduh',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
