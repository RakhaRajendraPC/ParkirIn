import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/app_settings.dart';
import '../utils/currency_formatter.dart';

/// Displays a Midtrans QRIS payment's scannable code and amount. Sibling to
/// [VaPaymentCard] rather than a branch inside it — QRIS's actual content
/// (a scannable image) has nothing in common with VA's (a copyable bank
/// number), so sharing a single widget would just be an if/else wrapper
/// around two unrelated layouts. Shared by PaymentWaitingScreen the same
/// way VaPaymentCard is.
class QrisPaymentCard extends StatelessWidget {
  final String qrString;
  final double amount;

  const QrisPaymentCard({
    super.key,
    required this.qrString,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            AppStrings.t('waiting_qris_instruction'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: qrString,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Divider(height: 1),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.t('summary_total'),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                CurrencyFormatter.rupiah(amount),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
