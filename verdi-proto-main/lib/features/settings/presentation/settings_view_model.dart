import '../../../core/viewmodels/page_view_model.dart';

class SettingsViewModel extends PageViewModel {
  SettingsViewModel() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    setLoading(
      title: 'Loading settings',
      message: 'Fetching user preferences and app configuration.',
    );

    await Future.delayed(const Duration(seconds: 2));

    setContent();
  }
}