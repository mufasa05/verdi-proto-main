import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/geospatial_providers.dart';

class LayerManagerPage extends ConsumerWidget {
  const LayerManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(geoLayerSettingsProvider);
    final notifier = ref.read(geoLayerSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Layer Control Center'),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure Overlay Blends',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Adjust individual layers visibility and opacity overlay weights to analyze crop data.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Base map selector
            _cardHeader('Base Map Style'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Satellite Imagery', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('High-resolution Esri World Imagery tiles'),
                    value: settings.showSatellite,
                    onChanged: (v) => notifier.toggleSatellite(v),
                    activeColor: const Color(0xFF16A34A),
                    secondary: const Icon(Icons.satellite_alt),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Terrain Contours', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('OpenTopoMap elevation shading'),
                    value: settings.showTerrain,
                    onChanged: (v) => notifier.toggleTerrain(v),
                    activeColor: const Color(0xFF16A34A),
                    secondary: const Icon(Icons.filter_hdr_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sensor Layers
            _cardHeader('Precision Sensor Overlays'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NDVI
                  Row(
                    children: [
                      const Icon(Icons.spa_outlined, color: Colors.green),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NDVI Crop Health Indicator', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Visualizes vegetation health scale (0.0 to 1.0)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: settings.showNdvi,
                        onChanged: (v) => notifier.toggleNdvi(v),
                        activeColor: const Color(0xFF16A34A),
                      ),
                    ],
                  ),
                  if (settings.showNdvi) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Opacity: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Expanded(
                          child: Slider(
                            value: settings.opacityNdvi,
                            onChanged: (val) => notifier.setNdviOpacity(val),
                            activeColor: const Color(0xFF16A34A),
                            min: 0.1,
                            max: 1.0,
                          ),
                        ),
                        Text('${(settings.opacityNdvi * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],

                  const Divider(height: 24),

                  // Soil
                  Row(
                    children: [
                      const Icon(Icons.water_drop_outlined, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Soil Moisture Radar', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Sub-surface saturation layers', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: settings.showSoil,
                        onChanged: (v) => notifier.toggleSoil(v),
                        activeColor: const Color(0xFF16A34A),
                      ),
                    ],
                  ),
                  if (settings.showSoil) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Opacity: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Expanded(
                          child: Slider(
                            value: settings.opacitySoil,
                            onChanged: (val) => notifier.setSoilOpacity(val),
                            activeColor: const Color(0xFF16A34A),
                            min: 0.1,
                            max: 1.0,
                          ),
                        ),
                        Text('${(settings.opacitySoil * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],

                  const Divider(height: 24),

                  // Weather
                  Row(
                    children: [
                      const Icon(Icons.thunderstorm_outlined, color: Colors.purple),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Weather Radar Overlay', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Live precipitation radar rings', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: settings.showWeather,
                        onChanged: (v) => notifier.toggleWeather(v),
                        activeColor: const Color(0xFF16A34A),
                      ),
                    ],
                  ),
                  if (settings.showWeather) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Opacity: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Expanded(
                          child: Slider(
                            value: settings.opacityWeather,
                            onChanged: (val) => notifier.setWeatherOpacity(val),
                            activeColor: const Color(0xFF16A34A),
                            min: 0.1,
                            max: 1.0,
                          ),
                        ),
                        Text('${(settings.opacityWeather * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Infrastructure Layers
            _cardHeader('Infrastructure overlays'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: SwitchListTile(
                title: const Text('Irrigation Pipelines', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Water pipes, valves, and pivot paths'),
                value: settings.showIrrigation,
                onChanged: (v) => notifier.toggleIrrigation(v),
                activeColor: const Color(0xFF16A34A),
                secondary: const Icon(Icons.shower_outlined, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
