class WeatherAlert {
  final String title;
  final String message;
  final String severity;

  const WeatherAlert({
    required this.title,
    required this.message,
    required this.severity,
  });
}

class HourlyForecast {
  final String time;
  final int temperature;
  final String condition;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });
}

class DailyForecast {
  final String day;
  final int minTemp;
  final int maxTemp;
  final String condition;

  const DailyForecast({
    required this.day,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
  });
}

class WeatherData {
  final String location;
  final String summary;
  final int temperature;
  final int feelsLike;
  final int humidity;
  final int windSpeed;
  final int pressure;
  final int rainChance;
  final int visibility;
  final List<WeatherAlert> alerts;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const WeatherData({
    required this.location,
    required this.summary,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.rainChance,
    required this.visibility,
    required this.alerts,
    required this.hourly,
    required this.daily,
  });
}