import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/geospatial_models.dart';

class ObservationCard extends StatelessWidget {
  final GeoObservation observation;
  final VoidCallback? onDelete;

  const ObservationCard({
    super.key,
    required this.observation,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (observation.severity.toLowerCase()) {
      'high' => const Color(0xFFDC2626),
      'medium' => const Color(0xFFF97316),
      _ => const Color(0xFF2563EB),
    };

    final icon = switch (observation.issueType.toLowerCase()) {
      'pest' => Icons.bug_report_outlined,
      'disease' => Icons.coronavirus_outlined,
      'water' => Icons.water_drop_outlined,
      'weed' => Icons.grass_outlined,
      _ => Icons.info_outline,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: severityColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  observation.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  observation.severity,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: severityColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Scouted: ${observation.date}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            observation.notes,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.35),
          ),
        ],
      ),
    );
  }
}
