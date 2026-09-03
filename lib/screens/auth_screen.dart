// lib/screens/auth_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '/main.dart';
import 'otp_verification_screen.dart';
import 'terms_privacy_screen.dart';
import 'forgot_password_screen.dart';
import '../widgets/stub_icon.dart';

enum _RegisterMethod { email, phone }

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
  _RegisterMethod _registerMethod = _RegisterMethod.email;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!_isLogin) {
      final contact = _registerMethod == _RegisterMethod.email
          ? _emailCtrl.text.trim()
          : _phoneCtrl.text.trim();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(contact: contact)));
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RootShell()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 0),
              Center(
                child: Image.asset('assets/logo/logo_inapandara_color.png',
                    height: 160, fit: BoxFit.cover),
              ),
              const SizedBox(height: 0),
              Text(
                _isLogin ? 'Selamat Datang Kembali' : 'Buat Akun Baru',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Color(0xFF16181F)),
              ),
              const SizedBox(height: 6),
              Text(
                _isLogin
                    ? 'Masuk untuk melanjutkan booking parkir Anda.'
                    : 'Daftar untuk mulai booking parkir inap bandara.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isLogin) ...[
                      _buildField('Nama Lengkap', _nameCtrl,
                          Icons.person_outline_rounded),
                      const SizedBox(height: 14),
                      _buildRegisterMethodToggle(),
                      const SizedBox(height: 14),
                    ],
                    if (_isLogin || _registerMethod == _RegisterMethod.email)
                      _buildField(
                          'Email', _emailCtrl, Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress)
                    else
                      _buildField('Nomor HP', _phoneCtrl, Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          hint: '08xxxxxxxxxx'),
                    const SizedBox(height: 14),
                    _buildField(
                      'Password',
                      _passwordCtrl,
                      Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 19,
                            color: Colors.grey.shade500),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    if (_isLogin) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen())),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Lupa Password?',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                    if (!_isLogin) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (v) =>
                                  setState(() => _agreedToTerms = v ?? false),
                              activeColor: primaryBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade700,
                                      height: 1.4),
                                  children: [
                                    const TextSpan(text: 'Saya menyetujui '),
                                    TextSpan(
                                      text: 'Syarat & Ketentuan',
                                      style: const TextStyle(
                                          color: primaryBlue,
                                          fontWeight: FontWeight.w700),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const TermsPrivacyScreen())),
                                    ),
                                    const TextSpan(
                                        text:
                                            ' & Kebijakan Privasi Inapandara.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: (_isLoading || (!_isLogin && !_agreedToTerms))
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(_isLogin ? 'MASUK' : 'DAFTAR',
                          style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 16,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const PerforationDivider(),
                    Container(
                      color: const Color(0xFFF7F8FA),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('ATAU',
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                              letterSpacing: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSocialButton(
                  'Lanjutkan dengan Google', Icons.g_mobiledata_rounded),
              const SizedBox(height: 10),
              _buildSocialButton('Lanjutkan dengan Apple', Icons.apple_rounded),
              const SizedBox(height: 22),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 12.5, color: Colors.grey.shade700),
                      children: [
                        TextSpan(
                            text: _isLogin
                                ? 'Belum punya akun? '
                                : 'Sudah punya akun? '),
                        TextSpan(
                            text: _isLogin ? 'Daftar' : 'Masuk',
                            style: const TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterMethodToggle() {
    Widget chip(String label, IconData icon, _RegisterMethod method) {
      final selected = _registerMethod == method;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _registerMethod = method),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? primaryBlue.withOpacity(0.08)
                  : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selected ? primaryBlue : Colors.transparent,
                  width: 1.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16,
                    color: selected ? primaryBlue : Colors.grey.shade500),
                const SizedBox(width: 7),
                Text(label,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: selected ? primaryBlue : Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Email', Icons.mail_outline_rounded, _RegisterMethod.email),
        const SizedBox(width: 10),
        chip('Nomor HP', Icons.phone_outlined, _RegisterMethod.phone),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false,
      Widget? suffix,
      TextInputType? keyboardType,
      String? hint}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF16181F)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 19, color: Colors.grey.shade500),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 20, color: const Color(0xFF16181F)),
        label: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16181F))),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade200, width: 1.3),
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }
}
