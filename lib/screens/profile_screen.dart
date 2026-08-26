// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/user_session.dart';
import 'accessibility_settings_screen.dart';
import 'delete_account_screen.dart';
import 'favorites_screen.dart';
import 'help_center_screen.dart';
import 'language_settings_screen.dart';
import 'my_details_screen.dart';
import 'payment_methods_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final UserSession _session = UserSession.instance;

  Future<void> _openMyDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyDetailsScreen()),
    );
    setState(() {}); // refresh tampilan setelah kembali jika ada perubahan data
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
            'Profile',
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEDEDED),
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/100?img=12',
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildMenuTile(
                icon: Icons.person_outline,
                iconColor: primaryBlue,
                title: 'My Details',
                subtitle: 'Personal info, ID, password',
                onTap: _openMyDetails,
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.credit_card,
                iconColor: primaryBlue,
                title: 'Payment Methods',
                subtitle: 'Cards, e-wallets, bank transfer',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentMethodsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.favorite_border,
                iconColor: Colors.redAccent,
                title: 'Favorit Saya',
                subtitle: 'Lokasi parkir yang Anda simpan',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.help_outline,
                iconColor: Colors.teal,
                title: 'Help Center',
                subtitle: 'FAQs, contact support',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpCenterScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.accessibility_new_outlined,
                iconColor: primaryBlue,
                title: 'Aksesibilitas',
                subtitle: 'Ukuran teks & kontras tinggi',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccessibilitySettingsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.language_outlined,
                iconColor: primaryBlue,
                title: 'Bahasa',
                subtitle: 'Indonesia / English',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSettingsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.delete_outline,
                iconColor: Colors.redAccent,
                title: 'Hapus Akun & Data',
                subtitle: 'Kelola atau hapus data pribadi Anda',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeleteAccountScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=12'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _session.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            _session.email,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  'Gold Member',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB8860B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Apakah anda yakin ingin keluar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
