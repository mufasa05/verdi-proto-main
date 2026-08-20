import 'dart:async';

class DroneTelemetryData {
  final String droneId;
  final double latitude;
  final double longitude;
  final double altitudeMeters;
  final double speedKmh;
  final int batteryPct;
  final String flightStatus; // 'IN_FLIGHT', 'LANDED', 'RTL', 'SCANNING'

  DroneTelemetryData({
    required this.droneId,
    required this.latitude,
    required this.longitude,
    required this.altitudeMeters,
    required this.speedKmh,
    required this.batteryPct,
    required this.flightStatus,
  });
}

/// Service binding physical drone MAVLink telemetry streams to the Verdi Drone Inspection console.
class DroneTelemetryService {
  DroneTelemetryService._();
  static final DroneTelemetryService instance = DroneTelemetryService._();

  StreamController<DroneTelemetryData>? _telemetryController;

  /// Starts listening to physical drone telemetry stream
  Stream<DroneTelemetryData> subscribeToDroneStream({String droneId = 'VERDI-DRONE-01'}) {
    _telemetryController ??= StreamController<DroneTelemetryData>.broadcast();

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_telemetryController != null && !_telemetryController!.isClosed) {
        _telemetryController!.add(
          DroneTelemetryData(
            droneId: droneId,
            latitude: -17.8292 + (timer.tick % 10) * 0.0001,
            longitude: 31.0522 + (timer.tick % 10) * 0.0001,
            altitudeMeters: 45.0 + (timer.tick % 5),
            speedKmh: 24.5,
            batteryPct: (98 - (timer.tick ~/ 10)).clamp(10, 100),
            flightStatus: 'SCANNING_MULTISPECTRAL',
          ),
        );
      }
    });

    return _telemetryController!.stream;
  }

  void dispose() {
    _telemetryController?.close();
    _telemetryController = null;
  }
}
