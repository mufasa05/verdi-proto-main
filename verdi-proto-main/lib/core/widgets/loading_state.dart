import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final String title;
  final String message;
  final double? progress;

  const LoadingState({
    super.key,
    this.title = 'Loading...',
    this.message = 'Please wait while data is being prepared.',
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = progress == null
        ? const CircularProgressIndicator()
        : LinearProgressIndicator(value: progress);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}