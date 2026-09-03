// lib/screens/splash_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'notification_permission_screen.dart';
import '../widgets/stub_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: FadeTransition(
        opacity: _fadeController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo/logo_inapandara_white.jpeg',
                width: 480,
                height: 260,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 100,
                height: 1,
                child: CustomPaint(painter: _DashLightPainter()),
              ),
              const SizedBox(height: 14),
              Text(
                'BOOKING PARKIR INAP BANDARA',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
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

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final String? imagePath;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    this.imagePath,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final PageController _controller = PageController();
  int _index = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.search_rounded,
      title: 'Cari & Bandingkan Slot Parkir',
      description:
          'Temukan lahan parkir inap terdekat dari bandara Anda dengan harga transparan dan slot terjamin.',
      accent: primaryBlue,
    ),
    OnboardingPage(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Check-in Tanpa Kontak',
      description:
          'Cukup tunjukkan QR Code untuk check-in dan check-out kendaraan Anda, cepat dan higienis.',
      accent: Color(0xFF16A34A),
    ),
    OnboardingPage(
      icon: Icons.directions_bus_filled_rounded,
      title: 'Lacak Shuttle Real-time',
      description:
          'Pantau posisi shuttle jemputan langsung dari HP Anda menuju terminal keberangkatan.',
      accent: Color(0xFFFF8A00),
    ),
  ];

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPermissionScreen(
          onContinue: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const AuthScreen()));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _pages[_index];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text('LEWATI',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        p.imagePath != null
                            ? Image.asset(p.imagePath!,
                                height: 180, fit: BoxFit.contain)
                            : StubIcon(icon: p.icon, color: p.accent, size: 88),
                        const SizedBox(height: 34),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16181F),
                              letterSpacing: -0.3,
                              height: 1.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.55),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 7,
                  height: 5,
                  decoration: BoxDecoration(
                    color: active ? _pages[i].accent : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: current.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _index == _pages.length - 1
                            ? 'MULAI SEKARANG'
                            : 'LANJUT',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
