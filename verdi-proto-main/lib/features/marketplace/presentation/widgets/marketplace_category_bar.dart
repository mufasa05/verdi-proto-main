import 'package:flutter/material.dart';

class MarketplaceCategoryBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const MarketplaceCategoryBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  static const green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final selected = cat == selectedCategory;
          return FilterChip(
            selected: selected,
            label: Text(cat),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF0F172A),
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
            selectedColor: green,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected ? green : const Color(0xFFE2E8F0),
            ),
            onSelected: (_) => onSelectCategory(cat),
          );
        },
      ),
    );
  }
}
