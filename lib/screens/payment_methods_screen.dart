// lib/screens/payment_methods_screen.dart
import 'package:flutter/material.dart';
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
  static const Color primaryBlue = Color(0xFF1E5EFF);

  final List<SavedPaymentMethod> _methods = [
    SavedPaymentMethod(
        label: 'BCA Debit •••• 4821',
        subtitle: 'Kartu Debit',
        icon: Icons.credit_card,
        color: primaryBlue,
        isDefault: true),
    SavedPaymentMethod(
        label: 'GoPay',
        subtitle: 'E-Wallet · 0812-3456-7890',
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.teal),
    SavedPaymentMethod(
        label: 'QRIS',
        subtitle: 'Bayar via aplikasi bank/e-wallet apapun',
        icon: Icons.qr_code,
        color: Colors.orange),
  ];

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
          title: const Text('Payment Methods',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ..._methods.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCard(e.value, e.key),
                )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showAddSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Metode Pembayaran'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(color: primaryBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(SavedPaymentMethod m, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: m.isDefault ? Border.all(color: primaryBlue) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: m.color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(m.icon, color: m.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(m.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    if (m.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('UTAMA',
                            style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(m.subtitle,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black38),
            onSelected: (v) {
              if (v == 'default') _setDefault(index);
              if (v == 'remove') _remove(index);
            },
            itemBuilder: (context) => [
              if (!m.isDefault)
                const PopupMenuItem(
                    value: 'default',
                    child:
                        Text('Jadikan Utama', style: TextStyle(fontSize: 13))),
              const PopupMenuItem(
                  value: 'remove',
                  child: Text('Hapus',
                      style: TextStyle(fontSize: 13, color: Colors.redAccent))),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final options = <(String, IconData, Color, PaymentMethodType)>[
          (
            'Kartu Debit/Kredit',
            Icons.credit_card,
            primaryBlue,
            PaymentMethodType.card
          ),
          (
            'E-Wallet (GoPay/OVO/Dana)',
            Icons.account_balance_wallet_outlined,
            Colors.teal,
            PaymentMethodType.ewallet
          ),
          (
            'Virtual Account',
            Icons.account_balance_outlined,
            Colors.purple,
            PaymentMethodType.virtualAccount
          ),
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((o) => ListTile(
                      leading: Icon(o.$2, color: o.$3),
                      title: Text(o.$1, style: const TextStyle(fontSize: 13)),
                      onTap: () async {
                        Navigator.pop(context); // tutup bottom sheet dulu
                        final saved = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddPaymentMethodScreen(type: o.$4),
                          ),
                        );
                        if (saved == true && mounted) {
                          // Metode pembayaran baru berhasil disimpan (mock).
                          // Di production: refresh dari API/backend di sini.
                        }
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
