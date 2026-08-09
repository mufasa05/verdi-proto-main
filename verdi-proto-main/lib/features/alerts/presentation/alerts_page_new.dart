import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  static const _alerts = [
    _AlertItem(
      title: 'Weather alert',
      details: 'Heavy rain expected later today in western regions.',
      time: '2m ago',
      severity: 'High',
    ),
    _AlertItem(
      title: 'Supply delay',
      details: 'Fertilizer shipment delayed by 3 hours.',
      time: '12m ago',
      severity: 'Medium',
    ),
    _AlertItem(
      title: 'Equipment warning',
      details: 'Irrigation pump #4 requires service.',
      time: '1h ago',
      severity: 'Low',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Alerts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: _alerts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final alert = _alerts[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: alert.severity == 'High'
                                ? Colors.red.shade50
                                : alert.severity == 'Medium'
                                ? Colors.orange.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            alert.severity,
                            style: TextStyle(
                              color: alert.severity == 'High'
                                  ? Colors.red.shade700
                                  : alert.severity == 'Medium'
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert.details,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      alert.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AlertItem {
  final String title;
  final String details;
  final String time;
  final String severity;

  const _AlertItem({
    required this.title,
    required this.details,
    required this.time,
    required this.severity,
  });
}
