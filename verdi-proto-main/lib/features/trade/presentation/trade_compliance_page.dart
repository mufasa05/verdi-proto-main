import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeCompliancePage extends ConsumerStatefulWidget {
  const TradeCompliancePage({super.key});

  @override
  ConsumerState<TradeCompliancePage> createState() => _TradeCompliancePageState();
}

class _TradeCompliancePageState extends ConsumerState<TradeCompliancePage> {
  String _filter = 'All';
  int _tabIndex = 0;

  final _filters = ['All', 'Active', 'Expiring', 'Expired', 'Pending'];

  List<ComplianceRecord> _filtered(List<ComplianceRecord> all) {
    if (_filter == 'All') return all;
    return all.where((c) => c.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allCerts = ref.watch(complianceProvider);
    final auditLog = ref.watch(auditLogProvider);
    final filtered = _filtered(allCerts);

    final activeCount = allCerts.where((c) => c.status == 'Active').length;
    final expiringCount = allCerts.where((c) => c.status == 'Expiring').length;
    final expiredCount = allCerts.where((c) => c.status == 'Expired').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TradePageHeader(
            title: 'Compliance Layer',
            subtitle: 'Certifications, licenses, regulatory standards, and audit trail.',
            actions: [
              OutlinedButton.icon(
                onPressed: () => _showExportDialog(context),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Export Pack'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: TradeColors.green,
                  side: const BorderSide(color: TradeColors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          // KPI row
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth >= 600 ? 4 : 2;
            final ratio = c.maxWidth >= 600 ? 1.8 : 1.35;
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: ratio,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                TradeStatTile(label: 'Total Certs', value: '${allCerts.length}', icon: Icons.verified_user_outlined),
                TradeStatTile(label: 'Active', value: '$activeCount', icon: Icons.check_circle_outline, iconColor: TradeColors.green, valueColor: TradeColors.green),
                TradeStatTile(label: 'Expiring', value: '$expiringCount', icon: Icons.access_time_outlined, iconColor: TradeColors.orange, valueColor: expiringCount > 0 ? TradeColors.orange : null),
                TradeStatTile(label: 'Expired', value: '$expiredCount', icon: Icons.cancel_outlined, iconColor: expiredCount > 0 ? TradeColors.red : TradeColors.muted, valueColor: expiredCount > 0 ? TradeColors.red : null),
              ],
            );
          }),
          const SizedBox(height: 16),
          // Compliance tabs
          Row(
            children: [
              _ComplianceTab(label: 'Certificates', isSelected: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
              const SizedBox(width: 10),
              _ComplianceTab(label: 'Audit Log', isSelected: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
            ],
          ),
          const SizedBox(height: 16),
          if (_tabIndex == 0) ...[
            // Cert filter
            TradeFilterRow(filters: _filters, selected: _filter, onSelect: (f) => setState(() => _filter = f)),
            const SizedBox(height: 16),
            // Cert cards
            if (filtered.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No certificates found.', style: TextStyle(color: TradeColors.muted))))
            else
              for (final cert in filtered) ...[
                _CertCard(cert: cert),
                const SizedBox(height: 12),
              ],
          ] else ...[
            // Audit log
            TradeSectionCard(
              title: 'Audit Trail',
              trailing: Text('${auditLog.length} events', style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
              child: Column(
                children: auditLog.map((entry) => _AuditEntry(entry: entry)).toList(),
              ),
            ),
          ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Compliance Pack'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select export contents:'),
            const SizedBox(height: 12),
            ...[
              'Certificate Registry',
              'Audit Trail (last 90 days)',
              'QC Reports',
              'Supplier Compliance Status',
            ].map(
              (item) => CheckboxListTile(
                title: Text(item, style: const TextStyle(fontSize: 13)),
                value: true,
                onChanged: (_) {},
                activeColor: TradeColors.green,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TradeColors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ComplianceTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? TradeColors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? TradeColors.green : TradeColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : TradeColors.muted,
          ),
        ),
      ),
    );
  }
}

class _CertCard extends StatelessWidget {
  final ComplianceRecord cert;

  const _CertCard({required this.cert});

  @override
  Widget build(BuildContext context) {
    final statusColor = TradeColors.statusColor(cert.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cert.status == 'Expired'
              ? TradeColors.red.withOpacity(0.4)
              : cert.status == 'Expiring'
                  ? TradeColors.orange.withOpacity(0.4)
                  : TradeColors.border,
        ),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.verified_user_outlined, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cert.certType} — ${cert.entityName}',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: TradeColors.dark),
                    ),
                    Text('Issued by ${cert.issuedBy}', style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
                  ],
                ),
              ),
              TradeBadge(label: cert.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CertMeta(label: 'Issued', value: cert.issuedDate),
              const SizedBox(width: 24),
              _CertMeta(
                label: 'Expires',
                value: cert.expiryDate,
                valueColor: cert.status == 'Expired'
                    ? TradeColors.red
                    : cert.status == 'Expiring'
                        ? TradeColors.orange
                        : null,
              ),
              const Spacer(),
              if (cert.status == 'Expiring')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: TradeColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Renew Soon', style: TextStyle(fontSize: 11, color: TradeColors.orange, fontWeight: FontWeight.w700)),
                ),
              if (cert.status == 'Expired')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: TradeColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Renewal Required', style: TextStyle(fontSize: 11, color: TradeColors.red, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CertMeta extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CertMeta({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: TradeColors.muted)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor ?? TradeColors.dark)),
      ],
    );
  }
}

class _AuditEntry extends StatelessWidget {
  final AuditLogEntry entry;

  const _AuditEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    final actionColor = switch (entry.action.toLowerCase()) {
      'created' => TradeColors.blue,
      'confirmed' || 'delivered' => TradeColors.green,
      'rejected' || 'cancelled' => TradeColors.red,
      _ => TradeColors.muted,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: actionColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TradeBadge(label: entry.action, color: actionColor),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.entityType} ${entry.entityId}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: TradeColors.dark),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.performedBy} • ${entry.timestamp}',
                  style: const TextStyle(fontSize: 11, color: TradeColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
