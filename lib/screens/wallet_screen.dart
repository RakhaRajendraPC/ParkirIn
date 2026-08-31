import 'package:flutter/material.dart';

class WalletTransaction {
  final String title;
  final double amount;
  final DateTime date;

  const WalletTransaction(
      {required this.title, required this.amount, required this.date});
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E5EFF);
  static const double balance = 75000;

  static final List<WalletTransaction> _history = [
    WalletTransaction(
        title: 'Bonus referral - Andi berhasil booking',
        amount: 25000,
        date: DateTime.now().subtract(const Duration(days: 2))),
    WalletTransaction(
        title: 'Bonus referral - Sinta berhasil booking',
        amount: 25000,
        date: DateTime.now().subtract(const Duration(days: 6))),
    WalletTransaction(
        title: 'Digunakan untuk booking PKR-88213',
        amount: -25000,
        date: DateTime.now().subtract(const Duration(days: 8))),
    WalletTransaction(
        title: 'Bonus referral - Doni berhasil booking',
        amount: 25000,
        date: DateTime.now().subtract(const Duration(days: 15))),
    WalletTransaction(
        title: 'Bonus pendaftaran akun baru',
        amount: 25000,
        date: DateTime.now().subtract(const Duration(days: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Wallet Saya',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [primaryBlue, Color(0xFF3D7BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Saldo Wallet',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Rp ${balance.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                      'Saldo dapat digunakan otomatis saat pembayaran booking',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                    child: Text('Riwayat Transaksi',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))),
                TextButton(
                    onPressed: () {},
                    child: const Text('Lihat Semua',
                        style: TextStyle(fontSize: 11, color: primaryBlue))),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Column(
                children: _history.map((t) {
                  final isPositive = t.amount > 0;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: (isPositive ? Colors.green : Colors.redAccent)
                              .withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Icon(
                          isPositive
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 16,
                          color: isPositive ? Colors.green : Colors.redAccent),
                    ),
                    title: Text(t.title,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${t.date.day}/${t.date.month}/${t.date.year}',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500)),
                    trailing: Text(
                      '${isPositive ? '+' : ''}Rp ${t.amount.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.redAccent),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
