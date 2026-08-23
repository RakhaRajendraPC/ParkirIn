enum BookingStatus { aktif, selesai, dibatalkan }

class BookingModel {
  final String bookingCode;
  final String locationName;
  final String locationAddress;
  final DateTime checkIn;
  final DateTime checkOut;
  final String vehiclePlate;
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
    required this.basePrice,
    required this.serviceFee,
    required this.shuttleFee,
    this.status = BookingStatus.aktif,
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
        basePrice: 45000,
        serviceFee: 10000,
        shuttleFee: 0,
        status: BookingStatus.aktif,
      ),
      BookingModel(
        bookingCode: 'PKR-88099',
        locationName: 'SafePark Soekarno Hatta',
        locationAddress: 'Jl. Husein Sastranegara No. 5, Tangerang',
        checkIn: now.subtract(const Duration(days: 10)),
        checkOut: now.subtract(const Duration(days: 7)),
        vehiclePlate: 'B 1234 CD',
        basePrice: 38000,
        serviceFee: 8000,
        shuttleFee: 0,
        status: BookingStatus.selesai,
        actualCheckoutTime: now.subtract(const Duration(days: 7)),
      ),
      BookingModel(
        bookingCode: 'PKR-87650',
        locationName: 'Angkasa Park & Fly Premium',
        locationAddress: 'Jl. Prof. Dr. Soepomo No. 3, Tangerang',
        checkIn: now.subtract(const Duration(days: 20)),
        checkOut: now.subtract(const Duration(days: 18)),
        vehiclePlate: 'B 5566 XY',
        basePrice: 60000,
        serviceFee: 10000,
        shuttleFee: 0,
        status: BookingStatus.dibatalkan,
      ),
    ];
  }
}
