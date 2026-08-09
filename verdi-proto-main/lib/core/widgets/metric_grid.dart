import 'package:flutter/material.dart';
import 'metric_item.dart';
import 'metric_card.dart';

class MetricGrid extends StatelessWidget {
  final List<MetricItem> items;
  final double spacing;
  final int minColumnWidth;

  const MetricGrid({
    super.key,
    required this.items,
    this.spacing = 16,
    this.minColumnWidth = 220,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minColumnWidth).floor().clamp(1, 6);

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.25,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return MetricCard(
              icon: item.icon,
              label: item.label,
              value: item.value,
              subtitle: item.subtitle,
              accentColor: item.accentColor,
            );
          },
        );
      },
    );
  }
}