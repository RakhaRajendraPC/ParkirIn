// lib/screens/promo_code_screen.dart
import 'package:flutter/material.dart';

class PromoVoucher {
  final String code;
  final String title;
  final String description;
  final String expiry;
  final bool isPercentage;
  final double value; // persen atau nominal rupiah

  const PromoVoucher({
    required this.code,
    required this.title,
    required this.description,
    required this.expiry,
    required this.isPercentage,
    required this.value,
  });
}

/// Halaman daftar voucher milik pelanggan. Bisa dibuka dari Profile atau
/// dari BookingSummaryScreen untuk menerapkan kode saat checkout (§6.3, Fase 2).
class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final _codeCtrl = TextEditingController();
  String? _errorText;

  final List<PromoVoucher> _vouchers = const [
    PromoVoucher(
        code: 'TERBANGAMAN',
        title: 'Diskon 20% Pengguna Baru',
        description:
            'Berlaku untuk booking pertama Anda, maksimal potongan Rp 50.000.',
        expiry: 'Berlaku s/d 31 Okt 2026',
        isPercentage: true,
        value: 20),
    PromoVoucher(
        code: 'WEEKEND20',
        title: 'Diskon Akhir Pekan',
        description:
            'Potongan 20% untuk booking check-in di hari Sabtu/Minggu.',
        expiry: 'Berlaku s/d 30 Sep 2026',
        isPercentage: true,
        value: 20),
    PromoVoucher(
        code: 'HEMAT10K',
        title: 'Potongan Rp 10.000',
        description: 'Minimal transaksi Rp 100.000.',
        expiry: 'Berlaku s/d 15 Sep 2026',
        isPercentage: false,
        value: 10000),
  ];

  void _applyManualCode() {
    final code = _codeCtrl.text.trim().toUpperCase();
    final match = _vouchers.where((v) => v.code == code).toList();
    if (match.isEmpty) {
      setState(() =>
          _errorText = 'Kode promo tidak ditemukan atau sudah tidak berlaku');
      return;
    }
    setState(() => _errorText = null);
    Navigator.pop(context, match.first);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Kode Promo & Voucher',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode promo',
                      filled: true,
                      fillColor: Colors.white,
                      errorText: _errorText,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _applyManualCode,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Pakai'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Voucher Tersedia',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._vouchers.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildVoucherCard(v),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard(PromoVoucher v) {
    return InkWell(
      onTap: () => Navigator.pop(context, v),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.local_offer, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(v.description,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(v.code,
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue)),
                      ),
                      const SizedBox(width: 6),
                      Text(v.expiry,
                          style: TextStyle(
                              fontSize: 9, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
