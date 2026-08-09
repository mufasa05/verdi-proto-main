import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_models.dart';

class NotificationSummaryCard extends StatelessWidget {
  const NotificationSummaryCard({super.key, required this.summary, required this.unreadCount, required this.criticalCount, required this.insights});

  final String summary;
  final int unreadCount;
  final int criticalCount;
  final List<AiInsight> insights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber),
              const SizedBox(width: 8),
              Text('AI digest', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(summary, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('Unread $unreadCount'), backgroundColor: Colors.white10, labelStyle: const TextStyle(color: Colors.white)),
              Chip(label: Text('Critical $criticalCount'), backgroundColor: Colors.white10, labelStyle: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• ${insight.title}: ${insight.description}', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
              )),
        ],
      ),
    );
  }
}
