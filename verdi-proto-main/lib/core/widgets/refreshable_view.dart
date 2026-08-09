import 'package:flutter/material.dart';

class RefreshableView extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const RefreshableView({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}