import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeIntelligencePage extends ConsumerWidget {
  const TradeIntelligencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prices = ref.watch(pricePointProvider);
    final batches = ref.watch(stockBatchProvider);
    final salesOrders = ref.watch(salesOrderProvider);

    final revenueMtd = salesOrders.where((so) => so.status != 'Cancelled').fold<double>(0, (s, so) => s + so.totalValue);
    final costMtd = salesOrders.where((so) => so.status != 'Cancelled').fold<double>(0, (s, so) => s + so.totalValue * 0.72);
    final marginMtd = revenueMtd - costMtd;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TradePageHeader(
            title: 'Intelligence Layer',
            subtitle: 'Pricing trends, demand forecasts, stock risk, and margin analytics.',
          ),
          // AI insight cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _InsightCard(
                  icon: Icons.refresh_outlined,
                  title: 'Reorder Alert',
                  description: 'Reorder 5t Potatoes from Eastern Highlands Produce within 10 days.',
                  color: TradeColors.orange,
                ),
                const SizedBox(width: 12),
                _InsightCard(
                  icon: Icons.wb_sunny_outlined,
                  title: 'Surplus Match',
                  description: '4.8t Mangoes can be matched with OK Zimbabwe buyer before expiry.',
                  color: TradeColors.blue,
                ),
                const SizedBox(width: 12),
                _InsightCard(
                  icon: Icons.warning_amber_outlined,
                  title: 'Spoilage Risk',
                  description: 'Mango batch BAT-004 has high spoilage risk. Dispatch within 48h.',
                  color: TradeColors.red,
                ),
                const SizedBox(width: 12),
                _InsightCard(
                  icon: Icons.trending_up_outlined,
                  title: 'Price Opportunity',
                  description: 'Mango prices up 5.6%. Lock in spot sales this week to maximise margin.',
                  color: TradeColors.green,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Price trend chart + stock risk
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final priceChart = TradeSectionCard(
              title: 'Price Trends — Last 30 Days',
              child: SizedBox(
                height: 220,
                child: _PriceTrendChart(prices: prices),
              ),
            );
            final stockRisk = TradeSectionCard(
              title: 'Stock Risk Analysis',
              child: Column(
                children: [
                  // Table header
                  Row(
                    children: const [
                      Expanded(child: Text('Product', style: TextStyle(fontSize: 11, color: TradeColors.muted, fontWeight: FontWeight.w700))),
                      SizedBox(width: 70, child: Text('Stock (kg)', style: TextStyle(fontSize: 11, color: TradeColors.muted, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                      SizedBox(width: 70, child: Text('Risk', style: TextStyle(fontSize: 11, color: TradeColors.muted, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                    ],
                  ),
                  const Divider(height: 14, color: TradeColors.border),
                  for (final batch in batches) ...[
                    _StockRiskRow(batch: batch),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            );
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: priceChart),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: stockRisk),
                ],
              );
            }
            return Column(children: [priceChart, const SizedBox(height: 16), stockRisk]);
          }),
          const SizedBox(height: 16),
          // Demand forecast + margin
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final demandForecast = TradeSectionCard(
              title: 'Demand Forecast — Next 4 Weeks',
              child: SizedBox(
                height: 200,
                child: _DemandForecastChart(),
              ),
            );
            final marginCard = TradeSectionCard(
              title: 'Margin Analysis — MTD',
              child: Column(
                children: [
                  MetricRow(label: 'Revenue', value: 'US\$ ${revenueMtd.toStringAsFixed(2)}', valueColor: TradeColors.green),
                  MetricRow(label: 'Cost of Goods', value: 'US\$ ${costMtd.toStringAsFixed(2)}', valueColor: TradeColors.orange),
                  MetricRow(label: 'Gross Margin', value: 'US\$ ${marginMtd.toStringAsFixed(2)}', valueColor: TradeColors.blue),
                  const SizedBox(height: 10),
                  TradeProgressBar(
                    value: revenueMtd == 0 ? 0 : marginMtd / revenueMtd,
                    color: TradeColors.blue,
                    label: 'Margin %',
                    trailingLabel: '${revenueMtd == 0 ? 0 : ((marginMtd / revenueMtd) * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 16),
                  // Per-product margin bars
                  for (final price in prices) ...[
                    _ProductMarginBar(product: price.productName, pricePer100kg: price.pricePer100kg),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            );
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: demandForecast),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: marginCard),
                ],
              );
            }
            return Column(children: [demandForecast, const SizedBox(height: 16), marginCard]);
          }),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

// =============================================================================
// AI INSIGHT CARD
// =============================================================================

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 12, color: TradeColors.muted, height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PRICE TREND CHART (fl_chart LineChart)
// =============================================================================

class _PriceTrendChart extends StatelessWidget {
  final List<PricePoint> prices;

  const _PriceTrendChart({required this.prices});

  // Mock 30-day trend data per product
  static const _trendData = {
    'White Maize': [42.0, 43.5, 43.0, 44.5, 44.0, 45.0, 46.0, 47.0, 46.5, 48.0, 49.0, 50.0, 51.0, 52.0, 51.5, 53.0, 52.5, 54.0, 55.0],
    'Potatoes': [55.0, 53.0, 52.0, 51.5, 50.5, 51.0, 50.0, 49.5, 50.0, 49.0, 48.0, 48.5, 49.0, 50.0, 50.5, 50.0, 49.5, 50.0, 50.0],
    'Mangoes': [90.0, 92.0, 94.0, 96.0, 95.0, 98.0, 100.0, 102.0, 104.0, 106.0, 105.0, 107.0, 108.0, 109.0, 110.0, 108.0, 110.0, 111.0, 110.0],
  };

  static const _colors = [TradeColors.green, TradeColors.blue, TradeColors.orange];

  @override
  Widget build(BuildContext context) {
    final keys = _trendData.keys.toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: TradeColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toInt()}',
                style: const TextStyle(fontSize: 9, color: TradeColors.muted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 != 0) return const SizedBox.shrink();
                return Text('D${value.toInt()}', style: const TextStyle(fontSize: 9, color: TradeColors.muted));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: List.generate(keys.length, (i) {
          final data = _trendData[keys[i]]!;
          final color = _colors[i % _colors.length];
          return LineChartBarData(
            spots: List.generate(data.length, (j) => FlSpot(j.toDouble(), data[j])),
            isCurved: true,
            color: color,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.07),
            ),
          );
        }),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => TradeColors.dark,
            getTooltipItems: (spots) => spots.map((s) {
              final productName = keys[s.barIndex];
              return LineTooltipItem(
                '$productName\nUS\$ ${s.y.toStringAsFixed(0)}/100kg',
                const TextStyle(color: Colors.white, fontSize: 10),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DEMAND FORECAST CHART (fl_chart BarChart)
// =============================================================================

class _DemandForecastChart extends StatelessWidget {
  static const _products = ['Maize', 'Potatoes', 'Mangoes', 'Onions'];
  static const _weeks = ['Wk 27', 'Wk 28', 'Wk 29', 'Wk 30'];
  static const _forecast = [
    [180.0, 195.0, 210.0, 225.0], // Maize (tonnes)
    [80.0, 75.0, 70.0, 85.0],    // Potatoes
    [40.0, 35.0, 48.0, 52.0],    // Mangoes
    [30.0, 32.0, 28.0, 35.0],    // Onions
  ];
  static const _colors = [TradeColors.green, TradeColors.blue, TradeColors.orange, TradeColors.purple];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 250,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: TradeColors.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text(
                _weeks[value.toInt() % _weeks.length],
                style: const TextStyle(fontSize: 9, color: TradeColors.muted),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, _) => Text('${value.toInt()}t', style: const TextStyle(fontSize: 9, color: TradeColors.muted)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(_weeks.length, (weekIdx) {
          return BarChartGroupData(
            x: weekIdx,
            barRods: List.generate(_products.length, (prodIdx) {
              return BarChartRodData(
                toY: _forecast[prodIdx][weekIdx],
                color: _colors[prodIdx].withOpacity(0.8),
                width: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              );
            }),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// STOCK RISK ROW
// =============================================================================

class _StockRiskRow extends StatelessWidget {
  final StockBatch batch;

  const _StockRiskRow({required this.batch});

  @override
  Widget build(BuildContext context) {
    final risk = batch.quantityKg < 1000
        ? 'Critical'
        : batch.quantityKg < 3000
            ? 'Medium'
            : 'Low';
    final riskColor = switch (risk) {
      'Critical' => TradeColors.red,
      'Medium' => TradeColors.orange,
      _ => TradeColors.green,
    };

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(batch.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TradeColors.dark)),
              Text(batch.lotNumber, style: const TextStyle(fontSize: 10, color: TradeColors.muted)),
            ],
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            '${batch.quantityKg.round()}kg',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          width: 70,
          child: Align(
            alignment: Alignment.centerRight,
            child: TradeBadge(label: risk, color: riskColor),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PRODUCT MARGIN BAR
// =============================================================================

class _ProductMarginBar extends StatelessWidget {
  final String product;
  final double pricePer100kg;

  const _ProductMarginBar({required this.product, required this.pricePer100kg});

  @override
  Widget build(BuildContext context) {
    final marginPct = 0.28; // 28% margin assumption
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(product, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
            Text(
              '${(marginPct * 100).toStringAsFixed(0)}% margin',
              style: const TextStyle(fontSize: 11, color: TradeColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TradeProgressBar(value: marginPct, color: TradeColors.blue),
      ],
    );
  }
}
