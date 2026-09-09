import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../services/app_settings.dart';
import '../services/favorites_service.dart';
import '../services/locations_api_service.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/app_toast.dart';
import '../widgets/empty_search_view.dart';
import '../widgets/material_symbol.dart';
import '../widgets/network_error_view.dart';
import '../widgets/stub_icon.dart' show PerforationDivider;
import 'advanced_filter_screen.dart';
import 'location_detail_screen.dart';
import 'map_view_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String airportName;
  final DateTime checkIn;
  final DateTime checkOut;

  const SearchResultsScreen({
    super.key,
    required this.airportName,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final FavoritesService _favorites = FavoritesService.instance;
  final LocationsApiService _locationsApi = LocationsApiService();
  String _sortBy = 'Terdekat';
  bool _onlyAccessible = false;
  SearchFilterResult? _advancedFilter;
  List<ParkingLocation> _locations = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_onChanged);
    AppSettings.instance.addListener(_onChanged);
    _loadLocations();
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

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final locations = await _locationsApi.getLocations();
      if (!mounted) return;
      setState(() => _locations = locations);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.message;
      });
      showAppToast(context, severity: AppSeverity.destructive, message: e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ParkingLocation> get _results {
    var list = List<ParkingLocation>.from(_locations);

    if (_onlyAccessible) {
      list = list.where((e) => e.isAccessible).toList();
    }

    final adv = _advancedFilter;
    if (adv != null) {
      list = list.where((e) {
        final inPriceRange = e.pricePerNight >= adv.priceRange.start &&
            e.pricePerNight <= adv.priceRange.end;
        final matchType = adv.parkingType == null ||
            (adv.parkingType == 'Indoor' && e.isIndoor) ||
            (adv.parkingType == 'Outdoor' && !e.isIndoor);
        final matchFacilities = adv.facilities.isEmpty ||
            adv.facilities.every((f) => e.facilities.contains(f));
        final matchAccessible = !adv.onlyAccessible || e.isAccessible;
        return inPriceRange && matchType && matchFacilities && matchAccessible;
      }).toList();
    }

    switch (_sortBy) {
      case 'Termurah':
        list.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
        break;
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return list;
  }

  int get _nights {
    final n = widget.checkOut.difference(widget.checkIn).inHours / 24;
    return n.ceil() < 1 ? 1 : n.ceil();
  }

  String get _dateRangeLabel {
    const months = [
      '',
      'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
      'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'
    ];
    final inD = widget.checkIn;
    final outD = widget.checkOut;
    if (inD.month == outD.month) {
      return '${inD.day}–${outD.day} ${months[outD.month]}';
    }
    return '${inD.day} ${months[inD.month]} – ${outD.day} ${months[outD.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const MaterialSymbol(MSymbols.arrowBack,
                color: AppColors.ink, size: 22, weight: 300),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.airportName,
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              Text('$_nights malam · ${_results.length} lokasi ditemukan',
                  style: const TextStyle(
                      fontFamily: 'Outfit', color: AppColors.body, fontSize: 10.5)),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                  ? NetworkErrorView(
                      onRetry: _loadLocations,
                      message: _errorMessage,
                      title: 'Tidak Dapat Terhubung ke Server',
                      icon: Icons.cloud_off_outlined,
                    )
                  : _results.isEmpty
                  ? EmptySearchView(
                      onResetFilter: () => setState(() {
                        _advancedFilter = null;
                        _onlyAccessible = false;
                      }),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      children: [
                        _buildListHeadRow(),
                        const SizedBox(height: 10),
                        ...List.generate(_results.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildLocationCard(_results[i]),
                          );
                        }),
                        _buildEndOfListFooter(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mono "URUT: <sortBy>" / date-range row above the list — present in the
  /// target design, absent from the previous layout.
  Widget _buildListHeadRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('URUT: ${_sortBy.toUpperCase()}',
            style: const TextStyle(
                fontFamily: 'IBM Plex Mono',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.6,
                color: AppColors.label)),
        Text(_dateRangeLabel,
            style: const TextStyle(
                fontFamily: 'IBM Plex Mono',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.6,
                color: AppColors.label)),
      ],
    );
  }

  /// "<N> dari <N> lokasi" + hint text, always shown after a non-empty
  /// result list — present in the target design, absent from the previous
  /// layout.
  Widget _buildEndOfListFooter() {
    final n = _results.length;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$n DARI $n LOKASI',
              style: const TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.6,
                  color: AppColors.label)),
          const SizedBox(height: 6),
          const Text(
            'Perluas radius pencarian untuk melihat lokasi lain di sekitar bandara.',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                fontWeight: FontWeight.w300,
                height: 1.5,
                color: AppColors.body),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Terdekat', 'Termurah', 'Rating'].map((s) {
                  final selected = _sortBy == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _sortBy = s),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.hairline),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                letterSpacing: -0.1,
                                color: selected ? Colors.white : AppColors.ink,
                                fontWeight:
                                    selected ? FontWeight.w500 : FontWeight.w400)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          _iconToggle(
              MSymbols.accessible,
              _onlyAccessible,
              () => setState(() => _onlyAccessible = !_onlyAccessible),
              'Ramah kursi roda / lansia'),
          const SizedBox(width: 8),
          _iconToggle(MSymbols.tune, _advancedFilter != null, () async {
            final result = await Navigator.push<SearchFilterResult>(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AdvancedFilterScreen(initialFilter: _advancedFilter)));
            if (result != null) setState(() => _advancedFilter = result);
          }, 'Filter Lanjutan'),
          const SizedBox(width: 8),
          _iconToggle(
              MSymbols.map,
              false,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapViewScreen(
                          checkIn: widget.checkIn, checkOut: widget.checkOut))),
              'Lihat di Peta'),
        ],
      ),
    );
  }

  Widget _iconToggle(
      int symbol, bool active, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: active ? AppColors.primary : AppColors.hairline),
          ),
          child: MaterialSymbol(symbol,
              size: 20,
              color: active ? AppColors.primary : AppColors.inactiveNav,
              weight: 300),
        ),
      ),
    );
  }

  Widget _buildLocationCard(ParkingLocation loc) {
    final isFav = _favorites.isFavorite(loc.id);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LocationDetailScreen(
                  location: loc,
                  checkIn: widget.checkIn,
                  checkOut: widget.checkOut))),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      loc.imagePath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(loc.imagePath,
                                  fit: BoxFit.cover, width: 76, height: 76))
                          : const _ImagePlaceholder(size: 76),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Text(loc.name,
                                  style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      letterSpacing: -0.2,
                                      color: AppColors.ink)),
                            ),
                            const SizedBox(height: 3),
                            Text(loc.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.body)),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const MaterialSymbol(MSymbols.star,
                                    size: 15, color: AppColors.ink, weight: 300),
                                const SizedBox(width: 4),
                                Text('${loc.rating}',
                                    style: const TextStyle(
                                        fontFamily: 'IBM Plex Mono',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.ink)),
                                const SizedBox(width: 10),
                                const MaterialSymbol(MSymbols.directionsCar,
                                    size: 15, color: AppColors.label, weight: 300),
                                const SizedBox(width: 4),
                                Text('${loc.distanceKm} km',
                                    style: const TextStyle(
                                        fontFamily: 'IBM Plex Mono',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.label)),
                                if (loc.isAccessible) ...[
                                  const SizedBox(width: 8),
                                  const MaterialSymbol(MSymbols.accessible,
                                      size: 15, color: AppColors.label, weight: 300),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  const PerforationDivider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontFamily: 'IBM Plex Mono', color: AppColors.ink),
                          children: [
                            TextSpan(
                                text:
                                    CurrencyFormatter.rupiah(loc.pricePerNight),
                                style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2)),
                            const TextSpan(
                                text: ' / malam',
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.body)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LocationDetailScreen(
                                    location: loc,
                                    checkIn: widget.checkIn,
                                    checkOut: widget.checkOut))),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFF8A00),
                              borderRadius: BorderRadius.circular(18)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Pilih',
                                  style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.1)),
                              const SizedBox(width: 7),
                              const MaterialSymbol(MSymbols.northEast,
                                  color: Colors.white, size: 17, weight: 300),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: InkWell(
              onTap: () {
                _favorites.toggle(loc).catchError((Object e) {
                  if (!mounted) return;
                  showAppToast(
                    context,
                    severity: AppSeverity.destructive,
                    message: e is ApiException
                        ? e.message
                        : 'Gagal memperbarui favorit',
                  );
                });
              },
              child: MaterialSymbol(
                MSymbols.favorite,
                filled: isFav,
                color: isFav ? const Color(0xFFE1306C) : AppColors.inactiveNav,
                size: 20,
                weight: 300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain square placeholder for a missing location photo — matches the
/// target design file's own placeholder treatment ("FOTO LOKASI"), replacing
/// the previous StubIcon angled-clip fallback.
class _ImagePlaceholder extends StatelessWidget {
  final double size;

  const _ImagePlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border.all(color: AppColors.hairline),
      ),
      child: const Text(
        'FOTO LOKASI',
        style: TextStyle(
            fontFamily: 'IBM Plex Mono',
            fontSize: 6,
            letterSpacing: 0.4,
            color: AppColors.label),
      ),
    );
  }
}
