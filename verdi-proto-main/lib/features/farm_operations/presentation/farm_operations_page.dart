import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdi/features/irrigation/presentation/farmer_irrigation_view.dart';
import 'package:verdi/features/irrigation/presentation/government_irrigation_view.dart';
import 'package:verdi/state/app_state.dart';

class FarmOperationsPage extends ConsumerWidget {
  const FarmOperationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appStateProvider).role;

    // Government role renders National Schemes & Multi-Project Oversight View
    if (role == UserRole.government) {
      return const GovernmentIrrigationView();
    }

    // Farmer role renders Private Farm Zone Command & Moisture Telemetry View
    final isReadOnly = role != UserRole.farmer && role != UserRole.admin;
    return FarmerIrrigationView(readOnly: isReadOnly);
  }
}
