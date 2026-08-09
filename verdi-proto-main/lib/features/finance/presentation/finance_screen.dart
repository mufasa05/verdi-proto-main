import 'package:flutter/material.dart';
import '../../../core/widgets/placeholder_page.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Finance',
      subtitle: 'Payments, credit tools, invoices, and financial tracking.',
      icon: Icons.payments_outlined,
    );
  }
}