import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_models.dart';
import '../providers/notification_provider.dart';

class NotificationDetailPage extends ConsumerWidget {
  const NotificationDetailPage({super.key, required this.notification});

  final PlatformNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationCenterProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification details')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.title, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(notification.body, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(notification.module)),
                Chip(label: Text(notification.severity.name.toUpperCase())),
                Chip(label: Text(notification.category.name)),
              ],
            ),
            const SizedBox(height: 24),
            if (notification.aiSummary != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFECFDF3), borderRadius: BorderRadius.circular(14)),
                child: Text(notification.aiSummary!, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      notifier.acknowledge(notification.id);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Acknowledge'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      notifier.resolve(notification.id);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.done_all_outlined),
                    label: const Text('Resolve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
