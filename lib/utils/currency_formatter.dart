import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  /// Contoh: rupiah(19000) => "Rp 19.000"
  static String rupiah(num amount) {
    return 'Rp ${_formatter.format(amount)}';
  }

  static String plain(num amount) {
    return _formatter.format(amount);
  }
}
