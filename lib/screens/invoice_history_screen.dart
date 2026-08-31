import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class InvoiceHistoryScreen extends StatelessWidget {
  const InvoiceHistoryScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E5EFF);

  @override
  Widget build(BuildContext context) {
    final invoices = BookingModel.mockList()
        .where((b) => b.status != BookingStatus.dibatalkan)
        .toList();

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
        body: invoices.isEmpty
            ? Center(
                child: Text('Belum ada invoice',
                    style: TextStyle(color: Colors.grey.shade500)))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: invoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildInvoiceCard(context, invoices[index]),
              ),
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
                color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long_outlined, color: primaryBlue),
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Mengunduh invoice PDF...')));
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, size: 12, color: primaryBlue),
                    SizedBox(width: 3),
                    Text('Unduh',
                        style: TextStyle(
                            fontSize: 10,
                            color: primaryBlue,
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
