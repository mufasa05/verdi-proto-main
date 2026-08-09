import '../../../core/viewmodels/page_view_model.dart';

class WeatherViewModel extends PageViewModel {
  WeatherViewModel() {
    loadWeather();
  }

  Future<void> loadWeather() async {
    setLoading(
      title: 'Loading weather',
      message: 'Fetching forecasts and alerts.',
    );

    await Future.delayed(const Duration(seconds: 2));

    setContent();
  }
}