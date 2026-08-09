import '../../../core/services/verdi_api_service.dart';
import '../../../core/viewmodels/page_view_model.dart';

class FinanceViewModel extends PageViewModel {
  final _api = VerdiApiService.instance;

  List<Map<String, dynamic>> payments = [];

  FinanceViewModel() {
    loadFinance();
  }

  Future<void> loadFinance() async {
    setLoading(
      title: 'Loading finance',
      message: 'Fetching balances and payment records.',
    );

    try {
      payments = await _api.getPayments();
      setContent();
    } catch (_) {
      setEmpty(
        title: 'Unable to load finance data',
        message: 'Check your network connection and try again.',
      );
    }
  }

  Future<void> releasePayment(String id) async {
    await _api.releasePayment(id);
    await loadFinance();
  }
}
