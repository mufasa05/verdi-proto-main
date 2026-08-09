import 'package:flutter/foundation.dart';

import '../data/mock_weather_repository.dart';
import '../data/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  final MockWeatherRepository repository;

  WeatherProvider({
    required this.repository,
  });

  WeatherData? weather;
  bool isLoading = false;
  String? error;

  Future<void> loadWeather() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      weather = await repository.fetchWeather();
    } catch (e) {
      error = e.toString();
      weather = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}