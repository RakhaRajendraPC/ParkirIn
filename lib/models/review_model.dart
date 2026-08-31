class LocationReview {
  final String userName;
  final String userAvatarSeed;
  final int rating;
  final String comment;
  final DateTime date;
  final List<String> tags;

  const LocationReview({
    required this.userName,
    required this.userAvatarSeed,
    required this.rating,
    required this.comment,
    required this.date,
    this.tags = const [],
  });

  static List<LocationReview> mockForLocation(String locationId) {
    final now = DateTime.now();
    return [
      LocationReview(
        userName: 'Dewi Anggraini',
        userAvatarSeed: '45',
        rating: 5,
        comment:
            'Lokasinya bersih, petugas ramah, dan shuttle datangnya cepat banget. Recommended!',
        date: now.subtract(const Duration(days: 3)),
        tags: const ['Bersih', 'Shuttle Cepat'],
      ),
      LocationReview(
        userName: 'Rian Pratama',
        userAvatarSeed: '22',
        rating: 4,
        comment:
            'Overall bagus, cuma agak jauh dari terminal kalau dapat slot ekonomis.',
        date: now.subtract(const Duration(days: 10)),
        tags: const ['Aman'],
      ),
      LocationReview(
        userName: 'Siti Nurhaliza',
        userAvatarSeed: '31',
        rating: 5,
        comment:
            'Sudah 3 kali pakai selalu puas. Proses check-in/check-out cepat pakai QR.',
        date: now.subtract(const Duration(days: 18)),
        tags: const ['Mudah Diakses', 'Petugas Ramah'],
      ),
    ];
  }
}
