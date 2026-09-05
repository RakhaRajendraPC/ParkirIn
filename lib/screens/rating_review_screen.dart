import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_exception.dart';
import '../services/reviews_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_toast.dart';

class RatingReviewScreen extends StatefulWidget {
  final BookingModel booking;

  const RatingReviewScreen({super.key, required this.booking});

  @override
  State<RatingReviewScreen> createState() => _RatingReviewScreenState();
}

class _RatingReviewScreenState extends State<RatingReviewScreen> {
  int _rating = 0;
  final _reviewCtrl = TextEditingController();
  bool _isSubmitting = false;
  final _reviewsApi = ReviewsApiService();

  final List<String> _tags = [
    'Bersih',
    'Aman',
    'Petugas Ramah',
    'Shuttle Cepat',
    'Mudah Diakses'
  ];
  final Set<String> _selectedTags = {};

  Future<void> _submit() async {
    if (_rating == 0) {
      showAppToast(
        context,
        severity: AppSeverity.warning,
        message: 'Pilih rating bintang terlebih dahulu',
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await _reviewsApi.submitReview(
        widget.booking.bookingCode,
        rating: _rating,
        comment: _reviewCtrl.text.trim(),
        tags: _selectedTags.toList(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      showAppToast(
        context,
        severity: AppSeverity.success,
        message: 'Terima kasih atas ulasan Anda!',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 409) {
        // Defensive fallback for the race window between BookingDetailScreen's
        // proactive existence check and this submit — the backend is the
        // final authority on whether a review already exists.
        Navigator.pop(context);
        showAppToast(
          context,
          severity: AppSeverity.warning,
          message: 'Anda sudah memberi ulasan untuk booking ini.',
        );
        return;
      }
      showAppToast(
        context,
        severity: AppSeverity.destructive,
        message: e.message,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Beri Rating',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  Text(widget.booking.locationName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Bagaimana pengalaman parkir Anda?',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final filled = i < _rating;
                      return IconButton(
                        onPressed: () => setState(() => _rating = i + 1),
                        icon: Icon(filled ? Icons.star : Icons.star_border,
                            color: Colors.amber, size: 36),
                      );
                    }),
                  ),
                  if (_rating > 0)
                    Text(
                      [
                        '',
                        'Buruk',
                        'Kurang',
                        'Cukup',
                        'Baik',
                        'Sangat Baik'
                      ][_rating],
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Apa yang Anda sukai?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((t) {
                final selected = _selectedTags.contains(t);
                return FilterChip(
                  label: Text(t, style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  onSelected: (v) => setState(
                      () => v ? _selectedTags.add(t) : _selectedTags.remove(t)),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? AppColors.primary : Colors.black87,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Tulis Ulasan (opsional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _reviewCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ceritakan pengalaman parkir Anda...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Kirim Ulasan',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
