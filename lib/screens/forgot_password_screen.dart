import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'reset_password_otp_screen.dart';

final RegExp _phonePattern = RegExp(r'^[0-9]{9,15}$');

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _authApi = AuthApiService();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    final phone = _phoneCtrl.text.trim();
    if (!_phonePattern.hasMatch(phone)) {
      setState(() => _error = AppStrings.t('forgot_invalid_phone_error'));
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authApi.forgotPassword(phone);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResetPasswordOtpScreen(phone: phone)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.statusCode == 404
            ? AppStrings.t('forgot_not_found_error')
            : e.message;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle),
                child: Icon(Icons.lock_reset_outlined,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.t('forgot_title'),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                AppStrings.t('forgot_subtitle'),
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildField(AppStrings.t('forgot_phone_label'), _phoneCtrl,
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hint: AppStrings.t('forgot_phone_hint')),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(AppStrings.t('forgot_kirim_kode_btn'),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.t('forgot_kembali_login'),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType? keyboardType, String? hint}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
