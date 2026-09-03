import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../widgets/stub_icon.dart';
import 'add_payment_method_screen.dart';

class SavedPaymentMethod {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  bool isDefault;

  SavedPaymentMethod(
      {required this.label,
      required this.subtitle,
      required this.icon,
      required this.color,
      this.isDefault = false});
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late final List<SavedPaymentMethod> _methods;

  @override
  void initState() {
    super.initState();
    _methods = [
      SavedPaymentMethod(
          label: 'BCA Debit •••• 4821',
          subtitle: 'Kartu Debit',
          icon: Icons.credit_card_rounded,
          color: AppColors.primary,
          isDefault: true),
      SavedPaymentMethod(
          label: 'GoPay',
          subtitle: 'E-Wallet · 0812-3456-7890',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF0EA5A4)),
      SavedPaymentMethod(
          label: 'QRIS',
          subtitle: 'Bayar via aplikasi bank/e-wallet apapun',
          icon: Icons.qr_code_rounded,
          color: const Color(0xFFFF8A00)),
    ];
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

  void _setDefault(int index) {
    setState(() {
      for (var i = 0; i < _methods.length; i++) {
        _methods[i].isDefault = i == index;
      }
    });
  }

  void _remove(int index) {
    setState(() => _methods.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(AppStrings.t('payment_appbar_title'),
              style: const TextStyle(
                  color: Color(0xFF16181F),
                  fontWeight: FontWeight.w800,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._methods.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCard(e.value, e.key))),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => _showAddSheet(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withOpacity(0.4), width: 1.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(AppStrings.t('payment_tambah_btn'),
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

  Widget _buildCard(SavedPaymentMethod m, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: m.isDefault ? Border.all(color: m.color, width: 1.3) : null,
        boxShadow: [
          BoxShadow(
              color: m.color.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            StubIcon(icon: m.icon, color: m.color, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(m.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: Color(0xFF16181F))),
                      if (m.isDefault) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: m.color,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(AppStrings.t('payment_utama_badge'),
                              style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(m.subtitle,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
              onSelected: (v) {
                if (v == 'default') _setDefault(index);
                if (v == 'remove') _remove(index);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                if (!m.isDefault)
                  PopupMenuItem(
                      value: 'default',
                      child: Text(AppStrings.t('payment_jadikan_utama'),
                          style: const TextStyle(fontSize: 13))),
                PopupMenuItem(
                    value: 'remove',
                    child: Text(AppStrings.t('payment_hapus'),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.redAccent))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final options = <(String, IconData, Color, PaymentMethodType)>[
          (
            AppStrings.t('payment_kartu'),
            Icons.credit_card_rounded,
            AppColors.primary,
            PaymentMethodType.card
          ),
          (
            AppStrings.t('payment_ewallet'),
            Icons.account_balance_wallet_rounded,
            const Color(0xFF0EA5A4),
            PaymentMethodType.ewallet
          ),
          (
            AppStrings.t('payment_va'),
            Icons.account_balance_rounded,
            const Color(0xFF7C3AED),
            PaymentMethodType.virtualAccount
          ),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 18),
                ...options.map((o) => InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddPaymentMethodScreen(type: o.$4)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            StubIcon(icon: o.$2, color: o.$3, size: 40),
                            const SizedBox(width: 13),
                            Text(o.$1,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16181F))),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
