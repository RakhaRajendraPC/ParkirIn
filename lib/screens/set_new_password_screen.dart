import 'package:flutter/material.dart';
import '../services/auth_api_service.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import 'auth_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String resetToken;

  const SetNewPasswordScreen({super.key, required this.resetToken});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _authApi = AuthApiService();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;
  String? _error;
  bool _tokenExpired = false;

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    _pass1Ctrl.dispose();
    _pass2Ctrl.dispose();
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (_pass1Ctrl.text.length < 8) {
      setState(() => _error = AppStrings.t('newpass_error_short'));
      return;
    }
    if (_pass1Ctrl.text != _pass2Ctrl.text) {
      setState(() => _error = AppStrings.t('newpass_error_mismatch'));
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _authApi.resetPassword(
        resetToken: widget.resetToken,
        newPassword: _pass1Ctrl.text,
      );
      if (!mounted) return;
      _showSuccessDialog();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _tokenExpired = e.statusCode == 400;
        _error = _tokenExpired
            ? AppStrings.t('newpass_error_token_expired')
            : e.message;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
                child: Text(AppStrings.t('newpass_success_title'),
                    style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Text(AppStrings.t('newpass_success_msg')),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppStrings.t('newpass_success_btn')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight, shape: BoxShape.circle),
                child: Icon(Icons.password_outlined,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.t('newpass_title'),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(AppStrings.t('newpass_subtitle'),
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600, height: 1.5)),
              const SizedBox(height: 24),
              _buildField(AppStrings.t('newpass_field1'), _pass1Ctrl, _obscure1,
                  () => setState(() => _obscure1 = !_obscure1)),
              const SizedBox(height: 14),
              _buildField(AppStrings.t('newpass_field2'), _pass2Ctrl, _obscure2,
                  () => setState(() => _obscure2 = !_obscure2)),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              if (_tokenExpired) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    child: Text(AppStrings.t('forgot_kembali_login'),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading || _tokenExpired ? null : _submit,
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
                      : Text(AppStrings.t('newpass_simpan_btn'),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, bool obscure,
      VoidCallback onToggle) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18),
          onPressed: onToggle,
        ),
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
