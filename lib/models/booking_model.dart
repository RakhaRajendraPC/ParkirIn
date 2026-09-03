enum BookingStatus {
  menungguPembayaran,
  dipesan,
  checkIn,
  checkOut,
  dibatalkan,
  kedaluwarsa,
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
  final String slotCode;
  final double basePrice;
  final double serviceFee;
  final double shuttleFee;
  BookingStatus status;
  double overstayFee;
  DateTime? actualCheckoutTime;

  /// Real bookings from the backend carry their own authoritative `total`
  /// (what was actually charged) — set via the [total] constructor param.
  /// Mock/local bookings leave this null and fall back to the live
  /// client-side computation below, which still needs to react to later
  /// mutations of [overstayFee] etc. (e.g. CheckoutScreen's mock flow).
  final double? _totalOverride;

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
    double? total,
  }) : _totalOverride = total;

  int get durationNights => checkOut.difference(checkIn).inHours ~/ 24 == 0
      ? 1
      : (checkOut.difference(checkIn).inHours / 24).ceil();

  double get subtotal => basePrice * durationNights;
  double get total =>
      _totalOverride ?? (subtotal + serviceFee + shuttleFee + overstayFee);

  Map<String, dynamic> toJson() => {
        'bookingCode': bookingCode,
        'locationName': locationName,
        'locationAddress': locationAddress,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'vehiclePlate': vehiclePlate,
        'slotCode': slotCode,
        'basePrice': basePrice,
        'serviceFee': serviceFee,
        'shuttleFee': shuttleFee,
        'status': status.name,
        'overstayFee': overstayFee,
        'actualCheckoutTime': actualCheckoutTime?.toIso8601String(),
      };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        bookingCode: json['bookingCode'] as String,
        locationName: json['locationName'] as String,
        locationAddress: json['locationAddress'] as String,
        checkIn: DateTime.parse(json['checkIn'] as String),
        checkOut: DateTime.parse(json['checkOut'] as String),
        vehiclePlate: json['vehiclePlate'] as String,
        slotCode: json['slotCode'] as String? ?? '',
        basePrice: (json['basePrice'] as num).toDouble(),
        serviceFee: (json['serviceFee'] as num).toDouble(),
        shuttleFee: (json['shuttleFee'] as num).toDouble(),
        status: BookingStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => BookingStatus.dipesan,
        ),
        overstayFee: (json['overstayFee'] as num?)?.toDouble() ?? 0,
        actualCheckoutTime: json['actualCheckoutTime'] != null
            ? DateTime.parse(json['actualCheckoutTime'] as String)
            : null,
      );

  /// Maps a `GET /bookings`/`GET /bookings/:code` JSON object — including
  /// its nested `location`/`vehicle`/`slot` objects (see
  /// `bookings.service.ts`'s `findAllForUser` include) — to this model.
  /// Uses the backend's own `total`, not the client-side computed one,
  /// since the backend is the source of truth for what was actually
  /// charged.
  factory BookingModel.fromApi(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    final slot = json['slot'] as Map<String, dynamic>?;
    return BookingModel(
      bookingCode: json['bookingCode'] as String,
      locationName: location?['name'] as String? ?? '',
      locationAddress: location?['address'] as String? ?? '',
      checkIn: DateTime.parse(json['checkInPlanned'] as String),
      checkOut: DateTime.parse(json['checkOutPlanned'] as String),
      vehiclePlate: vehicle?['plate'] as String? ?? '',
      slotCode: slot?['code'] as String? ?? '',
      basePrice: (json['basePrice'] as num).toDouble(),
      serviceFee: (json['serviceFee'] as num).toDouble(),
      shuttleFee: 0,
      status: _statusFromApi(json['status'] as String),
      overstayFee: (json['overstayFee'] as num?)?.toDouble() ?? 0,
      actualCheckoutTime: json['checkOutActual'] != null
          ? DateTime.parse(json['checkOutActual'] as String)
          : null,
      total: (json['total'] as num).toDouble(),
    );
  }

  static BookingStatus _statusFromApi(String raw) {
    switch (raw) {
      case 'menunggu_pembayaran':
        return BookingStatus.menungguPembayaran;
      case 'dipesan':
        return BookingStatus.dipesan;
      case 'check_in':
        return BookingStatus.checkIn;
      case 'check_out':
        return BookingStatus.checkOut;
      case 'dibatalkan':
        return BookingStatus.dibatalkan;
      case 'kedaluwarsa':
        return BookingStatus.kedaluwarsa;
      default:
        return BookingStatus.dipesan;
    }
  }

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
