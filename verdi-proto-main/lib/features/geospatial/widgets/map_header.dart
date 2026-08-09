import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedRegion;
  final List<String> regions;
  final ValueChanged<String?> onRegionChanged;
  final String selectedCrop;
  final List<String> crops;
  final ValueChanged<String?> onCropChanged;
  final int totalFields;
  final double avgHealth;

  const MapHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedRegion,
    required this.regions,
    required this.onRegionChanged,
    required this.selectedCrop,
    required this.crops,
    required this.onCropChanged,
    required this.totalFields,
    required this.avgHealth,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spatial Command Center',
                      style: GoogleFonts.inter(
                        fontSize: isDesktop ? 22 : 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor field bounds, crop-health index, and active tasks.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                _statWidget('Fields', totalFields.toString(), Colors.blue),
                const SizedBox(width: 16),
                _statWidget('Avg NDVI', '${(avgHealth * 100).toStringAsFixed(0)}%', Colors.green),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(
                flex: isDesktop ? 2 : 0,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 20),
                    hintText: 'Search fields or crops...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
              ),
              if (!isDesktop) const SizedBox(height: 10),
              if (isDesktop) const SizedBox(width: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRegion,
                        items: regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: onRegionChanged,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCrop,
                        items: crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: onCropChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statWidget(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
