import 'dart:async';
import 'package:flutter/material.dart';
import '/main.dart' show RootShell;

class OtpVerificationScreen extends StatefulWidget {
  final String contact;

  const OtpVerificationScreen({super.key, required this.contact});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
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
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otpCode.length < 6) {
      setState(() => _error = 'Masukkan 6 digit kode OTP');
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isVerifying = false);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RootShell()),
        (route) => false);
  }

  void _onChanged(int index, String value) {
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.sms_outlined,
                    color: primaryBlue, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('Verifikasi Kode OTP',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  children: [
                    const TextSpan(text: 'Kode verifikasi telah dikirim ke '),
                    TextSpan(
                        text: widget.contact,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                    6,
                    (i) => SizedBox(
                          width: 44,
                          height: 52,
                          child: TextField(
                            controller: _ctrls[i],
                            focusNode: _nodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: primaryBlue, width: 2)),
                            ),
                            onChanged: (v) => _onChanged(i, v),
                          ),
                        )),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 24),
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Kirim ulang kode dalam 00:${_secondsLeft.toString().padLeft(2, '0')}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600))
                    : TextButton(
                        onPressed: _startTimer,
                        child: const Text('Kirim Ulang Kode',
                            style: TextStyle(
                                fontSize: 12,
                                color: primaryBlue,
                                fontWeight: FontWeight.w600)),
                      ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verify,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Verifikasi',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
