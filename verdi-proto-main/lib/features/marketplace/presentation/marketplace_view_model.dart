import '../../../core/services/verdi_api_service.dart';
import '../../../core/viewmodels/page_view_model.dart';

class MarketplaceViewModel extends PageViewModel {
  final _api = VerdiApiService.instance;

  List<Map<String, dynamic>> listings = [];

  MarketplaceViewModel() {
    loadMarketplace();
  }

  Future<void> loadMarketplace() async {
    setLoading(
      title: 'Loading marketplace',
      message: 'Fetching listings and pricing data.',
    );

    try {
      listings = await _api.getMarketplaceListings();
      if (listings.isEmpty) {
        setEmpty(
          title: 'No marketplace listings',
          message: 'Listings will appear here once farmers post produce.',
        );
      } else {
        setContent();
      }
    } catch (_) {
      setEmpty(
        title: 'Unable to load marketplace',
        message: 'Check your network connection and try again.',
      );
    }
  }
}