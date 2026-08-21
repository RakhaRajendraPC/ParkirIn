import 'package:flutter/material.dart';
import 'shuttle_tracking_screen.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedAirport = 'CGK - Soekarno Hatta';
  DateTime checkIn = DateTime(2026, 10, 12, 8, 0);
  DateTime checkOut = DateTime(2026, 10, 15, 18, 0);

  static const Color primaryBlue = Color(0xFF1E5EFF);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 56,
          leading: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.location_on_outlined, color: primaryBlue),
          ),
          title: const Text(
            'ParkirIn',
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEDEDED),
                child: Icon(Icons.person, color: Colors.grey, size: 18),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildSearchCard(),
              const SizedBox(height: 16),
              _buildSearchButton(),
              const SizedBox(height: 16),
              _buildPromoBanner(),
              const SizedBox(height: 24),
              _buildWhyChooseUsTitle(),
              const SizedBox(height: 12),
              _buildFeatureGrid(),
              const SizedBox(height: 12),
              _buildShuttleTracker(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF9CB9E8), Color(0xFFD9E4F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.flight_takeoff, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'PARK & FLY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          height: 1.3,
        ),
        children: [
          TextSpan(text: 'Solusi Parkir Inap\nBandara yang '),
          TextSpan(
            text: 'Aman & Mudah',
            style: TextStyle(color: primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Airport selector
          InkWell(
            onTap: _showAirportPicker,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flight, color: primaryBlue, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PILIH BANDARA',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedAirport,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          // Date row
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  icon: Icons.login,
                  iconColor: Colors.orange,
                  label: 'MASUK',
                  date: checkIn,
                  onTap: () => _pickDate(isCheckIn: true),
                ),
              ),
              Container(
                height: 36,
                width: 1,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _DateTile(
                  icon: Icons.logout,
                  iconColor: primaryBlue,
                  label: 'KELUAR',
                  date: checkOut,
                  onTap: () => _pickDate(isCheckIn: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(
                airportName: selectedAirport,
                checkIn: checkIn,
                checkOut: checkOut,
              ),
            ),
          );
        },
        icon: const Icon(Icons.search),
        label: const Text(
          'Cari Slot Parkir',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8A00),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B4FE0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PROMO PENGGUNA BARU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Diskon 20%',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    children: [
                      TextSpan(text: 'Gunakan kode: '),
                      TextSpan(
                        text: 'TERBANGAMAN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer_outlined, color: primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUsTitle() {
    return const Text(
      'Kenapa Pilih ParkirIn?',
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildFeatureGrid() {
    return Row(
      children: [
        Expanded(
          child: _FeatureCard(
            icon: Icons.verified_user_outlined,
            iconColor: Colors.green,
            title: 'Slot Terjamin',
            subtitle: 'Pasti dapat tempat, fasilitas aman 24/7.',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FeatureCard(
            icon: Icons.attach_money,
            iconColor: primaryBlue,
            title: 'Biaya Transparan',
            subtitle: 'Tanpa biaya tersembunyi saat checkout.',
          ),
        ),
      ],
    );
  }

  Widget _buildShuttleTracker() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShuttleTrackingScreen(
              bookingCode: 'PKR-88213',
              pickupPointName: 'Titik Jemput A - Lahan Parkir',
              destinationName: 'Terminal 3, CGK',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1E6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.airport_shuttle, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Lacak Shuttle Real-time',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pantau posisi bus jemputan langsung dari HP anda menuju terminal.',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ), // ⬅️ tutup Container
    ); // ⬅️ tutup InkWell
  } // ⬅️ tutup method

  void _showAirportPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final airports = [
          'CGK - Soekarno Hatta',
          'HLP - Halim Perdanakusuma',
          'SUB - Juanda Surabaya',
          'DPS - Ngurah Rai Bali',
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: airports
                .map((a) => ListTile(
                      title: Text(a),
                      onTap: () {
                        setState(() => selectedAirport = a);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn ? checkIn : checkOut;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    setState(() {
      final combined =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isCheckIn) {
        checkIn = combined;
      } else {
        checkOut = combined;
      }
    });
  }
}

class _DateTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.date,
    required this.onTap,
  });

  String get _formatted {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month]}, $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatted,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
