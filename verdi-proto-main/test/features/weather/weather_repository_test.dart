import 'package:flutter_test/flutter_test.dart';
import 'package:verdi/features/weather/data/mock_weather_repository.dart';
import 'package:verdi/features/weather/data/open_meteo_weather_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Weather Repositories', () {
    test('MockWeatherRepository returns valid WeatherData baseline', () async {
      final repo = MockWeatherRepository();
      final data = await repo.fetchWeather(isDemo: true);

      expect(data.location, isNotEmpty);
      expect(data.temperature, isNotNull);
      expect(data.hourly, isNotEmpty);
      expect(data.daily, isNotEmpty);
    });

    test('OpenMeteoWeatherRepository returns valid WeatherData with fallback', () async {
      final repo = OpenMeteoWeatherRepository();
      // In offline / test environment where network might fail, repository falls back gracefully
      final data = await repo.fetchWeather(latitude: -17.8252, longitude: 31.0335);

      expect(data.location, contains('Harare'));
      expect(data.temperature, isNotNull);
      expect(data.humidity, isNotNull);
      expect(data.hourly.length, greaterThanOrEqualTo(1));
    });
  });
}
