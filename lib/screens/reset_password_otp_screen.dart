import 'dart:async';
import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../widgets/stub_icon.dart';
import 'set_new_password_screen.dart';

class ResetPasswordOtpScreen extends StatefulWidget {
  final String contact;

  const ResetPasswordOtpScreen({super.key, required this.contact});

  @override
  State<ResetPasswordOtpScreen> createState() => _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState extends State<ResetPasswordOtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    AppSettings.instance.removeListener(_onChanged);
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  String get _otpCode => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otpCode.length < 6) {
      setState(() => _error = AppStrings.t('resetotp_error'));
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isVerifying = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => SetNewPasswordScreen(contact: widget.contact)),
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StubIcon(
                  icon: Icons.sms_rounded, color: AppColors.primary, size: 60),
              const SizedBox(height: 22),
              Text(AppStrings.t('resetotp_title'),
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16181F),
                      letterSpacing: -0.3)),
              const SizedBox(height: 7),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  children: [
                    TextSpan(
                        text: '${AppStrings.t('resetotp_subtitle_prefix')} '),
                    TextSpan(
                        text: widget.contact,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16181F))),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                    6,
                    (i) => SizedBox(
                          width: 44,
                          height: 54,
                          child: TextField(
                            controller: _ctrls[i],
                            focusNode: _nodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16181F)),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFF7F8FA),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  borderSide: BorderSide(
                                      color: AppColors.primary, width: 1.8)),
                            ),
                            onChanged: (v) => _onOtpChanged(i, v),
                          ),
                        )),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 26),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        '${AppStrings.t('resetotp_resend_prefix')} 00:${_secondsLeft.toString().padLeft(2, '0')}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      )
                    : TextButton(
                        onPressed: _startTimer,
                        child: Text(AppStrings.t('resetotp_resend_btn'),
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800)),
                      ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(AppStrings.t('resetotp_verify_btn').toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
