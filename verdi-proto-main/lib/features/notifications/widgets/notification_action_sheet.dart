import 'package:flutter/material.dart';

class NotificationActionSheet extends StatelessWidget {
  const NotificationActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.check_circle_outline), title: const Text('Acknowledge'), onTap: () {}),
            ListTile(leading: const Icon(Icons.done_all_outlined), title: const Text('Resolve'), onTap: () {}),
            ListTile(leading: const Icon(Icons.open_in_new), title: const Text('Open module'), onTap: () {}),
          ],
        ),
      ),
    );
  }
}
