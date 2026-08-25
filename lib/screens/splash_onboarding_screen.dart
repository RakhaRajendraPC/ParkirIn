// lib/screens/splash_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'notification_permission_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Center(
        child: Image.asset(
          'assets/logo/logo_parkirin_white.png',
          width: 480,
          height: 480,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final String? imagePath;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
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
      icon: Icons.search,
      title: 'Cari & Bandingkan Slot Parkir',
      description:
          'Temukan lahan parkir inap terdekat dari bandara Anda dengan harga transparan dan slot terjamin.',
    ),
    OnboardingPage(
      icon: Icons.qr_code_scanner,
      title: 'Check-in Tanpa Kontak',
      description:
          'Cukup scan QR Code untuk check-in dan check-out kendaraan Anda, cepat dan higienis.',
    ),
    OnboardingPage(
      icon: Icons.directions_bus_filled,
      title: 'Lacak Shuttle Real-time',
      description:
          'Pantau posisi shuttle jemputan langsung dari HP Anda menuju terminal keberangkatan.',
    ),
  ];

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPermissionScreen(
          onContinue: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child:
                    const Text('Lewati', style: TextStyle(color: Colors.grey)),
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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        p.imagePath != null
                            ? Image.asset(
                                p.imagePath!,
                                height: 180,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    Icon(p.icon, size: 56, color: primaryBlue),
                              ),
                        const SizedBox(height: 32),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index ? primaryBlue : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _index == _pages.length - 1 ? 'Mulai Sekarang' : 'Lanjut',
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
