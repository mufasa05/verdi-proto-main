import 'weather_model.dart';

/// Abstract repository interface for weather telemetry and forecasting.
abstract class WeatherRepository {
  Future<WeatherData> fetchWeather({
    double? latitude,
    double? longitude,
    String? locationName,
    bool isDemo = false,
  });
}
