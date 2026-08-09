import 'package:flutter/material.dart';
import 'section_tile.dart';

class SectionTileItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? accentColor;
  final VoidCallback? onTap;

  const SectionTileItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accentColor,
    this.onTap,
  });
}

class SectionGrid extends StatelessWidget {
  final List<SectionTileItem> items;
  final double spacing;
  final int minColumnWidth;
  final double childAspectRatio;

  const SectionGrid({
    super.key,
    required this.items,
    this.spacing = 16,
    this.minColumnWidth = 180,
    this.childAspectRatio = 0.95,
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
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return SectionTile(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              accentColor: item.accentColor,
              onTap: item.onTap,
            );
          },
        );
      },
    );
  }
}