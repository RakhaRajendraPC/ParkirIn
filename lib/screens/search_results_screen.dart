// lib/screens/search_results_screen.dart
import 'package:flutter/material.dart';
import '../models/parking_location_model.dart';
import 'location_detail_screen.dart';

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
  String _sortBy = 'Terdekat';
  bool _onlyAccessible = false;

  List<ParkingLocation> get _results {
    var list = List<ParkingLocation>.from(ParkingLocation.mockList());
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
              Text(widget.airportName,
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              Text('$_nights malam · ${_results.length} lokasi ditemukan',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: ListView.separated(
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
                            color:
                                selected ? primaryBlue : Colors.grey.shade300),
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
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
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
                  child: Icon(
                      loc.isIndoor ? Icons.warehouse : Icons.local_parking,
                      color: primaryBlue,
                      size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(loc.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${loc.rating}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 10),
                          Icon(Icons.directions_car,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 2),
                          Text('${loc.distanceKm} km',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600)),
                          if (loc.isAccessible) ...[
                            const SizedBox(width: 10),
                            Icon(Icons.accessible,
                                size: 14, color: Colors.teal.shade400),
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
                child: Divider(height: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'Rp ${loc.pricePerNight.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text: ' / malam',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('Pilih',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
