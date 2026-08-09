import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationRulesPage extends ConsumerWidget {
  const NotificationRulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(notificationCenterProvider).rules;

    return Scaffold(
      appBar: AppBar(title: const Text('Notification rules')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: rules.map((rule) => Card(
          child: ListTile(
            title: Text(rule.name),
            subtitle: Text('${rule.category.name} • ${rule.minimumSeverity.name}'),
            trailing: const Icon(Icons.rule_outlined),
          ),
        )).toList(),
      ),
    );
  }
}
