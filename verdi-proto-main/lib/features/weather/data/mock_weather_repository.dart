import 'weather_model.dart';

class MockWeatherRepository {
  Future<WeatherData> fetchWeather() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const WeatherData(
      location: 'Harare, Zimbabwe',
      summary: 'Mostly cloudy with a chance of afternoon rain',
      temperature: 27,
      feelsLike: 29,
      humidity: 68,
      windSpeed: 14,
      pressure: 1016,
      rainChance: 40,
      visibility: 8,
      alerts: [
        WeatherAlert(
          title: 'Rain alert',
          message: 'Heavy rain expected later today in western regions.',
          severity: 'High',
        ),
      ],
      hourly: [
        HourlyForecast(time: '10 AM', temperature: 27, condition: 'Cloudy'),
        HourlyForecast(time: '11 AM', temperature: 28, condition: 'Cloudy'),
        HourlyForecast(time: '12 PM', temperature: 29, condition: 'Rain'),
        HourlyForecast(time: '01 PM', temperature: 28, condition: 'Rain'),
        HourlyForecast(time: '02 PM', temperature: 27, condition: 'Storm'),
        HourlyForecast(time: '03 PM', temperature: 26, condition: 'Storm'),
      ],
      daily: [
        DailyForecast(day: 'Today', minTemp: 22, maxTemp: 29, condition: 'Rain'),
        DailyForecast(day: 'Fri', minTemp: 21, maxTemp: 28, condition: 'Cloudy'),
        DailyForecast(day: 'Sat', minTemp: 20, maxTemp: 30, condition: 'Sunny'),
        DailyForecast(day: 'Sun', minTemp: 21, maxTemp: 31, condition: 'Storm'),
      ],
    );
  }
}