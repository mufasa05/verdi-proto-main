import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartPoint {
  final DateTime time;
  final double value;

  const ChartPoint({
    required this.time,
    required this.value,
  });
}

class ChartState {
  final List<ChartPoint> points;
  final bool streaming;
  final double latestValue;

  const ChartState({
    required this.points,
    required this.streaming,
    required this.latestValue,
  });

  const ChartState.initial()
      : points = const [],
        streaming = false,
        latestValue = 0;

  ChartState copyWith({
    List<ChartPoint>? points,
    bool? streaming,
    double? latestValue,
  }) {
    return ChartState(
      points: points ?? this.points,
      streaming: streaming ?? this.streaming,
      latestValue: latestValue ?? this.latestValue,
    );
  }
}

class ChartNotifier extends StateNotifier<ChartState> {
  ChartNotifier() : super(const ChartState.initial());

  final _random = Random();
  Timer? _timer;

  void addPoint(double value) {
    final next = [
      ...state.points,
      ChartPoint(time: DateTime.now(), value: value),
    ];
    state = state.copyWith(
      points: _trim(next),
      latestValue: value,
    );
  }

  void seed(List<double> values) {
    final seeded = values
        .map((v) => ChartPoint(time: DateTime.now(), value: v))
        .toList();
    state = state.copyWith(
      points: _trim(seeded),
      latestValue: seeded.isEmpty ? 0 : seeded.last.value,
    );
  }

  void startStreaming({
    Duration interval = const Duration(seconds: 2),
    double min = 0,
    double max = 100,
  }) {
    if (state.streaming) return;

    state = state.copyWith(streaming: true);
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      final value = min + _random.nextDouble() * (max - min);
      addPoint(value);
    });
  }

  void stopStreaming() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(streaming: false);
  }

  void reset() {
    stopStreaming();
    state = const ChartState.initial();
  }

  List<ChartPoint> _trim(List<ChartPoint> points, {int maxPoints = 24}) {
    if (points.length <= maxPoints) return points;
    return points.sublist(points.length - maxPoints);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final chartProvider =
    StateNotifierProvider<ChartNotifier, ChartState>((ref) {
  return ChartNotifier();
});