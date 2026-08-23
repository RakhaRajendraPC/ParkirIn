// lib/screens/help_center_screen.dart
import 'package:flutter/material.dart';
import 'livechat_sos_screen.dart';
import 'report_issue_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E5EFF);

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Help Center',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
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
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Pertanyaan yang Sering Diajukan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Column(
                children: _faqs
                    .map((f) => ExpansionTile(
                          title: Text(f.$1,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.$2,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.5))
                          ],
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Masih Butuh Bantuan?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LiveChatSosScreen())),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  children: [
                    Icon(Icons.support_agent, color: primaryBlue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Live Chat 24 Jam',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('Terhubung dengan tim Customer Support kami',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.black38),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportIssueScreen())),
              child: Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14)),
                child: const Row(
                  children: [
                    Icon(Icons.report_gmailerrorred_outlined,
                        color: Colors.redAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Lapor Masalah / Komplain',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
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
