// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/search_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/splash_onboarding_screen.dart';
import 'services/app_settings.dart'; // Sudah mencakup AppSettings dan AppStrings
import 'services/notification_repository.dart';
import 'services/notification_preferences.dart';
import 'widgets/floating_notification_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  await NotificationPreferences.instance.load();
  runApp(const ParkirInApp());
}

class ParkirInApp extends StatefulWidget {
  const ParkirInApp({super.key});

  @override
  State<ParkirInApp> createState() => _ParkirInAppState();
}

class _ParkirInAppState extends State<ParkirInApp> {
  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final highContrast = settings.highContrast;

    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E5EFF),
      primary: highContrast ? const Color(0xFF0033CC) : const Color(0xFF1E5EFF),
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E5EFF),
      brightness: Brightness.dark,
      primary: highContrast ? const Color(0xFF6E9BFF) : const Color(0xFF5C8DFF),
    );

    return MaterialApp(
      navigatorKey: NotificationBannerHost.navigatorKey,
      title: 'ParkirIn',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: lightScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: darkScheme,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
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
  final NotificationRepository _notifRepo = NotificationRepository.instance;

  @override
  void initState() {
    super.initState();
    _notifRepo.addListener(_onNotifChanged);
  }

  @override
  void dispose() {
    _notifRepo.removeListener(_onNotifChanged);
    super.dispose();
  }

  void _onNotifChanged() {
    if (mounted) setState(() {});
  }

  final List<Widget> _pages = const [
    SearchScreen(),
    BookingsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.search, labelKey: 'nav_search'),
    _NavItem(
        icon: Icons.confirmation_number_outlined, labelKey: 'nav_bookings'),
    _NavItem(icon: Icons.notifications_none_rounded, labelKey: 'nav_alerts'),
    _NavItem(icon: Icons.person_outline, labelKey: 'nav_profile'),
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
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
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
                          if (item.labelKey == 'nav_alerts' &&
                              _notifRepo.unreadCount > 0)
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
                        AppStrings.t(item.labelKey),
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
  final String labelKey;

  const _NavItem({
    required this.icon,
    required this.labelKey,
  });
}
