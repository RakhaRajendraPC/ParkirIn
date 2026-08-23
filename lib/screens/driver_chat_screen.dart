// lib/screens/driver_chat_screen.dart
import 'package:flutter/material.dart';

class DriverChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime time;

  DriverChatMessage(
      {required this.text, required this.isFromUser, required this.time});
}

class DriverChatScreen extends StatefulWidget {
  final String driverName;
  final String vehiclePlate;

  const DriverChatScreen(
      {super.key,
      this.driverName = 'Agus Wijaya',
      this.vehiclePlate = 'B 7788 KJ'});

  @override
  State<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final _msgCtrl = TextEditingController();

  final List<DriverChatMessage> _messages = [
    DriverChatMessage(
        text: 'Halo Bapak/Ibu, saya driver shuttle Anda hari ini 🙏',
        isFromUser: false,
        time: DateTime.now().subtract(const Duration(minutes: 3))),
    DriverChatMessage(
        text: 'Saya sedang menuju titik jemput, estimasi 5 menit lagi.',
        isFromUser: false,
        time: DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  final List<String> _quickReplies = [
    'Baik, saya tunggu',
    'Saya di titik jemput',
    'Mohon tunggu sebentar',
    'Terima kasih'
  ];

  void _send([String? quick]) {
    final text = quick ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(DriverChatMessage(
          text: text, isFromUser: true, time: DateTime.now()));
      _msgCtrl.clear();
    });
  }

  void _call() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hubungi Driver'),
        content: Text('Menelepon ${widget.driverName}...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFEDEDED),
                  child: Icon(Icons.person, color: Colors.grey, size: 18)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.driverName,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text('Shuttle ${widget.vehiclePlate}',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 10)),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: _call,
                icon: const Icon(Icons.call, color: primaryBlue)),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildBubble(_messages[index]),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ActionChip(
                  label: Text(_quickReplies[i],
                      style: const TextStyle(fontSize: 11)),
                  onPressed: () => _send(_quickReplies[i]),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2))
                ]),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan ke driver...',
                          filled: true,
                          fillColor: const Color(0xFFF2F3F5),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                        backgroundColor: primaryBlue,
                        child: IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.white, size: 18),
                            onPressed: () => _send())),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(DriverChatMessage m) {
    return Align(
      alignment: m.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
            color: m.isFromUser ? primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)
            ]),
        child: Text(m.text,
            style: TextStyle(
                color: m.isFromUser ? Colors.white : Colors.black87,
                fontSize: 13)),
      ),
    );
  }
}
