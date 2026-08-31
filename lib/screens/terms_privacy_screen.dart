import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  static const String terms = '''
1. Definisi Layanan
ParkirIn adalah platform reservasi parkir inap bandara yang menghubungkan pengguna dengan mitra penyedia lahan parkir.

2. Ketentuan Booking
Booking dianggap sah setelah pembayaran berhasil diverifikasi. Pengguna wajib melakukan check-in sesuai jadwal yang dipesan.

3. Kebijakan Pembatalan
Pembatalan gratis dapat dilakukan minimal 24 jam sebelum jadwal check-in. Pembatalan setelah itu dikenakan biaya sesuai kebijakan mitra.

4. Biaya Tambahan (Overstay)
Keterlambatan pengambilan kendaraan dari jadwal check-out akan dikenakan biaya tambahan otomatis sesuai tarif yang berlaku.

5. Tanggung Jawab
Mitra parkir bertanggung jawab atas keamanan kendaraan selama masa penitipan sesuai dokumentasi kondisi kendaraan saat check-in.
''';

  static const String privacy = '''
1. Data yang Dikumpulkan
Kami mengumpulkan data nama, email, nomor telepon, plat kendaraan, dan riwayat transaksi untuk keperluan layanan booking.

2. Penggunaan Data
Data digunakan untuk memproses booking, notifikasi terkait perjalanan Anda, dan peningkatan layanan.

3. Berbagi Data
Data dibagikan kepada mitra parkir dan penyedia layanan pembayaran hanya sejauh diperlukan untuk memproses transaksi Anda.

4. Keamanan Data
Kami menerapkan enkripsi standar industri untuk melindungi data pribadi Anda dari akses yang tidak sah.

5. Hak Pengguna
Anda berhak mengakses, memperbarui, atau meminta penghapusan data pribadi Anda melalui menu My Details atau Help Center.
''';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Syarat & Ketentuan',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          bottom: TabBar(
            controller: _tab,
            labelColor: primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryBlue,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Syarat & Ketentuan'),
              Tab(text: 'Kebijakan Privasi')
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            _buildContent(terms),
            _buildContent(privacy),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String text) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Text(text.trim(),
          style: TextStyle(
              fontSize: 12, color: Colors.grey.shade800, height: 1.7)),
    );
  }
}
