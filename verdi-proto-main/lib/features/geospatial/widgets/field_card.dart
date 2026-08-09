import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/geospatial_models.dart';

class FieldCard extends StatelessWidget {
  final GeoField field;
  final VoidCallback onViewDetails;
  final VoidCallback onEditZones;

  const FieldCard({
    super.key,
    required this.field,
    required this.onViewDetails,
    required this.onEditZones,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (field.status.toLowerCase()) {
      'healthy' => const Color(0xFF16A34A),
      'water stress' => const Color(0xFF2563EB),
      'heat stress' => const Color(0xFFF97316),
      _ => const Color(0xFFDC2626),
    };

    final healthColor = field.healthScore >= 0.8
        ? const Color(0xFF16A34A)
        : field.healthScore >= 0.6
            ? const Color(0xFFF97316)
            : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  field.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  field.status,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${field.crop} • ',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              Text(
                '${field.hectares.toStringAsFixed(0)} ha',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NDVI Index',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: healthColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        field.healthScore.toStringAsFixed(2),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: healthColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Last Scan',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    field.lastScoutDate,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 300;
              final btnEdit = OutlinedButton(
                onPressed: onEditZones,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF16A34A)),
                  foregroundColor: const Color(0xFF16A34A),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Edit Zones'),
              );
              final btnDetails = ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Field Details'),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    btnEdit,
                    const SizedBox(height: 8),
                    btnDetails,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: btnEdit),
                  const SizedBox(width: 8),
                  Expanded(child: btnDetails),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
