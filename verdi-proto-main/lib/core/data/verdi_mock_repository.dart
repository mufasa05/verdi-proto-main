import '../models/verdi_dashboard_data.dart';

class VerdiMockRepository {
  VerdiDashboardData getDashboardData() {
    return const VerdiDashboardData(
      maizeOutputMt: 1.82,
      milletOutputMt: 0.29,
      sorghumOutputMt: 0.44,
      beefHerdMillions: 5.74,
      dairyHerdThousands: 65.659,
      milkOutputMl: 11.7,
      tobaccoAvgPriceUsd: 3.55,
      activeRoutes: 12,
      pendingPickups: 6,
      inTransit: 18,
      registryCoveragePercent: 78,
      alerts: 7,
    );
  }
}