import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../services/favorites_service.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_toast.dart';
import '../widgets/network_error_view.dart';
import 'location_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favorites = FavoritesService.instance;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_onChanged);
    AppSettings.instance.addListener(_onChanged);
    _loadFavorites();
  }

  @override
  void dispose() {
    _favorites.removeListener(_onChanged);
    AppSettings.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await _favorites.load(force: true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.message;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggle(ParkingLocation loc) async {
    try {
      await _favorites.toggle(loc);
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
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
          title: Text(AppStrings.t('fav_appbar_title'),
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return NetworkErrorView(onRetry: _loadFavorites, message: _errorMessage);
    }

    final favLocations = _favorites.locations;

    if (favLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(AppStrings.t('fav_empty_title'),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 4),
            Text(AppStrings.t('fav_empty_sub'),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: favLocations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final loc = favLocations[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationDetailScreen(
                  location: loc,
                  checkIn: DateTime.now().add(const Duration(days: 1)),
                  checkOut: DateTime.now().add(const Duration(days: 2)),
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(
                        loc.isIndoor ? Icons.warehouse : Icons.local_parking,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(loc.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                        Text(
                            '${CurrencyFormatter.rupiah(loc.pricePerNight)}${AppStrings.t('fav_per_malam')}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _toggle(loc),
                    icon: const Icon(Icons.favorite,
                        color: Colors.redAccent, size: 20),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
