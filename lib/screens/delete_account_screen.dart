// lib/screens/delete_account_screen.dart
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final Set<String> _selectedReasons = {};
  final _feedbackCtrl = TextEditingController();
  bool _confirmChecked = false;

  final List<String> _reasons = [
    'Tidak lagi membutuhkan layanan',
    'Menemukan alternatif lain',
    'Masalah privasi/keamanan',
    'Sulit digunakan',
    'Lainnya',
  ];

  void _requestDeletion() {
    if (!_confirmChecked) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Terakhir'),
        content: const Text(
          'Akun dan seluruh data pribadi Anda (riwayat booking, kendaraan, metode pembayaran) akan dihapus permanen dalam 30 hari. Tindakan ini tidak dapat dibatalkan setelah masa tenggang berakhir.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showRequestSubmitted();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Ajukan Penghapusan'),
          ),
        ],
      ),
    );
  }

  void _showRequestSubmitted() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Permintaan Diajukan'),
        content: const Text(
            'Kami telah menerima permintaan penghapusan akun Anda. Konfirmasi akan dikirim ke email terdaftar dalam 1x24 jam.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            style: FilledButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _requestDataExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Permintaan ekspor data dikirim. Anda akan menerima email berisi salinan data dalam 1x24 jam.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Hapus Akun & Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Row(
                children: [
                  const Icon(Icons.download_outlined, color: primaryBlue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unduh Data Saya',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Dapatkan salinan seluruh data pribadi Anda',
                            style:
                                TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  TextButton(
                      onPressed: _requestDataExport,
                      child:
                          const Text('Minta', style: TextStyle(fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Menghapus akun akan menghilangkan seluruh riwayat booking, poin loyalty, saldo wallet, dan data kendaraan Anda secara permanen.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Mengapa Anda ingin menghapus akun?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasons.map((r) {
                final selected = _selectedReasons.contains(r);
                return FilterChip(
                  label: Text(r, style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  onSelected: (v) => setState(() =>
                      v ? _selectedReasons.add(r) : _selectedReasons.remove(r)),
                  selectedColor: primaryBlue.withOpacity(0.15),
                  checkmarkColor: primaryBlue,
                  labelStyle:
                      TextStyle(color: selected ? primaryBlue : Colors.black87),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color:
                              selected ? primaryBlue : Colors.grey.shade300)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukan tambahan (opsional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: _confirmChecked,
              onChanged: (v) => setState(() => _confirmChecked = v ?? false),
              activeColor: Colors.redAccent,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                  'Saya memahami tindakan ini permanen dan tidak dapat dibatalkan',
                  style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _confirmChecked ? _requestDeletion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hapus Akun Saya',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
