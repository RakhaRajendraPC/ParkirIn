import 'package:flutter/material.dart';
import 'screens/search_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/splash_onboarding_screen.dart';

void main() {
  runApp(const ParkirInApp());
}

class ParkirInApp extends StatelessWidget {
  const ParkirInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkirIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E5EFF),
          primary: const Color(0xFF1E5EFF),
        ),
      ),
      home:
          const SplashScreen(), // ⬅️ diubah dari RootShell() ke SplashScreen()
    );
  }
}

/// RootShell holds the bottom navigation and swaps between the 4 tabs:
/// Search, Bookings, Alerts (Notifications), Profile.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SearchScreen(),
    BookingsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.search, label: 'Search'),
    _NavItem(icon: Icons.confirmation_number_outlined, label: 'Bookings'),
    _NavItem(
        icon: Icons.notifications_none_rounded, label: 'Alerts', showDot: true),
    _NavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final bool selected = index == _currentIndex;
              final Color color =
                  selected ? const Color(0xFF1E5EFF) : Colors.grey.shade500;
              return InkWell(
                onTap: () => setState(() => _currentIndex = index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(item.icon, color: color, size: 24),
                          if (item.showDot)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final bool showDot;

  const _NavItem(
      {required this.icon, required this.label, this.showDot = false});
}
