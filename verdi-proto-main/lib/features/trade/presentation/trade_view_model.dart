import '../../../core/services/verdi_api_service.dart';
import '../../../core/viewmodels/page_view_model.dart';

class TradeViewModel extends PageViewModel {
  final _api = VerdiApiService.instance;

  List<Map<String, dynamic>> orders = [];

  TradeViewModel() {
    loadTrades();
  }

  Future<void> loadTrades() async {
    setLoading(
      title: 'Loading trade data',
      message: 'Retrieving contracts and purchase orders.',
    );

    try {
      orders = await _api.getOrders();
      if (orders.isEmpty) {
        setEmpty(
          title: 'No trades yet',
          message: 'Trade activity will show here once contracts are created.',
        );
      } else {
        setContent();
      }
    } catch (_) {
      setEmpty(
        title: 'Unable to load trades',
        message: 'Check your network connection and try again.',
      );
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _api.updateOrderStatus(id, status);
    await loadTrades();
  }
}