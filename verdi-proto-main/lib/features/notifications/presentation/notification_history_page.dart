import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationHistoryPage extends ConsumerWidget {
  const NotificationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(notificationCenterProvider).history;

    return Scaffold(
      appBar: AppBar(title: const Text('Notification history')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: history.map((entry) => Card(
          child: ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.detail),
            trailing: Text(entry.status.name),
          ),
        )).toList(),
      ),
    );
  }
}
