import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/main.dart';
import '../services/auth_api_service.dart';
import '../services/favorites_service.dart';
import '../services/user_session.dart';
import '../utils/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/coming_soon_badge.dart';
import 'otp_verification_screen.dart';
import 'terms_privacy_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authApiService = AuthApiService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Populates UserSession from a login/register response's embedded user
  /// object — that data is already returned by both calls, so this needs
  /// no extra network round-trip.
  void _applyUserFromResponse(Map<String, dynamic> response) {
    final user = response['user'] as Map<String, dynamic>?;
    if (user == null) return;
    UserSession.instance.name = user['name'] as String? ?? UserSession.instance.name;
    UserSession.instance.email = user['email'] as String? ?? UserSession.instance.email;
    UserSession.instance.phone = user['phone'] as String? ?? UserSession.instance.phone;
    UserSession.instance.save();
    // Best-effort refresh for this account — a prior session's reset() may
    // have cleared the cache, or a different account's data may still be
    // cached from before this login.
    FavoritesService.instance.load(force: true).catchError((_) {});
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (!_isLogin) {
        final phone = _phoneCtrl.text.trim();
        final response = await _authApiService.register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: phone,
          password: _passwordCtrl.text,
        );
        _applyUserFromResponse(response);
        // Trigger the actual OTP send so a code exists to verify next.
        await _authApiService.sendOtp(phone);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(contact: phone),
          ),
        );
      } else {
        final response = await _authApiService.login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
        _applyUserFromResponse(response);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RootShell()),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(
        context,
        severity: AppSeverity.destructive,
        message: e.message,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Row(
                children: [
                  Icon(Icons.airport_shuttle, color: primaryBlue, size: 32),
                  SizedBox(width: 8),
                  Text(
                    'ParkirIn',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                _isLogin ? 'Selamat Datang Kembali' : 'Buat Akun Baru',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _isLogin
                    ? 'Masuk untuk melanjutkan booking parkir Anda.'
                    : 'Daftar untuk mulai booking parkir inap bandara.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 28),
              if (!_isLogin) ...[
                _buildField('Nama Lengkap', _nameCtrl, Icons.person_outline),
                const SizedBox(height: 14),
              ],
              _buildField(
                'Email',
                _emailCtrl,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              // Registration requires both email and phone — the backend's
              // RegisterDto has no optional fields, and OTP verification
              // (POST /auth/otp/send, /otp/verify) is phone-only with no
              // email-based alternative. There is no "pick one" path today.
              if (!_isLogin) ...[
                _buildField(
                  'Nomor HP',
                  _phoneCtrl,
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  hint: '08xxxxxxxxxx',
                ),
                const SizedBox(height: 14),
              ],
              _buildField(
                'Password',
                _passwordCtrl,
                Icons.lock_outline,
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_isLogin) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    // No backend endpoint exists for password reset — the
                    // whole flow (OTP + set-new-password) is fake, never
                    // actually calls the backend, so it's disabled here
                    // rather than letting a user believe they changed their
                    // password when nothing was sent to the server.
                    onPressed: null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lupa Password?',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(width: 6),
                        const ComingSoonBadge(),
                      ],
                    ),
                  ),
                ),
              ],
              if (!_isLogin) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                      activeColor: primaryBlue,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                            children: [
                              const TextSpan(text: 'Saya menyetujui '),
                              TextSpan(
                                text: 'Syarat & Ketentuan',
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsPrivacyScreen(),
                                        ),
                                      ),
                              ),
                              const TextSpan(
                                text: ' dan Kebijakan Privasi ParkirIn.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || (!_isLogin && !_agreedToTerms))
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isLogin ? 'Masuk' : 'Daftar',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'atau',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 20),
              _buildSocialButton('Lanjutkan dengan Google', Icons.g_mobiledata),
              const SizedBox(height: 10),
              _buildSocialButton('Lanjutkan dengan Apple', Icons.apple),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: RichText(
                    text: TextSpan(
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      children: [
                        TextSpan(
                          text: _isLogin
                              ? 'Belum punya akun? '
                              : 'Sudah punya akun? ',
                        ),
                        TextSpan(
                          text: _isLogin ? 'Daftar' : 'Masuk',
                          style: const TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
