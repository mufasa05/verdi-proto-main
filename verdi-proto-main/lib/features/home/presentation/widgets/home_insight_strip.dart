import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../state/app_state.dart';
import '../../../../core/enums/verdi_screen.dart';

class HomeInsightStrip extends StatelessWidget {
  const HomeInsightStrip({super.key});

  static const green = Color(0xFF16A34A);
  static const orange = Color(0xFFF97316);
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final items = [
      _InsightCardData(
        title: '3 buyers in Chiredzi need tomatoes',
        subtitle: 'Demand is high near your farm this morning.',
        action: 'View buyers',
        imageUrl: 'https://images.unsplash.com/photo-1546470427-227c2e6b1b4c?auto=format&fit=crop&w=1200&q=80',
        color: green,
        confidence: 0.94,
        targetScreen: VerdiScreen.marketplace,
      ),
      _InsightCardData(
        title: 'Tomato price trend is up 12%',
        subtitle: 'You may want to list more inventory today.',
        action: 'See trend',
        imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=1200&q=80',
        color: orange,
        confidence: 0.85,
        targetScreen: VerdiScreen.analytics,
      ),
      _InsightCardData(
        title: 'Rain expected tomorrow',
        subtitle: 'Delivery timing may need adjustment.',
        action: 'View forecast',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
        color: blue,
        confidence: 0.78,
        targetScreen: VerdiScreen.logistics,
      ),
      _InsightCardData(
        title: 'Crop stress detected in East field',
        subtitle: 'Monitor moisture and leaf health soon.',
        action: 'Check field',
        imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=1200&q=80',
        color: purple,
        confidence: 0.91,
        targetScreen: VerdiScreen.irrigation,
      ),
    ];

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _InsightCard(data: items[index]),
      ),
    );
  }
}

class _InsightCardData {
  final String title;
  final String subtitle;
  final String action;
  final String imageUrl;
  final Color color;
  final double confidence;
  final VerdiScreen targetScreen;

  _InsightCardData({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.imageUrl,
    required this.color,
    required this.confidence,
    required this.targetScreen,
  });
}

class _InsightCard extends ConsumerWidget {
  final _InsightCardData data;

  const _InsightCard({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(appStateProvider.notifier).setNavIndex(data.targetScreen.pageIndex);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 260,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: data.color.withValues(alpha: 0.2),
        ),
        child: Stack(
          children: [
            // Background Image with Error & Loading Fallback for Offline Resilience
            Positioned.fill(
              child: Image.network(
                data.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [data.color.withValues(alpha: 0.8), const Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.offline_bolt_outlined, color: Colors.white70, size: 40),
                    ),
                  );
                },
              ),
            ),

            // Gradient Overlay for readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: data.color.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'AI Insight',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(data.confidence * 100).round()}% Conf.',
                          style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        data.action,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
