import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({super.key, required this.selectedFilter, required this.selectedModule, required this.onFilterChanged, required this.onModuleChanged});

  final String selectedFilter;
  final String selectedModule;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onModuleChanged;

  @override
  Widget build(BuildContext context) {
    final filters = ['all', 'unread', 'critical', 'action required', 'resolved'];
    final modules = ['all', 'Crop Health', 'Orders', 'Payments', 'Weather', 'Chats', 'Logistics'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) => ChoiceChip(
              label: Text(filter),
              selected: selectedFilter == filter,
              onSelected: (_) => onFilterChanged(filter),
            )).toList(),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedModule,
            decoration: const InputDecoration(labelText: 'Module'),
            items: modules.map((module) => DropdownMenuItem(value: module, child: Text(module))).toList(),
            onChanged: (value) => onModuleChanged(value ?? 'all'),
          ),
        ],
      ),
    );
  }
}
