import 'package:flutter/material.dart';
import '../../../core/widgets/placeholder_page.dart';

class LogisticsScreen extends StatelessWidget {
  const LogisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Logistics',
      subtitle: 'Transport tracking, delivery planning, and route status.',
      icon: Icons.local_shipping_outlined,
    );
  }
}