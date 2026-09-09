// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';
import '../services/favorites_service.dart';
import '../services/user_session.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_header_avatar.dart';
import '../widgets/parkirin_header_bar.dart';
import '../widgets/stub_icon.dart';
import 'accessibility_settings_screen.dart';
import 'auth_screen.dart';
import 'delete_account_screen.dart';
import 'favorites_screen.dart';
import 'help_center_screen.dart';
import 'invoice_history_screen.dart';
import 'language_settings_screen.dart';
import 'my_details_screen.dart';
import 'payment_methods_screen.dart';
import 'vehicles_screen.dart';

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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyDetailsScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: const ParkirInHeaderBar(actions: [AppHeaderAvatar()]),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildProfileHeader(),
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
                icon: Icons.directions_car_filled_rounded,
                color: AppColors.primary,
                title: AppStrings.t('profile_vehicles_title'),
                subtitle: AppStrings.t('profile_vehicles_sub'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VehiclesScreen())),
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
                icon: Icons.receipt_long_rounded,
                color: AppColors.primary,
                title: AppStrings.t('profile_invoice_title'),
                subtitle: AppStrings.t('profile_invoice_sub'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InvoiceHistoryScreen())),
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

  Widget _buildProfileHeader() {
    final hasPhoto =
        _session.avatarPath != null && File(_session.avatarPath!).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
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
                        fontSize: 11.5, color: Colors.white.withOpacity(0.8))),
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
          showAppSheet(
            context,
            severity: AppSeverity.neutral,
            icon: Icons.logout,
            title: AppStrings.t('profile_logout_confirm_title'),
            body: AppStrings.t('profile_logout_confirm_msg'),
            primaryLabel: AppStrings.t('profile_logout'),
            onPrimary: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            secondaryLabel: AppStrings.t('profile_cancel'),
            onSecondary: () => Navigator.pop(context),
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

  Future<void> _performLogout(BuildContext context) async {
    await AuthApiService().logout();
    // Clear cached favorites so the next login (possibly a different
    // account) doesn't briefly show this account's data before its own
    // load() completes.
    FavoritesService.instance.reset();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }
}
