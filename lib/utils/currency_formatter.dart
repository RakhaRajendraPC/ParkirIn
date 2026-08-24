// lib/utils/currency_formatter.dart
import 'package:intl/intl.dart';

/// Formatter Rupiah terpusat, dipakai di seluruh layar yang menampilkan
/// harga (booking, invoice, wallet, promo, dsb) supaya format konsisten:
/// Rp 19.000 — bukan Rp 19000.
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  /// Contoh: rupiah(19000) => "Rp 19.000"
  static String rupiah(num amount) {
    return 'Rp ${_formatter.format(amount)}';
  }

  /// Tanpa prefix "Rp", untuk kasus prefix sudah ditulis terpisah di UI.
  /// Contoh: plain(19000) => "19.000"
  static String plain(num amount) {
    return _formatter.format(amount);
  }
}
