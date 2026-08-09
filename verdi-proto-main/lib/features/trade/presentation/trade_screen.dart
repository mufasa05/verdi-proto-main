import 'package:flutter/material.dart';
import '../../../core/widgets/placeholder_page.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Trade',
      subtitle: 'Trade flows, export records, and cross-border activity.',
      icon: Icons.public_outlined,
    );
  }
}