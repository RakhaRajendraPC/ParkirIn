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

  /// Maps a `GET /locations/:id/reviews` entry — `{ id, rating, comment,
  /// tags, createdAt, user: { name } }` (see `reviews.service.ts`'s
  /// `findAllForLocation`). The backend stores no avatar, so a stable
  /// pseudo-random pravatar seed is derived from the review's own id purely
  /// for visual variety, not real data.
  factory LocationReview.fromApi(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final id = json['id'] as String? ?? '';
    return LocationReview(
      userName: user?['name'] as String? ?? 'Pengguna ParkirIn',
      userAvatarSeed: '${(id.hashCode.abs() % 70) + 1}',
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      date: DateTime.parse(json['createdAt'] as String),
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}
