import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/repositories/in_memory_traceability_repository.dart';
import 'traceability_provider.dart';

class TraceabilityProviderSetup extends StatelessWidget {
  final Widget child;

  const TraceabilityProviderSetup({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TraceabilityProvider(
        repository: InMemoryTraceabilityRepository(),
      ),
      child: child,
    );
  }
}