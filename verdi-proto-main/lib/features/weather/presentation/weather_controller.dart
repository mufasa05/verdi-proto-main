import 'package:flutter/foundation.dart';
import '../data/weather_model.dart';
import '../data/weather_repository.dart';

class WeatherController extends ChangeNotifier {
  final WeatherRepository repository;

  WeatherController({required this.repository});

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
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}