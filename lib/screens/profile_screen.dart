// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'accessibility_settings_screen.dart';
import 'delete_account_screen.dart';
import 'favorites_screen.dart';
import 'help_center_screen.dart';
import 'language_settings_screen.dart';
import 'my_details_screen.dart';
import 'payment_methods_screen.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/app_header_avatar.dart';
import '../widgets/stub_icon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserSession _session = UserSession.instance;

  @override
  void initState() {
    super.initState();
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

  Future<void> _openMyDetails() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const MyDetailsScreen()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Padding(
              padding: EdgeInsets.only(left: 0),
              child: AppLogoBadge(height: 38)),
          leadingWidth: 160,
          title: null,
          centerTitle: true,
          actions: const [AppHeaderAvatar()],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildMembershipCard(),
              const SizedBox(height: 22),
              _buildSectionLabel('AKUN'),
              const SizedBox(height: 10),
              _buildMenuTile(
                icon: Icons.person_rounded,
                color: AppColors.primary,
                title: AppStrings.t('profile_my_details_title'),
                subtitle: AppStrings.t('profile_my_details_sub'),
                onTap: _openMyDetails,
              ),
              const SizedBox(height: 10),
              _buildMenuTile(
                icon: Icons.credit_card_rounded,
                color: AppColors.primary,
                title: AppStrings.t('profile_payment_title'),
                subtitle: AppStrings.t('profile_payment_sub'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentMethodsScreen())),
              ),
              const SizedBox(height: 10),
              _buildMenuTile(
                icon: Icons.favorite_rounded,
                color: const Color(0xFFE1306C),
                title: AppStrings.t('profile_favorites_title'),
                subtitle: AppStrings.t('profile_favorites_sub'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoritesScreen())),
              ),
              const SizedBox(height: 20),
              _buildSectionLabel('PREFERENSI'),
              const SizedBox(height: 10),
              _buildMenuTile(
                icon: Icons.help_rounded,
                color: const Color(0xFF00A896),
                title: AppStrings.t('profile_help_title'),
                subtitle: AppStrings.t('profile_help_sub'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen())),
              ),
              const SizedBox(height: 10),
              _buildMenuTile(
                icon: Icons.accessibility_new_rounded,
                color: AppColors.primary,
                title: AppStrings.t('profile_accessibility_title'),
                subtitle: AppStrings.t('profile_accessibility_sub'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AccessibilitySettingsScreen())),
              ),
              const SizedBox(height: 10),
              _buildMenuTile(
                icon: Icons.language_rounded,
                color: AppColors.primary,
                title: AppStrings.t('profile_language_title'),
                subtitle: AppStrings.t('profile_language_sub'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LanguageSettingsScreen())),
              ),
              const SizedBox(height: 20),
              _buildSectionLabel('LAINNYA'),
              const SizedBox(height: 10),
              _buildMenuTile(
                icon: Icons.delete_rounded,
                color: const Color(0xFFDC2626),
                title: AppStrings.t('profile_delete_account_title'),
                subtitle: AppStrings.t('profile_delete_account_sub'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DeleteAccountScreen())),
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

  Widget _buildMembershipCard() {
    final hasPhoto =
        _session.avatarPath != null && File(_session.avatarPath!).existsSync();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5), width: 1.5)),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    backgroundImage:
                        hasPhoto ? FileImage(File(_session.avatarPath!)) : null,
                    child: hasPhoto
                        ? null
                        : const Icon(Icons.person_rounded,
                            color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_session.name,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2)),
                      const SizedBox(height: 3),
                      Text(_session.email,
                          style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashLightPainter()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Colors.amber, size: 15),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.t('profile_gold_member').toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6),
                ),
                const Spacer(),
                Text(
                  'ID: PKR-USR-001',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 9.5,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 1)),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              StubIcon(icon: icon, color: color, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: Color(0xFF16181F))),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade300, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(AppStrings.t('profile_logout_confirm_title')),
              content: Text(AppStrings.t('profile_logout_confirm_msg')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppStrings.t('profile_cancel'))),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.t('profile_logout'),
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFECACA)),
          backgroundColor: const Color(0xFFFEF2F2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: Color(0xFFDC2626), size: 18),
            const SizedBox(width: 8),
            Text(AppStrings.t('profile_logout'),
                style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}

/// Garis putus-putus terang, versi "perforasi" untuk dipakai di atas
/// background gelap (kartu membership gradient).
class _DashLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
