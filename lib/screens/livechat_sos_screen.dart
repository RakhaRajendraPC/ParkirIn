// lib/screens/livechat_sos_screen.dart
import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime time;

  ChatMessage(
      {required this.text, required this.isFromUser, required this.time});
}

class LiveChatSosScreen extends StatefulWidget {
  const LiveChatSosScreen({super.key});

  @override
  State<LiveChatSosScreen> createState() => _LiveChatSosScreenState();
}

class _LiveChatSosScreenState extends State<LiveChatSosScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
        text:
            'Halo Budi! Ada yang bisa kami bantu terkait booking parkir Anda?',
        isFromUser: false,
        time: DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages
          .add(ChatMessage(text: text, isFromUser: true, time: DateTime.now()));
      _msgCtrl.clear();
    });
    // Simulasi balasan otomatis dari CS (production: integrasi live chat/chatbot §6.9).
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          text:
              'Terima kasih atas pesannya. Tim kami akan segera membantu Anda.',
          isFromUser: false,
          time: DateTime.now(),
        ));
      });
    });
  }

  void _triggerSos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Panggilan Darurat (SOS)')
          ],
        ),
        content: const Text(
            'Ini akan menghubungkan Anda langsung dengan petugas keamanan/hotline darurat di lokasi parkir. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text('Menghubungkan ke petugas darurat...')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Ya, Hubungi Sekarang'),
          ),
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
                  backgroundColor: primaryBlue,
                  child:
                      Icon(Icons.support_agent, color: Colors.white, size: 18)),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Support',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text('Online 24 Jam',
                      style: TextStyle(color: Colors.green, fontSize: 10)),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: _triggerSos,
                icon: const Icon(Icons.sos, size: 16),
                label: const Text('SOS', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildBubble(_messages[index]),
              ),
            ),
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
                          hintText: 'Tulis pesan...',
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
                          onPressed: _send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage m) {
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
          ],
        ),
        child: Text(
          m.text,
          style: TextStyle(
              color: m.isFromUser ? Colors.white : Colors.black87,
              fontSize: 13),
        ),
      ),
    );
  }
}
