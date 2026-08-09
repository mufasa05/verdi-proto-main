import 'package:flutter/material.dart';

import '../models/live_ai_event.dart';

class LiveAiEventTile extends StatelessWidget {
  final LiveAiEvent event;

  const LiveAiEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final color = switch (event.severity) {
      LiveAiEventSeverity.low => Colors.blueGrey,
      LiveAiEventSeverity.medium => Colors.blue,
      LiveAiEventSeverity.high => Colors.orange,
      LiveAiEventSeverity.critical => Colors.red,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.bolt, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                event.message,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
