import '../../../core/viewmodels/page_view_model.dart';

class AnalyticsViewModel extends PageViewModel {
  AnalyticsViewModel() {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    setLoading(
      title: 'Loading analytics',
      message: 'Preparing charts and performance metrics.',
    );

    await Future.delayed(const Duration(seconds: 2));

    setContent();
  }
}