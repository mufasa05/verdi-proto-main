import 'package:flutter/material.dart';
import 'package:verdi/core/widgets/verdi_page_scaffold.dart';
import '../../shell/presentation/verdi_destinations.dart';

class MorePage extends StatelessWidget {
  final void Function(int index) onSelectDestination;

  const MorePage({super.key, required this.onSelectDestination});

  @override
  Widget build(BuildContext context) {
    final remainingDestinations = verdiDestinations.sublist(5);
    final moreDestinationIndexes = [17, 2, 3, 22];

    return VerdiPageScaffold(
      title: 'More',
      subtitle: 'Additional sections and settings.',
      child: ListView.separated(
        itemCount: remainingDestinations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final destination = remainingDestinations[index];
          final actualIndex = moreDestinationIndexes[index];

          return Card(
            child: ListTile(
              leading: Icon(destination.icon),
              title: Text(destination.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelectDestination(actualIndex),
            ),
          );
        },
      ),
    );
  }
}
