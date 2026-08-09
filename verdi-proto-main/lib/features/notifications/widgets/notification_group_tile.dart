import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_models.dart';
import '../presentation/notification_detail_page.dart';

class NotificationGroupTile extends StatelessWidget {
  const NotificationGroupTile({super.key, required this.group});

  final NotificationGroup group;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NotificationDetailPage(notification: group.notifications.first),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: group.severity == NotificationSeverity.critical ? Colors.red : const Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(group.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  if (group.hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF16A34A).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                      child: const Text('Unread', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(group.summary, style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B))),
              const SizedBox(height: 8),
              Text('${group.notifications.length} items • ${group.category.name}', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8))),
            ],
          ),
        ),
      ),
    );
  }
}
