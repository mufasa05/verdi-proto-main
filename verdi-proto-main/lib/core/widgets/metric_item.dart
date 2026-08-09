import 'package:flutter/material.dart';

class MetricItem {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color? accentColor;

  const MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    this.accentColor,
  });
}