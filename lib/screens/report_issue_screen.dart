// lib/screens/report_issue_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_toast.dart';

class ReportIssueScreen extends StatefulWidget {
  final String? bookingCode;

  const ReportIssueScreen({super.key, this.bookingCode});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _descCtrl = TextEditingController();
  String? _category;
  final List<bool> _attachedPhotos = [false, false, false];
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Kendaraan Rusak/Tergores',
    'Biaya Tidak Sesuai',
    'Shuttle Tidak Datang',
    'Petugas Tidak Ramah',
    'Masalah Pembayaran',
    'Lainnya',
  ];

  Future<void> _submit() async {
    if (_category == null || _descCtrl.text.trim().isEmpty) {
      showAppToast(
        context,
        severity: AppSeverity.warning,
        message: 'Lengkapi kategori dan deskripsi masalah',
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Transient confirmation, not a decision — toast instead of a blocking
    // dialog, so returning to Help Center now happens immediately rather
    // than waiting on a button tap.
    showAppToast(
      context,
      severity: AppSeverity.success,
      message:
          'Laporan terkirim. Tim kami akan menghubungi dalam 1x24 jam.',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Lapor Masalah',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.bookingCode != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Terkait booking: ${widget.bookingCode}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Kategori Masalah',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final selected = _category == c;
                return ChoiceChip(
                  label: Text(c, style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = c),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Deskripsi Masalah',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Jelaskan masalah yang Anda alami secara detail...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Lampirkan Foto Bukti (opsional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(_attachedPhotos.length, (i) {
                final done = _attachedPhotos[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => setState(() => _attachedPhotos[i] = true),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: done
                            ? Colors.green.withOpacity(0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: done ? Colors.green : Colors.grey.shade300),
                      ),
                      child: Icon(
                          done
                              ? Icons.check_circle
                              : Icons.add_a_photo_outlined,
                          color: done ? Colors.green : Colors.grey.shade400),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Kirim Laporan',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
