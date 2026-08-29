import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';

enum PaymentMethodType { card, ewallet, virtualAccount }

class AddPaymentMethodScreen extends StatefulWidget {
  final PaymentMethodType type;

  const AddPaymentMethodScreen({super.key, required this.type});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedBank = 'BCA';
  bool _isSaving = false;

  final List<String> _banks = ['BCA', 'Mandiri', 'BNI', 'BRI', 'CIMB Niaga'];

  @override
  void initState() {
    super.initState();
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

  String get _title {
    switch (widget.type) {
      case PaymentMethodType.card:
        return AppStrings.t('addpayment_title_card');
      case PaymentMethodType.ewallet:
        return AppStrings.t('addpayment_title_ewallet');
      case PaymentMethodType.virtualAccount:
        return AppStrings.t('addpayment_title_va');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.t('addpayment_success_snackbar'))),
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
          title: Text(_title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.type == PaymentMethodType.card) ..._buildCardFields(),
              if (widget.type == PaymentMethodType.ewallet)
                ..._buildEwalletFields(),
              if (widget.type == PaymentMethodType.virtualAccount)
                ..._buildVaFields(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(AppStrings.t('addpayment_security_note'),
                            style: const TextStyle(fontSize: 11))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(AppStrings.t('addpayment_simpan_btn'),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCardFields() {
    return [
      _field(AppStrings.t('addpayment_nomor_kartu'), _cardNumberCtrl,
          hint: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
          maxLength: 19),
      _field(AppStrings.t('addpayment_nama_pemegang'), _cardNameCtrl,
          hint: AppStrings.t('addpayment_nama_hint')),
      Row(
        children: [
          Expanded(
              child: _field(
                  AppStrings.t('addpayment_masa_berlaku'), _expiryCtrl,
                  hint: '12/28', keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(
              child: _field(AppStrings.t('addpayment_cvv'), _cvvCtrl,
                  hint: '123',
                  keyboardType: TextInputType.number,
                  obscure: true,
                  maxLength: 3)),
        ],
      ),
    ];
  }

  List<Widget> _buildEwalletFields() {
    return [
      _field(AppStrings.t('addpayment_nomor_hp'), _phoneCtrl,
          hint: '0812xxxxxxxx', keyboardType: TextInputType.phone),
      const SizedBox(height: 4),
      Text(AppStrings.t('addpayment_ewallet_note'),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ];
  }

  List<Widget> _buildVaFields() {
    return [
      Text(AppStrings.t('addpayment_pilih_bank'),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _banks.map((b) {
          final selected = _selectedBank == b;
          return ChoiceChip(
            label: Text(b, style: const TextStyle(fontSize: 12)),
            selected: selected,
            onSelected: (_) => setState(() => _selectedBank = b),
            selectedColor: AppColors.primary,
            labelStyle:
                TextStyle(color: selected ? Colors.white : Colors.black87),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                    color:
                        selected ? AppColors.primary : Colors.grey.shade300)),
          );
        }).toList(),
      ),
      const SizedBox(height: 12),
      Text(AppStrings.t('addpayment_va_note'),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ];
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint,
      TextInputType? keyboardType,
      bool obscure = false,
      int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscure,
        maxLength: maxLength,
        validator: (v) => (v == null || v.trim().isEmpty)
            ? AppStrings.t('addpayment_wajib_diisi')
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
