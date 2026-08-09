import 'package:flutter/material.dart';
import '../../../core/widgets/placeholder_page.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Weather',
      subtitle: 'Weather forecasts, alerts, and farm climate insights.',
      icon: Icons.cloud_outlined,
    );
  }
}