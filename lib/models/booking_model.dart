enum BookingStatus {
  menungguPembayaran, // Lot terkunci sementara selama proses bayar
  dipesan, // Bayar sukses, QR diterbitkan, menunggu check-in
  checkIn, // Sedang parkir (sesi aktif)
  checkOut, // Sesi selesai, lot kembali tersedia
  dibatalkan, // Dibatalkan oleh user
  kedaluwarsa, // Auto-cancel sistem karena tidak check-in
}

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.menungguPembayaran:
        return 'MENUNGGU PEMBAYARAN';
      case BookingStatus.dipesan:
        return 'DIPESAN';
      case BookingStatus.checkIn:
        return 'SEDANG PARKIR';
      case BookingStatus.checkOut:
        return 'SELESAI';
      case BookingStatus.dibatalkan:
        return 'DIBATALKAN';
      case BookingStatus.kedaluwarsa:
        return 'KEDALUWARSA';
    }
  }

  String get tabGroup {
    switch (this) {
      case BookingStatus.menungguPembayaran:
      case BookingStatus.dipesan:
      case BookingStatus.checkIn:
        return 'aktif';
      case BookingStatus.checkOut:
        return 'selesai';
      case BookingStatus.dibatalkan:
        return 'dibatalkan';
      case BookingStatus.kedaluwarsa:
        return 'kedaluwarsa';
    }
  }
}

class BookingModel {
  final String bookingCode;
  final String locationName;
  final String locationAddress;
  DateTime checkIn;
  DateTime checkOut;
  final String vehiclePlate;
  final String slotCode; // kode slot parkir yang dipilih user, mis. 'A3'
  final double basePrice;
  final double serviceFee;
  final double shuttleFee;
  BookingStatus status;
  double overstayFee;
  DateTime? actualCheckoutTime;

  BookingModel({
    required this.bookingCode,
    required this.locationName,
    required this.locationAddress,
    required this.checkIn,
    required this.checkOut,
    required this.vehiclePlate,
    this.slotCode = '',
    required this.basePrice,
    required this.serviceFee,
    required this.shuttleFee,
    this.status = BookingStatus.dipesan,
    this.overstayFee = 0,
    this.actualCheckoutTime,
  });

  int get durationNights => checkOut.difference(checkIn).inHours ~/ 24 == 0
      ? 1
      : (checkOut.difference(checkIn).inHours / 24).ceil();

  double get subtotal => basePrice * durationNights;
  double get total => subtotal + serviceFee + shuttleFee + overstayFee;

  static List<BookingModel> mockList() {
    final now = DateTime.now();
    return [
      BookingModel(
        bookingCode: 'PKR-88213',
        locationName: 'SkyPark Fly & Park CGK',
        locationAddress: 'Jl. Marsekal Suryadarma No. 12, Tangerang',
        checkIn: now.add(const Duration(days: 2, hours: 8)),
        checkOut: now.add(const Duration(days: 5, hours: 18)),
        vehiclePlate: 'B 1234 CD',
        slotCode: 'A3',
        basePrice: 45000,
        serviceFee: 10000,
        shuttleFee: 0,
        status: BookingStatus.dipesan,
      ),
      BookingModel(
        bookingCode: 'PKR-88099',
        locationName: 'SafePark Soekarno Hatta',
        locationAddress: 'Jl. Husein Sastranegara No. 5, Tangerang',
        checkIn: now.subtract(const Duration(days: 10)),
        checkOut: now.subtract(const Duration(days: 7)),
        vehiclePlate: 'B 1234 CD',
        slotCode: 'C5',
        basePrice: 38000,
        serviceFee: 8000,
        shuttleFee: 0,
        status: BookingStatus.checkOut,
        actualCheckoutTime: now.subtract(const Duration(days: 7)),
      ),
      BookingModel(
        bookingCode: 'PKR-87650',
        locationName: 'Angkasa Park & Fly Premium',
        locationAddress: 'Jl. Prof. Dr. Soepomo No. 3, Tangerang',
        checkIn: now.subtract(const Duration(days: 20)),
        checkOut: now.subtract(const Duration(days: 18)),
        vehiclePlate: 'B 5566 XY',
        slotCode: 'B2',
        basePrice: 60000,
        serviceFee: 10000,
        shuttleFee: 0,
        status: BookingStatus.dibatalkan,
      ),
      BookingModel(
        bookingCode: 'PKR-86112',
        locationName: 'SkyPark Fly & Park CGK',
        locationAddress: 'Jl. Marsekal Suryadarma No. 12, Tangerang',
        checkIn: now.subtract(const Duration(days: 30)),
        checkOut: now.subtract(const Duration(days: 27)),
        vehiclePlate: 'B 1234 CD',
        slotCode: 'D7',
        basePrice: 45000,
        serviceFee: 10000,
        shuttleFee: 0,
        status: BookingStatus.kedaluwarsa,
      ),
    ];
  }
}
