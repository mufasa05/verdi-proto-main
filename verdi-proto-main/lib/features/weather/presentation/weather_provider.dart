import 'package:flutter/foundation.dart';
import '../data/weather_model.dart';
import '../data/weather_repository.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository repository;

  WeatherProvider({
    required this.repository,
  });

  WeatherData? weather;
  bool isLoading = false;
  String? error;

  Future<void> loadWeather({bool isDemo = true}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      weather = await repository.fetchWeather(isDemo: isDemo);
    } catch (e) {
      error = e.toString();
      weather = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}