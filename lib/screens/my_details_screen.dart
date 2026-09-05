import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../widgets/coming_soon_badge.dart';

class MyDetailsScreen extends StatefulWidget {
  const MyDetailsScreen({super.key});

  @override
  State<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  final UserSession _session = UserSession.instance;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final _idCtrl = TextEditingController(text: '3171xxxxxxxxxxxx');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _session.name);
    _emailCtrl = TextEditingController(text: _session.email);
    _phoneCtrl = TextEditingController(text: _session.phone);
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _idCtrl.dispose();
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(AppStrings.t('mydetails_appbar_title'),
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                      radius: 42,
                      backgroundImage:
                          NetworkImage('https://i.pravatar.cc/150?img=12')),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(AppStrings.t('mydetails_section_personal'), [
              _field(AppStrings.t('mydetails_nama'), _nameCtrl,
                  Icons.person_outline),
              _field(AppStrings.t('mydetails_email'), _emailCtrl,
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              _field(AppStrings.t('mydetails_telepon'), _phoneCtrl,
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
            ]),
            const SizedBox(height: 16),
            _buildSection(AppStrings.t('mydetails_section_identitas'), [
              _field(AppStrings.t('mydetails_nomor_identitas'), _idCtrl,
                  Icons.badge_outlined),
            ]),
            const SizedBox(height: 16),
            _buildSection(AppStrings.t('mydetails_section_keamanan'), [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.lock_outline, color: Colors.grey.shade400),
                title: Row(
                  children: [
                    Text(AppStrings.t('mydetails_ubah_password'),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    const ComingSoonBadge(),
                  ],
                ),
                // No backend endpoint exists for changing a password yet —
                // disabled rather than opening a sheet whose "save" was a
                // no-op that silently discarded whatever was typed.
                onTap: null,
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                // No profile-update endpoint exists yet — disabled rather
                // than faking a successful save of local-only state.
                onPressed: null,
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.t('mydetails_simpan_btn'),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    const ComingSoonBadge(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

}
