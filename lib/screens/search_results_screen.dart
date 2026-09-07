import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../services/favorites_service.dart';
import '../services/app_settings.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/empty_search_view.dart';
import '../widgets/stub_icon.dart';
import 'location_detail_screen.dart';
import 'map_view_screen.dart';
import 'advanced_filter_screen.dart';

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
  String _sortBy = 'Terdekat';
  bool _onlyAccessible = false;
  SearchFilterResult? _advancedFilter;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_onChanged);
    AppSettings.instance.addListener(_onChanged);
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

  List<ParkingLocation> get _results {
    var list = List<ParkingLocation>.from(ParkingLocation.mockList());

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
      case 'Rating Tertinggi':
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF16181F)),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.airportName,
                  style: const TextStyle(
                      color: Color(0xFF16181F),
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              Text('$_nights malam · ${_results.length} lokasi ditemukan',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 10.5)),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: _results.isEmpty
                  ? EmptySearchView(
                      onResetFilter: () => setState(() {
                        _advancedFilter = null;
                        _onlyAccessible = false;
                      }),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildLocationCard(_results[index]),
                    ),
            ),
          ],
        ),
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
                children: ['Terdekat', 'Termurah', 'Rating Tertinggi'].map((s) {
                  final selected = _sortBy == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (_) => setState(() => _sortBy = s),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                          fontSize: 11.5,
                          color: selected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.grey.shade200)),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          _iconToggle(
              Icons.accessible_rounded,
              _onlyAccessible,
              () => setState(() => _onlyAccessible = !_onlyAccessible),
              'Ramah kursi roda / lansia'),
          const SizedBox(width: 6),
          _iconToggle(Icons.tune_rounded, _advancedFilter != null, () async {
            final result = await Navigator.push<SearchFilterResult>(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AdvancedFilterScreen(initialFilter: _advancedFilter)));
            if (result != null) setState(() => _advancedFilter = result);
          }, 'Filter Lanjutan'),
          const SizedBox(width: 6),
          _iconToggle(
              Icons.map_rounded,
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
      IconData icon, bool active, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
                color: active ? AppColors.primary : Colors.grey.shade200),
          ),
          child: Icon(icon,
              size: 18,
              color: active ? AppColors.primary : Colors.grey.shade500),
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
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(loc.imagePath,
                                  fit: BoxFit.cover, width: 64, height: 64))
                          : StubIcon(
                              icon: loc.isIndoor
                                  ? Icons.warehouse_rounded
                                  : Icons.local_parking_rounded,
                              color: AppColors.primary,
                              size: 64),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Text(loc.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF16181F))),
                            ),
                            const SizedBox(height: 3),
                            Text(loc.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600)),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 15, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text('${loc.rating}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(width: 10),
                                Icon(Icons.directions_car_rounded,
                                    size: 13, color: Colors.grey.shade400),
                                const SizedBox(width: 2),
                                Text('${loc.distanceKm} km',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600)),
                                if (loc.isAccessible) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.accessible_rounded,
                                      size: 15, color: const Color(0xFF0EA5A4)),
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
                          style: const TextStyle(color: Color(0xFF16181F)),
                          children: [
                            TextSpan(
                                text:
                                    CurrencyFormatter.rupiah(loc.pricePerNight),
                                style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800)),
                            TextSpan(
                                text: ' / malam',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(11)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('PILIH',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3)),
                            SizedBox(width: 4),
                            Icon(Icons.north_east_rounded,
                                color: Colors.white, size: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: () => _favorites.toggle(loc.id),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06), blurRadius: 6)
                    ]),
                child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color:
                        isFav ? const Color(0xFFE1306C) : Colors.grey.shade400,
                    size: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
