import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';

// =============================================================================
// COLOR PALETTE
// =============================================================================

class TradeColors {
  static const green = Color(0xFF16A34A);
  static const greenLight = Color(0xFFDCFCE7);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const surface = Color(0xFFF8FAFC);
  static const border = Color(0xFFE2E8F0);
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFDC2626);
  static const amber = Color(0xFFF59E0B);
  static const purple = Color(0xFF7C3AED);

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
      case 'in stock':
      case 'cleared':
      case 'delivered':
        return green;
      case 'sent':
      case 'en route':
      case 'dispatched':
      case 'in progress':
        return blue;
      case 'draft':
      case 'pending':
        return amber;
      case 'review':
      case 'expiring':
      case 'partial':
        return orange;
      case 'held':
      case 'cancelled':
      case 'expired':
      case 'rejected':
        return red;
      case 'received':
      case 'completed':
      case 'paid':
        return green;
      case 'reserved':
        return purple;
      default:
        return muted;
    }
  }
}

// =============================================================================
// TRADE STAT TILE
// =============================================================================

class TradeStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final double? trendPercent;
  final Color? valueColor;

  const TradeStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.trendPercent,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? TradeColors.green;
    final hasPositiveTrend = trendPercent != null && trendPercent! >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TradeColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (trendPercent != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasPositiveTrend
                        ? TradeColors.green.withOpacity(0.1)
                        : TradeColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasPositiveTrend ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: hasPositiveTrend ? TradeColors.green : TradeColors.red,
                      ),
                      Text(
                        '${trendPercent!.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasPositiveTrend ? TradeColors.green : TradeColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor ?? TradeColors.dark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 11, color: TradeColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// =============================================================================
// TRADE BADGE (status chip)
// =============================================================================

class TradeBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const TradeBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? TradeColors.statusColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: c,
        ),
      ),
    );
  }
}

// =============================================================================
// GRADE BADGE
// =============================================================================

class GradeBadge extends StatelessWidget {
  final GradeClass grade;

  const GradeBadge({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    final color = switch (grade) {
      GradeClass.a => TradeColors.green,
      GradeClass.b => TradeColors.blue,
      GradeClass.c => TradeColors.orange,
      GradeClass.rejected => TradeColors.red,
    };
    return TradeBadge(label: grade.label, color: color);
  }
}

// =============================================================================
// TRADE PROGRESS BAR
// =============================================================================

class TradeProgressBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color? color;
  final String? label;
  final String? trailingLabel;

  const TradeProgressBar({
    super.key,
    required this.value,
    this.color,
    this.label,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? TradeColors.green;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || trailingLabel != null)
          Row(
            children: [
              if (label != null)
                Text(label!, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
              const Spacer(),
              if (trailingLabel != null)
                Text(trailingLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: TradeColors.dark)),
            ],
          ),
        if (label != null || trailingLabel != null) const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: TradeColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(c),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// TRADE SECTION CARD
// =============================================================================

class TradeSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets? padding;

  const TradeSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TradeColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: TradeColors.dark,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: TradeColors.border),
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TRADE ALERT BANNER
// =============================================================================

class TradeAlertBanner extends StatelessWidget {
  final String message;
  final String severity;
  final VoidCallback? onDismiss;

  const TradeAlertBanner({
    super.key,
    required this.message,
    required this.severity,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (severity.toLowerCase()) {
      'critical' => TradeColors.red,
      'high' => TradeColors.orange,
      'medium' => TradeColors.amber,
      _ => TradeColors.blue,
    };

    final icon = switch (severity.toLowerCase()) {
      'critical' || 'high' => Icons.warning_amber_rounded,
      _ => Icons.info_outline_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
            ),
          ),
          if (onDismiss != null)
            InkWell(
              onTap: onDismiss,
              child: Icon(Icons.close, color: color, size: 16),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// TRUST SCORE RING
// =============================================================================

class TrustScoreRing extends StatelessWidget {
  final double score; // 0.0 – 1.0
  final double size;

  const TrustScoreRing({super.key, required this.score, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final color = score >= 0.85
        ? TradeColors.green
        : score >= 0.65
            ? TradeColors.orange
            : TradeColors.red;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score,
            strokeWidth: 4,
            backgroundColor: TradeColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${(score * 100).round()}',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// METRIC ROW
// =============================================================================

class MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const MetricRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: TradeColors.muted, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? TradeColors.dark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE HEADER
// =============================================================================

class TradePageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;

  const TradePageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: TradeColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: TradeColors.muted)),
                ],
              ),
            ),
            ...?actions,
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// =============================================================================
// FILTER CHIPS ROW
// =============================================================================

class TradeFilterRow extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;

  const TradeFilterRow({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = f == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? TradeColors.green : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? TradeColors.green : TradeColors.border,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : TradeColors.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
