import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import '../services/favorites_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/empty_search_view.dart';
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
  static const Color primaryBlue = Color(0xFF1E5EFF);
  final FavoritesService _favorites = FavoritesService.instance;
  String _sortBy = 'Terdekat';
  bool _onlyAccessible = false;
  SearchFilterResult? _advancedFilter;

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
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.airportName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$_nights malam · ${_results.length} lokasi ditemukan',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
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
                      padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                      selectedColor: primaryBlue,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: selected ? primaryBlue : Colors.grey.shade300,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _onlyAccessible = !_onlyAccessible),
            icon: Icon(
              Icons.accessible,
              color: _onlyAccessible ? primaryBlue : Colors.grey.shade400,
            ),
            tooltip: 'Ramah kursi roda / lansia',
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push<SearchFilterResult>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AdvancedFilterScreen(initialFilter: _advancedFilter),
                ),
              );
              if (result != null) setState(() => _advancedFilter = result);
            },
            icon: const Icon(Icons.tune, color: primaryBlue),
            tooltip: 'Filter Lanjutan',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapViewScreen(
                  checkIn: widget.checkIn,
                  checkOut: widget.checkOut,
                ),
              ),
            ),
            icon: const Icon(Icons.map_outlined, color: primaryBlue),
            tooltip: 'Lihat di Peta',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(ParkingLocation loc) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationDetailScreen(
              location: loc,
              checkIn: widget.checkIn,
              checkOut: widget.checkOut,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: loc.imagePath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                loc.imagePath,
                                fit: BoxFit.cover,
                                width: 70,
                                height: 70,
                              ),
                            )
                          : Icon(
                              loc.isIndoor
                                  ? Icons.warehouse
                                  : Icons.local_parking,
                              color: primaryBlue,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 32),
                            child: Text(
                              loc.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                '${loc.rating}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.directions_car,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${loc.distanceKm} km',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (loc.isAccessible) ...[
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.accessible,
                                  size: 14,
                                  color: Colors.teal.shade400,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: CurrencyFormatter.rupiah(loc.pricePerNight),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' / malam',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Pilih',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => setState(() => _favorites.toggle(loc.id)),
              icon: Icon(
                _favorites.isFavorite(loc.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _favorites.isFavorite(loc.id)
                    ? Colors.redAccent
                    : Colors.grey.shade400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
