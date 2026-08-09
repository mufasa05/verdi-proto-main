import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/verdi_api_service.dart';

class GovernmentPermit {
  final String id;
  final String permitNumber;
  final String cropType;
  final double quantityTonnes;
  final String status;
  final String applicantName;
  final String dateIssued;

  const GovernmentPermit({
    required this.id,
    required this.permitNumber,
    required this.cropType,
    required this.quantityTonnes,
    required this.status,
    required this.applicantName,
    required this.dateIssued,
  });

  factory GovernmentPermit.fromJson(Map<String, dynamic> json) {
    return GovernmentPermit(
      id: json['id']?.toString() ?? '',
      permitNumber: json['permitNumber']?.toString() ?? '',
      cropType: json['cropType']?.toString() ?? '',
      quantityTonnes: (json['quantityTonnes'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'Pending',
      applicantName: json['applicantName']?.toString() ?? '',
      dateIssued: json['dateIssued']?.toString() ?? '',
    );
  }
}

class GovernmentPermitsState {
  final List<GovernmentPermit> permits;
  final bool isLoading;
  final String? error;

  const GovernmentPermitsState({
    required this.permits,
    required this.isLoading,
    this.error,
  });

  static const initial =
      GovernmentPermitsState(permits: [], isLoading: true);

  GovernmentPermitsState copyWith({
    List<GovernmentPermit>? permits,
    bool? isLoading,
    String? error,
  }) {
    return GovernmentPermitsState(
      permits: permits ?? this.permits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GovernmentPermitsNotifier
    extends StateNotifier<GovernmentPermitsState> {
  final _api = VerdiApiService.instance;

  GovernmentPermitsNotifier() : super(GovernmentPermitsState.initial) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _api.getGovernmentPermits();
      state = state.copyWith(
        permits: data.map(GovernmentPermit.fromJson).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approvePermit(String id) async {
    await _api.approvePermit(id);
    await load();
  }
}

final governmentPermitsProvider =
    StateNotifierProvider<GovernmentPermitsNotifier, GovernmentPermitsState>(
  (ref) => GovernmentPermitsNotifier(),
);
