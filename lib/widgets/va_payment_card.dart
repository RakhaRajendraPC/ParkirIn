import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'app_toast.dart';

/// Displays a Midtrans VA payment's bank name, number (with copy-to-
/// clipboard), and amount. Shared by PaymentWaitingScreen (booking payment)
/// and OverstayPaymentScreen (overstay payment) — the two screens differ in
/// what happens around this card (polling target, success behavior), not in
/// how the VA itself is presented, so only this purely-presentational piece
/// is shared rather than the whole screen's state machine.
class VaPaymentCard extends StatelessWidget {
  final String instruction;
  final String bank;
  final String vaNumber;
  final double amount;

  const VaPaymentCard({
    super.key,
    required this.instruction,
    required this.bank,
    required this.vaNumber,
    required this.amount,
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: vaNumber));
    if (!context.mounted) return;
    showAppToast(
      context,
      severity: AppSeverity.success,
      message: AppStrings.t('waiting_copy_success'),
    );
  }

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
            instruction,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.t('waiting_va_bank_label'),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            bank,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                  vaNumber,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _copy(context),
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
