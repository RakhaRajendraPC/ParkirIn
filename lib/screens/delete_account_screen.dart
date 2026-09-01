import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../widgets/app_sheet.dart';
import '../widgets/app_toast.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final Set<String> _selectedReasons = {};
  final _feedbackCtrl = TextEditingController();
  bool _confirmChecked = false;

  @override
  void initState() {
    super.initState();
    AppSettings.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<String> get _reasons => [
        AppStrings.t('delete_reason_1'),
        AppStrings.t('delete_reason_2'),
        AppStrings.t('delete_reason_3'),
        AppStrings.t('delete_reason_4'),
        AppStrings.t('delete_reason_5'),
      ];

  void _requestDeletion() {
    if (!_confirmChecked) return;
    showAppSheet(
      context,
      severity: AppSeverity.destructive,
      icon: Icons.delete_forever_outlined,
      title: AppStrings.t('delete_final_title'),
      body: AppStrings.t('delete_final_msg'),
      primaryLabel: AppStrings.t('delete_ajukan_btn'),
      onPrimary: () {
        Navigator.pop(context);
        _showRequestSubmitted();
      },
      secondaryLabel: AppStrings.t('delete_batal'),
      onSecondary: () => Navigator.pop(context),
    );
  }

  void _showRequestSubmitted() {
    // Transient confirmation, not a decision — a toast instead of a
    // blocking dialog, so the "back to home" navigation now fires
    // immediately alongside the toast rather than waiting on a button tap.
    showAppToast(
      context,
      severity: AppSeverity.success,
      message: AppStrings.t('delete_submitted_msg'),
    );
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  void _requestDataExport() {
    showAppToast(
      context,
      severity: AppSeverity.success,
      message: AppStrings.t('delete_export_snackbar'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(AppStrings.t('delete_appbar_title'),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  Icon(Icons.download_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.t('delete_unduh_data_title'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(AppStrings.t('delete_unduh_data_sub'),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  TextButton(
                      onPressed: _requestDataExport,
                      child: Text(AppStrings.t('delete_minta_btn'),
                          style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(AppStrings.t('delete_warning'),
                          style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.t('delete_reason_title'),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? AppColors.primary : Colors.black87),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppStrings.t('delete_feedback_hint'),
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
              title: Text(AppStrings.t('delete_confirm_checkbox'),
                  style: const TextStyle(fontSize: 12)),
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
                child: Text(AppStrings.t('delete_hapus_btn'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
