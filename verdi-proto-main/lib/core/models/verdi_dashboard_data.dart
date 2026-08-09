class VerdiDashboardData {
  final double maizeOutputMt;
  final double milletOutputMt;
  final double sorghumOutputMt;
  final double beefHerdMillions;
  final double dairyHerdThousands;
  final double milkOutputMl;
  final double tobaccoAvgPriceUsd;
  final int activeRoutes;
  final int pendingPickups;
  final int inTransit;
  final int registryCoveragePercent;
  final int alerts;

  const VerdiDashboardData({
    required this.maizeOutputMt,
    required this.milletOutputMt,
    required this.sorghumOutputMt,
    required this.beefHerdMillions,
    required this.dairyHerdThousands,
    required this.milkOutputMl,
    required this.tobaccoAvgPriceUsd,
    required this.activeRoutes,
    required this.pendingPickups,
    required this.inTransit,
    required this.registryCoveragePercent,
    required this.alerts,
  });
}