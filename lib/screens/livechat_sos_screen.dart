import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';

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
  final _msgCtrl = TextEditingController();
  late List<ChatMessage> _messages;
  late List<String> _quickReplies;

  @override
  void initState() {
    super.initState();
    _messages = [
      ChatMessage(
          text: AppStrings.t('chat_greeting'),
          isFromUser: false,
          time: DateTime.now().subtract(const Duration(minutes: 2))),
    ];
    _quickReplies = [
      'Baik, saya tunggu',
      'Saya di titik jemput',
      'Mohon tunggu sebentar',
      'Terima kasih'
    ];
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _send([String? quick]) {
    final text = quick ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages
          .add(ChatMessage(text: text, isFromUser: true, time: DateTime.now()));
      _msgCtrl.clear();
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
            text: AppStrings.t('chat_autoresponse'),
            isFromUser: false,
            time: DateTime.now()));
      });
    });
  }

  void _triggerSos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(AppStrings.t('chat_sos_dialog_title'))
          ],
        ),
        content: Text(AppStrings.t('chat_sos_dialog_msg')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.t('chat_sos_batal'))),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text(AppStrings.t('chat_sos_connecting'))),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(AppStrings.t('chat_sos_confirm')),
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
              CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.support_agent,
                      color: Colors.white, size: 18)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Support',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(AppStrings.t('chat_appbar_online'),
                      style:
                          const TextStyle(color: Colors.green, fontSize: 10)),
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
                label: Text(AppStrings.t('chat_sos_btn'),
                    style: const TextStyle(fontSize: 11)),
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
                          hintText: AppStrings.t('chat_input_hint'),
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
                        backgroundColor: AppColors.primary,
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

  Widget _buildBubble(ChatMessage m) {
    return Align(
      alignment: m.isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
            color: m.isFromUser ? AppColors.primary : Colors.white,
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
