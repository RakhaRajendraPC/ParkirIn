import 'dart:io';
import 'package:flutter/material.dart';
import '../services/user_session.dart';
import '../screens/profile_screen.dart';

class AppHeaderAvatar extends StatefulWidget {
  const AppHeaderAvatar({super.key});

  @override
  State<AppHeaderAvatar> createState() => _AppHeaderAvatarState();
}

class _AppHeaderAvatarState extends State<AppHeaderAvatar> {
  final UserSession _session = UserSession.instance;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final path = _session.avatarPath;
    final hasPhoto = path != null && path.isNotEmpty && File(path).existsSync();

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ProfileScreen())),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFFEDEDED),
          backgroundImage: hasPhoto ? FileImage(File(path)) : null,
          child: hasPhoto
              ? null
              : const Icon(Icons.person, color: Colors.grey, size: 18),
        ),
      ),
    );
  }
}
