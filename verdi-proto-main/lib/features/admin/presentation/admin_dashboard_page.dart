import 'package:flutter/material.dart';
import '../../dashboard/presentation/dashboard_page.dart';

/// Admin Command Center Route - Unified Super Administrator Control Tower
class AdminDashboardPage extends StatelessWidget {
  final String? initialSubPageTitle;
  final Widget? initialSubPageWidget;

  const AdminDashboardPage({
    super.key,
    this.initialSubPageTitle,
    this.initialSubPageWidget,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardPage(
      initialSubPageTitle: initialSubPageTitle,
      initialSubPageWidget: initialSubPageWidget,
    );
  }
}
