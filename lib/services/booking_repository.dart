import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

/// Sumber data tunggal untuk seluruh booking milik user yang sedang login.
/// Menggantikan pola lama di mana tiap layar (BookingsScreen, dsb) punya
/// list mock sendiri-sendiri. ChangeNotifier supaya layar yang menampilkan
/// daftar booking bisa auto-refresh saat ada booking baru atau perubahan
/// status (check-in/check-out) dari layar lain.
///
/// Production: ganti isi list ini dengan hasil fetch dari backend, dan
/// panggil refresh() setelah setiap mutasi status tersinkron ke server.
class BookingRepository extends ChangeNotifier {
  BookingRepository._();
  static final BookingRepository instance = BookingRepository._();

  final List<BookingModel> _bookings = BookingModel.mockList();

  List<BookingModel> get all => List.unmodifiable(_bookings);

  void add(BookingModel booking) {
    _bookings.insert(0, booking); // booking terbaru muncul paling atas
    notifyListeners();
  }

  /// Panggil setelah memutasi field pada objek BookingModel yang sudah ada
  /// (mis. booking.status = BookingStatus.checkIn) supaya listener tahu
  /// harus rebuild, karena mutasi objek in-place tidak otomatis terdeteksi.
  void refresh() => notifyListeners();

  BookingModel? findByCode(String code) {
    try {
      return _bookings.firstWhere((b) => b.bookingCode == code);
    } catch (_) {
      return null;
    }
  }
}
