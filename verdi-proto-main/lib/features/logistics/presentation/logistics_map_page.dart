import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'widgets/tracking_map.dart';

class LogisticsMapPage extends StatelessWidget {
  final LatLng startPoint;
  final LatLng stopPoint;
  final String startLabel;
  final String stopLabel;
  final String eta;
  final String distance;
  final String title;

  const LogisticsMapPage({
    super.key,
    required this.startPoint,
    required this.stopPoint,
    required this.startLabel,
    required this.stopLabel,
    required this.eta,
    required this.distance,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: TrackingMap(
                  startPoint: startPoint,
                  stopPoint: stopPoint,
                  startLabel: startLabel,
                  stopLabel: stopLabel,
                  eta: eta,
                  distance: distance,
                  height: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
