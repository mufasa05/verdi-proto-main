import '../../../core/services/verdi_api_service.dart';
import '../../../core/viewmodels/page_view_model.dart';

class LogisticsViewModel extends PageViewModel {
  final _api = VerdiApiService.instance;

  List<Map<String, dynamic>> dispatches = [];

  LogisticsViewModel() {
    loadLogistics();
  }

  Future<void> loadLogistics() async {
    setLoading(
      title: 'Loading logistics',
      message: 'Fetching routes and delivery statuses.',
    );

    try {
      dispatches = await _api.getDispatches();
      setContent();
    } catch (_) {
      setEmpty(
        title: 'Unable to load logistics',
        message: 'Check your network connection and try again.',
      );
    }
  }

  Future<void> updateStatus(String id, String status) async {
    await _api.updateDispatchStatus(id, status);
    await loadLogistics();
  }
}