import 'package:flutter/material.dart';
import '../../../core/widgets/placeholder_page.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Marketplace',
      subtitle: 'Commodity listings, buyers, sellers, and pricing updates.',
      icon: Icons.storefront_outlined,
    );
  }
}