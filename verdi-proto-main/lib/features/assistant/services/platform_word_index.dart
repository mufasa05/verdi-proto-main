class PageMatch {
  final int navIndex;
  final String pageName;
  final String description;

  const PageMatch({
    required this.navIndex,
    required this.pageName,
    required this.description,
  });
}

class DisambiguationResult {
  final String keyword;
  final List<PageMatch> matches;

  const DisambiguationResult({
    required this.keyword,
    required this.matches,
  });
}

class TermLookupResult {
  final bool isDisambiguationNeeded;
  final PageMatch? singleMatch;
  final DisambiguationResult? disambiguation;

  const TermLookupResult.single(PageMatch match)
      : isDisambiguationNeeded = false,
        singleMatch = match,
        disambiguation = null;

  const TermLookupResult.disambiguate(DisambiguationResult result)
      : isDisambiguationNeeded = true,
        singleMatch = null,
        disambiguation = result;

  const TermLookupResult.notFound()
      : isDisambiguationNeeded = false,
        singleMatch = null,
        disambiguation = null;
}

class PlatformWordIndex {
  static final PlatformWordIndex instance = PlatformWordIndex._internal();
  PlatformWordIndex._internal();

  /// Multi-page terms that exist on more than 1 screen.
  static const Map<String, List<PageMatch>> _multiPageTerms = {
    'irrigation': [
      PageMatch(navIndex: 9, pageName: 'Farmer Irrigation', description: 'Smart field watering, soil moisture & valve controls'),
      PageMatch(navIndex: 8, pageName: 'Government Irrigation', description: 'National irrigation schemes, dams & borehole networks'),
    ],
    'trade': [
      PageMatch(navIndex: 19, pageName: 'Regional Trade Hub', description: 'Commodity prices & regional trade intelligence'),
      PageMatch(navIndex: 1, pageName: 'Marketplace', description: 'Buy & sell farm produce, seeds & fertilizers'),
      PageMatch(navIndex: 22, pageName: 'Export & Customs', description: 'ePhyto certificates & cross-border trade'),
    ],
    'dashboard': [
      PageMatch(navIndex: 12, pageName: 'Operations Dashboard', description: 'Farm KPI dashboard & real-time operational overview'),
      PageMatch(navIndex: 3, pageName: 'Performance Analytics', description: 'Crop yield analytics & financial forecasts'),
      PageMatch(navIndex: 23, pageName: 'Admin Command Center', description: 'System status & microservices control center'),
    ],
    'forecast': [
      PageMatch(navIndex: 17, pageName: 'Weather Forecast', description: 'Real-time rain radar, humidity & weather predictions'),
      PageMatch(navIndex: 3, pageName: 'Yield Forecast Analytics', description: 'AI crop harvest & yield projections'),
    ],
    'map': [
      PageMatch(navIndex: 13, pageName: 'Geospatial GIS Map', description: 'Farm boundary, contour & topography mapping'),
      PageMatch(navIndex: 20, pageName: 'Satellite NDVI Map', description: 'Sentinel-2 satellite spectral crop health imagery'),
    ],
    'gis': [
      PageMatch(navIndex: 13, pageName: 'Geospatial GIS Map', description: 'Farm boundary & land mapping'),
      PageMatch(navIndex: 20, pageName: 'Satellite Spectral GIS', description: 'Satellite NDVI imagery map'),
    ],
    'scan': [
      PageMatch(navIndex: 14, pageName: 'Crop Health Disease Scan', description: 'AI leaf disease & pest diagnostic scanner'),
      PageMatch(navIndex: 15, pageName: 'Traceability Batch Scan', description: 'Supply chain QR code & origin batch scanner'),
      PageMatch(navIndex: 10, pageName: 'Drone Aerial Scan', description: 'Automated drone aerial inspection flight'),
    ],
    'voucher': [
      PageMatch(navIndex: 18, pageName: 'Government Subsidies', description: 'E-vouchers & input subsidy programs'),
      PageMatch(navIndex: 8, pageName: 'Government Irrigation Schemes', description: 'State irrigation scheme vouchers'),
    ],
    'water': [
      PageMatch(navIndex: 9, pageName: 'Farmer Irrigation', description: 'Smart field watering & valve control'),
      PageMatch(navIndex: 8, pageName: 'Government Irrigation', description: 'National water resources & dams'),
    ],
  };

  /// Single-page terms mapped directly to their exact page index.
  static const Map<String, PageMatch> _singlePageTerms = {
    'home': PageMatch(navIndex: 0, pageName: 'Home', description: 'Main home screen'),
    'marketplace': PageMatch(navIndex: 1, pageName: 'Marketplace', description: 'Agricultural product catalog & store'),
    'store': PageMatch(navIndex: 1, pageName: 'Marketplace', description: 'Buy farm inputs & equipment'),
    'buy': PageMatch(navIndex: 1, pageName: 'Marketplace', description: 'Purchase seeds, fertilizers & pumps'),
    'fertilizer': PageMatch(navIndex: 1, pageName: 'Marketplace', description: 'NPK fertilizer catalog'),
    'seed': PageMatch(navIndex: 1, pageName: 'Marketplace', description: 'Hybrid seed maize catalog'),
    'assistant': PageMatch(navIndex: 2, pageName: 'AI Assistant', description: 'Verdi AI Assistant & Conversations'),
    'chat': PageMatch(navIndex: 2, pageName: 'AI Assistant', description: 'AI chat messages'),
    'analytics': PageMatch(navIndex: 3, pageName: 'Analytics', description: 'Farm analytics & performance metrics'),
    'yield': PageMatch(navIndex: 3, pageName: 'Analytics', description: 'Crop yield predictions'),
    'orders': PageMatch(navIndex: 4, pageName: 'Orders', description: 'Order history & active shipments'),
    'logistics': PageMatch(navIndex: 5, pageName: 'Logistics', description: 'Fleet tracking & transport logistics'),
    'truck': PageMatch(navIndex: 5, pageName: 'Logistics', description: 'Transport fleet management'),
    'fleet': PageMatch(navIndex: 5, pageName: 'Logistics', description: 'Truck dispatch & cargo tracking'),
    'payments': PageMatch(navIndex: 6, pageName: 'Payments', description: 'Payments & escrow settlement'),
    'escrow': PageMatch(navIndex: 6, pageName: 'Payments', description: 'Escrow payment safety hub'),
    'notifications': PageMatch(navIndex: 7, pageName: 'Notifications', description: 'Notification & alert center'),
    'alerts': PageMatch(navIndex: 7, pageName: 'Notifications', description: 'Unread platform alerts'),
    'farmer irrigation': PageMatch(navIndex: 9, pageName: 'Farmer Irrigation', description: 'Smart field watering & moisture sensors'),
    'government irrigation': PageMatch(navIndex: 8, pageName: 'Government Irrigation', description: 'National irrigation scheme administration'),
    'drone': PageMatch(navIndex: 10, pageName: 'Drone Inspection', description: 'Drone aerial telemetry & flight controls'),
    'aerial': PageMatch(navIndex: 10, pageName: 'Drone Inspection', description: 'Aerial crop scanning'),
    'farm operations': PageMatch(navIndex: 11, pageName: 'Farm Operations', description: 'Field work & labor task management'),
    'tasks': PageMatch(navIndex: 11, pageName: 'Farm Operations', description: 'Daily operational tasks'),
    'operations dashboard': PageMatch(navIndex: 12, pageName: 'Operations Dashboard', description: 'Operations KPI summary'),
    'geospatial': PageMatch(navIndex: 13, pageName: 'Geospatial', description: 'GIS mapping & boundary contours'),
    'crop health': PageMatch(navIndex: 14, pageName: 'Crop Health', description: 'AI crop disease diagnostic scanner'),
    'pest': PageMatch(navIndex: 14, pageName: 'Crop Health', description: 'Pest identification & treatment'),
    'disease': PageMatch(navIndex: 14, pageName: 'Crop Health', description: 'Crop disease diagnostics'),
    'traceability': PageMatch(navIndex: 15, pageName: 'Traceability', description: 'Supply chain QR batch traceability'),
    'finance': PageMatch(navIndex: 16, pageName: 'Finance', description: 'Agri-Wallet & credit score'),
    'wallet': PageMatch(navIndex: 16, pageName: 'Finance', description: 'AgriWallet balance & transactions'),
    'agri wallet': PageMatch(navIndex: 16, pageName: 'Finance', description: 'AgriWallet financing'),
    'weather': PageMatch(navIndex: 17, pageName: 'Weather', description: 'Real-time weather radar & forecast'),
    'rain': PageMatch(navIndex: 17, pageName: 'Weather', description: 'Precipitation radar'),
    'government': PageMatch(navIndex: 18, pageName: 'Government', description: 'Government AgOS & extension services'),
    'subsidies': PageMatch(navIndex: 18, pageName: 'Government', description: 'E-vouchers & input subsidies'),
    'trade hub': PageMatch(navIndex: 19, pageName: 'Regional Trade Hub', description: 'Commodity price index'),
    'prices': PageMatch(navIndex: 19, pageName: 'Regional Trade Hub', description: 'Regional market price exchange'),
    'satellite': PageMatch(navIndex: 20, pageName: 'Satellite', description: 'Sentinel-2 NDVI vegetation imagery'),
    'ndvi': PageMatch(navIndex: 20, pageName: 'Satellite', description: 'Satellite NDVI spectral map'),
    'settings': PageMatch(navIndex: 21, pageName: 'Settings', description: 'App preferences & configuration'),
    'export': PageMatch(navIndex: 22, pageName: 'Export', description: 'ePhyto customs & export clearance'),
    'ephyto': PageMatch(navIndex: 22, pageName: 'Export', description: 'Phytosanitary export certificates'),
    'admin': PageMatch(navIndex: 23, pageName: 'Admin Command Center', description: 'System administration & server health'),
    'command center': PageMatch(navIndex: 23, pageName: 'Admin Command Center', description: 'Platform administration'),
    'news': PageMatch(navIndex: 24, pageName: 'News', description: 'Regional agriculture news feed'),
  };

  /// Analyzes spoken input for platform terms and returns either a direct single match or a disambiguation request if found on > 1 screen.
  TermLookupResult lookupTerm(String prompt) {
    final lower = prompt.toLowerCase().trim();

    // Check multi-page disambiguation terms first
    for (final entry in _multiPageTerms.entries) {
      if (lower.contains(entry.key)) {
        return TermLookupResult.disambiguate(
          DisambiguationResult(
            keyword: entry.key,
            matches: entry.value,
          ),
        );
      }
    }

    // Check single-page terms
    for (final entry in _singlePageTerms.entries) {
      if (lower.contains(entry.key)) {
        return TermLookupResult.single(entry.value);
      }
    }

    return const TermLookupResult.notFound();
  }

  /// Parses user's answer during an active disambiguation prompt (e.g. "Farmer", "Government", "1", "2", "First", "Second")
  PageMatch? parseDisambiguationChoice(String response, List<PageMatch> matches) {
    final lower = response.toLowerCase().trim();

    // Number matching (e.g. "1", "one", "first", "2", "two", "second")
    if (lower.contains('1') || lower.contains('first') || lower.contains('one') || lower.contains('option 1')) {
      return matches.isNotEmpty ? matches[0] : null;
    }
    if (lower.contains('2') || lower.contains('second') || lower.contains('two') || lower.contains('option 2')) {
      return matches.length > 1 ? matches[1] : null;
    }
    if (lower.contains('3') || lower.contains('third') || lower.contains('three') || lower.contains('option 3')) {
      return matches.length > 2 ? matches[2] : null;
    }

    // Name matching (e.g. "farmer", "government", "marketplace", "regional trade", "export", "analytics")
    for (final match in matches) {
      final nameLower = match.pageName.toLowerCase();
      final words = nameLower.split(' ');
      for (final w in words) {
        if (w.length > 3 && lower.contains(w)) {
          return match;
        }
      }
    }

    return null;
  }
}
