import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DroneMission {
  final String title;
  final String status; // 'Completed' | 'In Flight' | 'Scheduled' | 'Failed'
  final String field;
  final double coverage;
  final int hotspots;

  const DroneMission({
    required this.title,
    required this.status,
    required this.field,
    required this.coverage,
    required this.hotspots,
  });

  DroneMission copyWith({
    String? title,
    String? status,
    String? field,
    double? coverage,
    int? hotspots,
  }) {
    return DroneMission(
      title: title ?? this.title,
      status: status ?? this.status,
      field: field ?? this.field,
      coverage: coverage ?? this.coverage,
      hotspots: hotspots ?? this.hotspots,
    );
  }
}

class IrrigationState {
  final bool pump1Running;
  final bool pump2Running;
  final String valve3AStatus; // 'Fault (Leak)', 'Open (Running)', 'Closed'
  final bool valve3AOpen;
  
  // Zone control grid states (Zone 1 to 4)
  final double zone1Moisture;
  final String zone1NextWatering;
  final String zone1Mode;
  final String zone1Risk;

  final double zone2Moisture;
  final String zone2NextWatering;
  final String zone2Mode;
  final String zone2Risk;

  final double zone3Moisture;
  final String zone3NextWatering;
  final String zone3Mode;
  final String zone3Risk;

  final double zone4Moisture;
  final String zone4NextWatering;
  final String zone4Mode;
  final String zone4Risk;

  // Drone flight control
  final String droneStatus; // 'Idle', 'In Flight', 'Returning'
  final int selectedDroneZone; // 1, 2, 3, 4
  final List<DroneMission> droneMissions;

  const IrrigationState({
    this.pump1Running = true,
    this.pump2Running = false,
    this.valve3AStatus = 'Fault (Leak)',
    this.valve3AOpen = false,
    
    this.zone1Moisture = 0.72,
    this.zone1NextWatering = 'In 3 hours',
    this.zone1Mode = 'Auto',
    this.zone1Risk = 'Low',

    this.zone2Moisture = 0.44,
    this.zone2NextWatering = 'Watering Now',
    this.zone2Mode = 'Manual',
    this.zone2Risk = 'High',

    this.zone3Moisture = 0.58,
    this.zone3NextWatering = 'In 6 hours',
    this.zone3Mode = 'Auto',
    this.zone3Risk = 'Medium',

    this.zone4Moisture = 0.71,
    this.zone4NextWatering = 'Scheduled',
    this.zone4Mode = 'AI Optimised',
    this.zone4Risk = 'None',

    this.droneStatus = 'Idle',
    this.selectedDroneZone = 2,
    this.droneMissions = const [
      DroneMission(title: 'Mvurwi North Survey', status: 'Completed', field: 'Zone 1-3', coverage: 0.94, hotspots: 2),
      DroneMission(title: 'Odzi Field Moisture Scan', status: 'In Flight', field: 'Zone 5', coverage: 0.67, hotspots: 4),
      DroneMission(title: 'Gutu Canal Inspection', status: 'Scheduled', field: 'Zone 7-9', coverage: 0.00, hotspots: 0),
    ],
  });

  IrrigationState copyWith({
    bool? pump1Running,
    bool? pump2Running,
    String? valve3AStatus,
    bool? valve3AOpen,
    
    double? zone1Moisture,
    String? zone1NextWatering,
    String? zone1Mode,
    String? zone1Risk,

    double? zone2Moisture,
    String? zone2NextWatering,
    String? zone2Mode,
    String? zone2Risk,

    double? zone3Moisture,
    String? zone3NextWatering,
    String? zone3Mode,
    String? zone3Risk,

    double? zone4Moisture,
    String? zone4NextWatering,
    String? zone4Mode,
    String? zone4Risk,

    String? droneStatus,
    int? selectedDroneZone,
    List<DroneMission>? droneMissions,
  }) {
    return IrrigationState(
      pump1Running: pump1Running ?? this.pump1Running,
      pump2Running: pump2Running ?? this.pump2Running,
      valve3AStatus: valve3AStatus ?? this.valve3AStatus,
      valve3AOpen: valve3AOpen ?? this.valve3AOpen,
      
      zone1Moisture: zone1Moisture ?? this.zone1Moisture,
      zone1NextWatering: zone1NextWatering ?? this.zone1NextWatering,
      zone1Mode: zone1Mode ?? this.zone1Mode,
      zone1Risk: zone1Risk ?? this.zone1Risk,

      zone2Moisture: zone2Moisture ?? this.zone2Moisture,
      zone2NextWatering: zone2NextWatering ?? this.zone2NextWatering,
      zone2Mode: zone2Mode ?? this.zone2Mode,
      zone2Risk: zone2Risk ?? this.zone2Risk,

      zone3Moisture: zone3Moisture ?? this.zone3Moisture,
      zone3NextWatering: zone3NextWatering ?? this.zone3NextWatering,
      zone3Mode: zone3Mode ?? this.zone3Mode,
      zone3Risk: zone3Risk ?? this.zone3Risk,

      zone4Moisture: zone4Moisture ?? this.zone4Moisture,
      zone4NextWatering: zone4NextWatering ?? this.zone4NextWatering,
      zone4Mode: zone4Mode ?? this.zone4Mode,
      zone4Risk: zone4Risk ?? this.zone4Risk,

      droneStatus: droneStatus ?? this.droneStatus,
      selectedDroneZone: selectedDroneZone ?? this.selectedDroneZone,
      droneMissions: droneMissions ?? this.droneMissions,
    );
  }
}

class IrrigationStateNotifier extends StateNotifier<IrrigationState> {
  IrrigationStateNotifier() : super(const IrrigationState());

  void togglePump1(bool val) {
    state = state.copyWith(pump1Running: val);
  }

  void togglePump2(bool val) {
    state = state.copyWith(pump2Running: val);
  }

  void toggleValve3A(bool val) {
    if (state.valve3AStatus == 'Fault (Leak)') {
      return;
    }
    state = state.copyWith(
      valve3AOpen: val,
      valve3AStatus: val ? 'Open (Running)' : 'Closed',
    );
  }

  void clearValve3AFault() {
    state = state.copyWith(
      valve3AStatus: 'Closed',
      valve3AOpen: false,
    );
  }

  void toggleZoneWatering(int zoneIndex) {
    switch (zoneIndex) {
      case 1:
        final isWatering = state.zone1NextWatering == 'Watering Now';
        state = state.copyWith(
          zone1NextWatering: isWatering ? 'In 3 hours' : 'Watering Now',
          zone1Moisture: isWatering ? 0.72 : 0.85,
        );
        break;
      case 2:
        final isWatering = state.zone2NextWatering == 'Watering Now';
        state = state.copyWith(
          zone2NextWatering: isWatering ? 'Scheduled' : 'Watering Now',
          zone2Moisture: isWatering ? 0.44 : 0.65,
        );
        break;
      case 3:
        final isWatering = state.zone3NextWatering == 'Watering Now';
        state = state.copyWith(
          zone3NextWatering: isWatering ? 'In 6 hours' : 'Watering Now',
          zone3Moisture: isWatering ? 0.58 : 0.78,
        );
        break;
      case 4:
        final isWatering = state.zone4NextWatering == 'Watering Now';
        state = state.copyWith(
          zone4NextWatering: isWatering ? 'Scheduled' : 'Watering Now',
          zone4Moisture: isWatering ? 0.71 : 0.90,
        );
        break;
    }
  }

  void emergencyStop() {
    state = state.copyWith(
      pump1Running: false,
      pump2Running: false,
      valve3AOpen: false,
      valve3AStatus: state.valve3AStatus == 'Fault (Leak)' ? 'Fault (Leak)' : 'Closed',
      zone1NextWatering: state.zone1NextWatering == 'Watering Now' ? 'Scheduled' : state.zone1NextWatering,
      zone2NextWatering: state.zone2NextWatering == 'Watering Now' ? 'Scheduled' : state.zone2NextWatering,
      zone3NextWatering: state.zone3NextWatering == 'Watering Now' ? 'Scheduled' : state.zone3NextWatering,
      zone4NextWatering: state.zone4NextWatering == 'Watering Now' ? 'Scheduled' : state.zone4NextWatering,
    );
  }

  void setSelectedDroneZone(int zone) {
    state = state.copyWith(selectedDroneZone: zone);
  }

  void addDroneMission(DroneMission mission) {
    final updated = List<DroneMission>.from(state.droneMissions)
      ..insert(0, mission);
    state = state.copyWith(droneMissions: updated);
  }

  void launchDroneSurvey(String title, String zoneName) {
    final newMission = DroneMission(
      title: title,
      status: 'In Flight',
      field: zoneName,
      coverage: 0.10,
      hotspots: 0,
    );
    final updatedMissions = List<DroneMission>.from(state.droneMissions)..insert(0, newMission);
    state = state.copyWith(
      droneStatus: 'In Flight',
      droneMissions: updatedMissions,
    );

    // Simulate flight progression
    Timer.periodic(const Duration(seconds: 4), (timer) {
      final currentMissions = state.droneMissions;
      final missionIndex = currentMissions.indexWhere((m) => m.title == title);
      if (missionIndex != -1) {
        final m = currentMissions[missionIndex];
        if (m.coverage >= 0.90) {
          timer.cancel();
          final finalMissions = List<DroneMission>.from(currentMissions)
            ..[missionIndex] = m.copyWith(status: 'Completed', coverage: 1.0, hotspots: 1);
          state = state.copyWith(
            droneStatus: 'Idle',
            droneMissions: finalMissions,
          );
        } else {
          final nextCoverage = (m.coverage + 0.30).clamp(0.0, 1.0);
          final finalMissions = List<DroneMission>.from(currentMissions)
            ..[missionIndex] = m.copyWith(coverage: nextCoverage);
          state = state.copyWith(droneMissions: finalMissions);
        }
      } else {
        timer.cancel();
      }
    });
  }
}

final irrigationStateProvider = StateNotifierProvider<IrrigationStateNotifier, IrrigationState>((ref) {
  return IrrigationStateNotifier();
});
