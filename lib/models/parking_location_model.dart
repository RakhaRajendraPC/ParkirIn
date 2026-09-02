class ParkingLocation {
  final String id;
  final String name;
  final String address;
  final double pricePerNight;
  final double rating;
  final double distanceKm;
  final bool isIndoor;
  final List<String> facilities;
  final bool isAccessible;
  final String imagePath;
  final String? closingTime;
  final int? totalSlots;
  final int? availableSlots;

  const ParkingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerNight,
    required this.rating,
    required this.distanceKm,
    required this.isIndoor,
    required this.facilities,
    this.isAccessible = false,
    this.imagePath = '',
    this.closingTime,
    this.totalSlots,
    this.availableSlots,
  });

  /// Maps a `/locations` summary or `/locations/:id` detail JSON object to
  /// this model. The backend doesn't provide rating, distance, or an image
  /// yet, so those fall back to 0/empty rather than fabricated placeholder
  /// values. closingTime/totalSlots/availableSlots are only present on the
  /// detail response — absent on the summary, they stay null.
  factory ParkingLocation.fromApi(Map<String, dynamic> json) {
    final startingPrice = json['startingPrice'];
    return ParkingLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      pricePerNight:
          startingPrice == null ? 0 : (startingPrice as num).toDouble(),
      rating: 0,
      distanceKm: 0,
      isIndoor: json['isIndoor'] as bool? ?? false,
      facilities: (json['facilities'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      isAccessible: json['isAccessible'] as bool? ?? false,
      imagePath: '',
      closingTime: json['closingTime'] as String?,
      totalSlots: json['totalSlots'] as int?,
      availableSlots: json['availableSlots'] as int?,
    );
  }

  static List<ParkingLocation> mockList() => const [
        ParkingLocation(
          id: 'loc1',
          name: 'SkyPark Fly & Park CGK',
          address: 'Jl. Marsekal Suryadarma No. 12, Tangerang',
          pricePerNight: 45000,
          rating: 4.7,
          distanceKm: 1.2,
          isIndoor: true,
          facilities: [
            'CCTV 24 Jam',
            'Pagar Keliling',
            'Petugas Jaga',
            'Area Tertutup',
          ],
          isAccessible: true,
          imagePath: 'assets/images/skypark_1.png',
        ),
        ParkingLocation(
          id: 'loc2',
          name: 'SafePark Soekarno Hatta',
          address: 'Jl. Husein Sastranegara No. 5, Tangerang',
          pricePerNight: 38000,
          rating: 4.5,
          distanceKm: 2.5,
          isIndoor: false,
          facilities: ['CCTV 24 Jam', 'Petugas Jaga', 'Shuttle Reguler'],
          imagePath: 'assets/images/safepark_1.png',
        ),
        ParkingLocation(
          id: 'loc3',
          name: 'Angkasa Park & Fly Premium',
          address: 'Jl. Prof. Dr. Soepomo No. 3, Tangerang',
          pricePerNight: 60000,
          rating: 4.9,
          distanceKm: 0.8,
          isIndoor: true,
          facilities: [
            'CCTV 24 Jam',
            'Pagar Keliling',
            'Petugas Jaga',
            'Area Tertutup',
            'Car Wash',
          ],
          isAccessible: true,
          imagePath: 'assets/images/angkasa_1.png',
        ),
      ];
}
