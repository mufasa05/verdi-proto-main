import 'package:flutter/material.dart';
import 'empty_state.dart';
import 'error_state.dart';
import 'loading_state.dart';

enum ViewState { loading, empty, error, content }

class StateView extends StatelessWidget {
  final ViewState state;
  final Widget child;
  final String? title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StateView({
    super.key,
    required this.state,
    required this.child,
    this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return LoadingState(
          title: title ?? 'Loading...',
          message: message ?? 'Please wait while data is being prepared.',
        );
      case ViewState.empty:
        return EmptyState(
          icon: icon ?? Icons.inbox_outlined,
          title: title ?? 'No data yet',
          message: message ?? 'There is nothing to display right now.',
          actionLabel: actionLabel,
          onAction: onAction,
        );
      case ViewState.error:
        return ErrorState(
          icon: icon ?? Icons.error_outline,
          title: title ?? 'Something went wrong',
          message: message ?? 'Please try again in a moment.',
          actionLabel: actionLabel,
          onAction: onAction,
        );
      case ViewState.content:
        return child;
    }
  }
}