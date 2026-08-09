import 'package:flutter/material.dart';
import '../../../core/widgets/placeholder_page.dart';

class GovernmentScreen extends StatelessWidget {
  const GovernmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Government',
      subtitle: 'Policy support, public programs, and compliance tools.',
      icon: Icons.account_balance_outlined,
    );
  }
}