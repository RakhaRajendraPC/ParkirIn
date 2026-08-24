import 'package:flutter/material.dart';

class SearchFilterResult {
  final RangeValues priceRange;
  final Set<String> facilities;
  final String? parkingType;
  final bool onlyAccessible;

  const SearchFilterResult({
    required this.priceRange,
    required this.facilities,
    this.parkingType,
    this.onlyAccessible = false,
  });
}

class AdvancedFilterScreen extends StatefulWidget {
  final SearchFilterResult? initialFilter;

  const AdvancedFilterScreen({super.key, this.initialFilter});

  @override
  State<AdvancedFilterScreen> createState() => _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends State<AdvancedFilterScreen> {
  static const Color primaryBlue = Color(0xFF1E5EFF);

  late RangeValues _priceRange;
  late Set<String> _selectedFacilities;
  String? _parkingType;
  bool _onlyAccessible = false;

  final List<String> _allFacilities = const [
    'CCTV 24 Jam',
    'Pagar Keliling',
    'Petugas Jaga',
    'Area Tertutup',
    'Shuttle Reguler',
    'Car Wash',
  ];

  @override
  void initState() {
    super.initState();
    _priceRange =
        widget.initialFilter?.priceRange ?? const RangeValues(30000, 70000);
    _selectedFacilities = Set.from(widget.initialFilter?.facilities ?? {});
    _parkingType = widget.initialFilter?.parkingType;
    _onlyAccessible = widget.initialFilter?.onlyAccessible ?? false;
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(30000, 70000);
      _selectedFacilities.clear();
      _parkingType = null;
      _onlyAccessible = false;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      SearchFilterResult(
        priceRange: _priceRange,
        facilities: _selectedFacilities,
        parkingType: _parkingType,
        onlyAccessible: _onlyAccessible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Filter Pencarian',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          actions: [
            TextButton(
                onPressed: _reset,
                child: const Text('Reset',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12))),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Rentang Harga per Malam'),
            const SizedBox(height: 4),
            Text(
              'Rp ${_priceRange.start.toStringAsFixed(0)} - Rp ${_priceRange.end.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue),
            ),
            RangeSlider(
              values: _priceRange,
              min: 20000,
              max: 100000,
              divisions: 16,
              activeColor: primaryBlue,
              labels: RangeLabels('Rp ${_priceRange.start.toStringAsFixed(0)}',
                  'Rp ${_priceRange.end.toStringAsFixed(0)}'),
              onChanged: (v) => setState(() => _priceRange = v),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Tipe Lahan Parkir'),
            const SizedBox(height: 10),
            Row(
              children: [
                _typeChip('Semua', null),
                const SizedBox(width: 8),
                _typeChip('Indoor', 'Indoor'),
                const SizedBox(width: 8),
                _typeChip('Outdoor', 'Outdoor'),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('Fasilitas'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allFacilities.map((f) {
                final selected = _selectedFacilities.contains(f);
                return FilterChip(
                  label: Text(f, style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  onSelected: (v) => setState(() => v
                      ? _selectedFacilities.add(f)
                      : _selectedFacilities.remove(f)),
                  selectedColor: primaryBlue.withOpacity(0.15),
                  checkmarkColor: primaryBlue,
                  labelStyle:
                      TextStyle(color: selected ? primaryBlue : Colors.black87),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color:
                              selected ? primaryBlue : Colors.grey.shade300)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _onlyAccessible,
                onChanged: (v) => setState(() => _onlyAccessible = v),
                activeColor: primaryBlue,
                title: const Text('Ramah kursi roda / lansia',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2))
            ]),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Terapkan Filter',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));

  Widget _typeChip(String label, String? value) {
    final selected = _parkingType == value;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label, style: const TextStyle(fontSize: 12))),
        selected: selected,
        onSelected: (_) => setState(() => _parkingType = value),
        selectedColor: primaryBlue,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color: selected ? primaryBlue : Colors.grey.shade300)),
        showCheckmark: false,
      ),
    );
  }
}
