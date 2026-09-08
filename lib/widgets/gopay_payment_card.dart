import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'app_toast.dart';

/// Displays a Midtrans GoPay payment: a primary "open the app" deeplink
/// button plus a secondary scannable QR fallback. Sibling to
/// VaPaymentCard/QrisPaymentCard rather than a branch inside either — GoPay
/// is the only channel that offers both an app-deeplink AND a QR image
/// simultaneously, which neither of those widgets is shaped for.
class GopayPaymentCard extends StatelessWidget {
  final String deeplinkUrl;
  final String qrCodeUrl;
  final double amount;

  const GopayPaymentCard({
    super.key,
    required this.deeplinkUrl,
    required this.qrCodeUrl,
    required this.amount,
  });

  Future<void> _openGopay(BuildContext context) async {
    // Same try-app-then-fallback shape already established in
    // transport_category_detail_screen.dart — here there's no separate web
    // fallback URL (deeplinkUrl itself is web-openable in Midtrans's
    // sandbox), so a launch failure just means falling back to the QR
    // below, which is always shown anyway.
    final uri = Uri.parse(deeplinkUrl);
    final launched =
        await canLaunchUrl(uri) && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      showAppToast(
        context,
        severity: AppSeverity.warning,
        message: AppStrings.t('waiting_gopay_open_app_failed'),
      );
    }
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
            AppStrings.t('waiting_gopay_instruction'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () => _openGopay(context),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: Text(AppStrings.t('waiting_gopay_open_app_btn')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00AED6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('atau',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                qrCodeUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined,
                          size: 32, color: Colors.grey.shade400),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.t('waiting_gopay_qr_failed'),
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
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
