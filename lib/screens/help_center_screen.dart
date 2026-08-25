// lib/screens/help_center_screen.dart
import 'package:flutter/material.dart';
import 'livechat_sos_screen.dart';
import 'report_issue_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  static const List<(String, String)> _faqs = [
    (
      'Bagaimana cara membatalkan booking?',
      'Buka menu Bookings > pilih booking aktif > Reschedule/Batalkan. Pembatalan gratis jika dilakukan minimal 24 jam sebelum jadwal check-in.'
    ),
    (
      'Apa yang terjadi jika saya terlambat check-out?',
      'Sistem akan menghitung biaya tambahan (overstay fee) secara otomatis berdasarkan durasi keterlambatan. Anda akan menerima notifikasi peringatan sebelum batas waktu habis.'
    ),
    (
      'Bagaimana jika kendaraan saya rusak selama dititipkan?',
      'Kami mendokumentasikan foto kondisi kendaraan saat check-in dan check-out sebagai bukti klaim. Hubungi Customer Support untuk proses klaim lebih lanjut.'
    ),
    (
      'Apakah saya bisa mengubah metode pembayaran?',
      'Ya, kelola metode pembayaran Anda di menu Profile > Payment Methods.'
    ),
    (
      'Bagaimana cara melacak shuttle?',
      'Buka detail booking aktif Anda, lalu tekan tombol "Lacak Shuttle" untuk melihat posisi dan estimasi waktu kedatangan secara real-time.'
    ),
  ];

  List<(String, String)> get _filteredFaqs {
    if (_query.trim().isEmpty) return _faqs;
    final q = _query.toLowerCase();
    return _faqs
        .where((f) =>
            f.$1.toLowerCase().contains(q) || f.$2.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Help Center',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _query.isEmpty
                  ? 'Pertanyaan yang Sering Diajukan'
                  : 'Hasil untuk "$_query" (${_filteredFaqs.length})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_filteredFaqs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ditemukan pertanyaan yang cocok',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: _filteredFaqs
                      .map(
                        (f) => ExpansionTile(
                          title: Text(
                            f.$1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.$2,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Masih Butuh Bantuan?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveChatSosScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.support_agent, color: primaryBlue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Chat 24 Jam',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Terhubung dengan tim Customer Support kami',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.black38),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportIssueScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.report_gmailerrorred_outlined,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lapor Masalah / Komplain',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.black38),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
