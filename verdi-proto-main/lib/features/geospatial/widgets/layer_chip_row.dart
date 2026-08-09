import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/geospatial_providers.dart';

class LayerChipRow extends ConsumerWidget {
  const LayerChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(geoLayerSettingsProvider);
    final notifier = ref.read(geoLayerSettingsProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _layerChip(
            context: context,
            label: 'Satellite',
            icon: Icons.satellite_alt_outlined,
            selected: settings.showSatellite,
            onSelected: (v) => notifier.toggleSatellite(v),
          ),
          const SizedBox(width: 8),
          _layerChip(
            context: context,
            label: 'Crop Health (NDVI)',
            icon: Icons.spa_outlined,
            selected: settings.showNdvi,
            onSelected: (v) => notifier.toggleNdvi(v),
          ),
          const SizedBox(width: 8),
          _layerChip(
            context: context,
            label: 'Soil Moisture',
            icon: Icons.water_drop_outlined,
            selected: settings.showSoil,
            onSelected: (v) => notifier.toggleSoil(v),
          ),
          const SizedBox(width: 8),
          _layerChip(
            context: context,
            label: 'Weather Radar',
            icon: Icons.thunderstorm_outlined,
            selected: settings.showWeather,
            onSelected: (v) => notifier.toggleWeather(v),
          ),
          const SizedBox(width: 8),
          _layerChip(
            context: context,
            label: 'Terrain (Topography)',
            icon: Icons.filter_hdr_outlined,
            selected: settings.showTerrain,
            onSelected: (v) => notifier.toggleTerrain(v),
          ),
          const SizedBox(width: 8),
          _layerChip(
            context: context,
            label: 'Irrigation Map',
            icon: Icons.shower_outlined,
            selected: settings.showIrrigation,
            onSelected: (v) => notifier.toggleIrrigation(v),
          ),
        ],
      ),
    );
  }

  Widget _layerChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    const activeColor = Color(0xFF16A34A);

    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : Colors.grey.shade700,
      ),
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: activeColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : Colors.grey.shade800,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? activeColor : Colors.black12,
          width: 1,
        ),
      ),
      elevation: 0,
      pressElevation: 1,
    );
  }
}
