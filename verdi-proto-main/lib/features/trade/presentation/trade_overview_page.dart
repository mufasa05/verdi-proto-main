import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeOverviewPage extends ConsumerWidget {
  const TradeOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(tradeSupplierProvider);
    final purchaseOrders = ref.watch(purchaseOrderProvider);
    final batches = ref.watch(stockBatchProvider);
    final salesOrders = ref.watch(salesOrderProvider);
    final alerts = ref.watch(openAlertsProvider);
    final prices = ref.watch(pricePointProvider);
    final auditLog = ref.watch(auditLogProvider);

    final verifiedSuppliers = suppliers.where((s) => s.isVerified).length;
    final openPOs = purchaseOrders.where((p) => p.status == 'Sent' || p.status == 'Confirmed').length;
    final stockAlerts = batches.where((b) => b.quantityKg < 2000).length;
    final revenueMtd = salesOrders
        .where((so) => so.status != 'Cancelled')
        .fold<double>(0, (sum, so) => sum + so.totalValue);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TradePageHeader(
            title: 'Hub Overview',
            subtitle: 'Live snapshot of trade activity across the value chain.',
          ),

          // Alert Banners
          if (alerts.isNotEmpty) ...[
            for (final alert in alerts.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TradeAlertBanner(
                  message: alert.message,
                  severity: alert.severity,
                  onDismiss: () => ref.read(tradeAlertProvider.notifier).dismiss(alert.id),
                ),
              ),
            const SizedBox(height: 6),
          ],

          // KPI Stats Grid (Fully Clickable)
          LayoutBuilder(builder: (context, constraints) {
            final tiles = [
              InkWell(
                onTap: () => ref.read(selectedTradeTabProvider.notifier).state = 1, // Suppliers
                borderRadius: BorderRadius.circular(12),
                child: TradeStatTile(
                  label: 'Verified Suppliers',
                  value: '$verifiedSuppliers',
                  icon: Icons.verified_outlined,
                  trendPercent: 8.3,
                ),
              ),
              InkWell(
                onTap: () => ref.read(selectedTradeTabProvider.notifier).state = 2, // Procurement
                borderRadius: BorderRadius.circular(12),
                child: TradeStatTile(
                  label: 'Open Purchase Orders',
                  value: '$openPOs',
                  icon: Icons.receipt_long_outlined,
                  iconColor: TradeColors.blue,
                ),
              ),
              InkWell(
                onTap: () => ref.read(selectedTradeTabProvider.notifier).state = 3, // Inventory
                borderRadius: BorderRadius.circular(12),
                child: TradeStatTile(
                  label: 'Stock Alerts',
                  value: '$stockAlerts',
                  icon: Icons.inventory_2_outlined,
                  iconColor: stockAlerts > 0 ? TradeColors.orange : TradeColors.green,
                  valueColor: stockAlerts > 0 ? TradeColors.orange : null,
                ),
              ),
              InkWell(
                onTap: () => ref.read(selectedTradeTabProvider.notifier).state = 6, // Sales
                borderRadius: BorderRadius.circular(12),
                child: TradeStatTile(
                  label: 'Revenue MTD',
                  value: 'US\$ ${(revenueMtd / 1000).toStringAsFixed(1)}k',
                  icon: Icons.trending_up_outlined,
                  trendPercent: 12.6,
                ),
              ),
            ];
            if (constraints.maxWidth >= 900) {
              return Row(
                children: tiles.map((t) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: t))).toList(),
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: tiles[0]),
                    const SizedBox(width: 12),
                    Expanded(child: tiles[1]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: tiles[2]),
                    const SizedBox(width: 12),
                    Expanded(child: tiles[3]),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 16),

          // Quick Actions Suite
          TradeSectionCard(
            title: 'Quick Actions',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickAction(
                  icon: Icons.add_shopping_cart_outlined,
                  label: 'New Purchase Order',
                  color: TradeColors.blue,
                  onTap: () => _showNewPOModal(context, ref, suppliers),
                ),
                _QuickAction(
                  icon: Icons.inventory_outlined,
                  label: 'Log Intake',
                  color: TradeColors.green,
                  onTap: () => _showLogIntakeModal(context, ref, suppliers),
                ),
                _QuickAction(
                  icon: Icons.local_shipping_outlined,
                  label: 'Dispatch Stock',
                  color: TradeColors.purple,
                  onTap: () => _showDispatchModal(context, ref, batches),
                ),
                _QuickAction(
                  icon: Icons.fact_check_outlined,
                  label: 'Record QC',
                  color: TradeColors.orange,
                  onTap: () => _showRecordQcModal(context, ref, batches),
                ),
                _QuickAction(
                  icon: Icons.point_of_sale_outlined,
                  label: 'Create Sale',
                  color: TradeColors.amber,
                  onTap: () => _showCreateSaleModal(context, ref),
                ),
                _QuickAction(
                  icon: Icons.handshake_outlined,
                  label: 'Add Supplier',
                  color: TradeColors.muted,
                  onTap: () => _showAddSupplierModal(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Price Board + Audit Log
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final priceBoard = TradeSectionCard(
              title: 'Live Price Board',
              trailing: const TradeBadge(label: 'Harare • Today', color: TradeColors.green),
              child: Column(
                children: prices.map((p) {
                  final isUp = p.changePercent >= 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: TradeColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.productName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        Text(
                          'US\$ ${p.pricePer100kg.toStringAsFixed(2)}/100kg',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: TradeColors.dark),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isUp ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: isUp ? TradeColors.green : TradeColors.red,
                        ),
                        Text(
                          '${p.changePercent.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isUp ? TradeColors.green : TradeColors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );

            final recentActivity = TradeSectionCard(
              title: 'Recent Activity',
              child: Column(
                children: auditLog.take(6).map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: TradeColors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.history, size: 16, color: TradeColors.green),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.action} ${entry.entityType} ${entry.entityId}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TradeColors.dark),
                              ),
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
                }).toList(),
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: priceBoard),
                  const SizedBox(width: 16),
                  Expanded(child: recentActivity),
                ],
              );
            }
            return Column(
              children: [
                priceBoard,
                const SizedBox(height: 16),
                recentActivity,
              ],
            );
          }),
        ],
      ),
    );
  }

  // --- MODAL DIALOGS FOR QUICK ACTIONS ---

  void _showNewPOModal(BuildContext context, WidgetRef ref, List<TradeSupplier> suppliers) {
    String selectedSupplierId = suppliers.isNotEmpty ? suppliers.first.id : 'SUP-01';
    final productCtrl = TextEditingController(text: 'White Maize');
    final qtyCtrl = TextEditingController(text: '10000');
    final priceCtrl = TextEditingController(text: '45.00');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Purchase Order', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSupplierId,
              decoration: const InputDecoration(labelText: 'Supplier'),
              items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) { if (v != null) selectedSupplierId = v; },
            ),
            TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity (Kg)')),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Unit Price / 100kg (US\$)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newPo = PurchaseOrder(
                id: 'PO-${3000 + DateTime.now().millisecond}',
                supplierId: selectedSupplierId,
                productName: productCtrl.text,
                quantityKg: double.tryParse(qtyCtrl.text) ?? 5000,
                unitPricePer100kg: double.tryParse(priceCtrl.text) ?? 40.0,
                status: 'Sent',
                date: '2026-07-24',
                deliveryDate: '2026-08-01',
                warehouseId: 'WH-01',
              );
              ref.read(purchaseOrderProvider.notifier).addOrder(newPo);
              ref.read(auditLogProvider.notifier).addEntry(AuditLogEntry(
                id: 'LOG-${DateTime.now().millisecond}',
                action: 'Created',
                entityType: 'PurchaseOrder',
                entityId: newPo.id,
                performedBy: 'Procurement Desk',
                timestamp: 'Just now',
              ));
              Navigator.pop(context);
              ref.read(selectedTradeTabProvider.notifier).state = 2; // Route to Procurement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Created ${newPo.id} for ${newPo.productName}'), backgroundColor: TradeColors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: TradeColors.green, foregroundColor: Colors.white),
            child: const Text('Create PO'),
          ),
        ],
      ),
    );
  }

  void _showLogIntakeModal(BuildContext context, WidgetRef ref, List<TradeSupplier> suppliers) {
    String selectedSupplierId = suppliers.isNotEmpty ? suppliers.first.id : 'SUP-01';
    final productCtrl = TextEditingController(text: 'Potatoes');
    final qtyCtrl = TextEditingController(text: '5000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Stock Intake Batch', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSupplierId,
              decoration: const InputDecoration(labelText: 'Supplier Source'),
              items: suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) { if (v != null) selectedSupplierId = v; },
            ),
            TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Intake Quantity (Kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newBatch = StockBatch(
                id: 'BAT-${100 + DateTime.now().millisecond}',
                productName: productCtrl.text,
                supplierId: selectedSupplierId,
                warehouseId: 'WH-01',
                binLabel: 'A-04',
                quantityKg: double.tryParse(qtyCtrl.text) ?? 5000,
                gradeClass: GradeClass.a,
                lotNumber: 'LOT-NEW-${DateTime.now().second}',
                arrivalDate: '2026-07-24',
                expiryDate: '2026-11-24',
                status: 'In Stock',
              );
              ref.read(stockBatchProvider.notifier).addBatch(newBatch);
              ref.read(auditLogProvider.notifier).addEntry(AuditLogEntry(
                id: 'LOG-${DateTime.now().millisecond}',
                action: 'Log Intake',
                entityType: 'StockBatch',
                entityId: newBatch.id,
                performedBy: 'Depot Operations',
                timestamp: 'Just now',
              ));
              Navigator.pop(context);
              ref.read(selectedTradeTabProvider.notifier).state = 3; // Route to Inventory
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logged Stock Intake ${newBatch.id}'), backgroundColor: TradeColors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: TradeColors.green, foregroundColor: Colors.white),
            child: const Text('Confirm Intake'),
          ),
        ],
      ),
    );
  }

  void _showDispatchModal(BuildContext context, WidgetRef ref, List<StockBatch> batches) {
    String selectedBatchId = batches.isNotEmpty ? batches.first.id : 'BAT-001';
    final destinationCtrl = TextEditingController(text: 'Harare Fresh Produce Hub');
    final driverCtrl = TextEditingController(text: 'Takudzwa Transport #4');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dispatch Stock Shipment', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedBatchId,
              decoration: const InputDecoration(labelText: 'Select Stock Batch'),
              items: batches.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.productName} (${b.id})'))).toList(),
              onChanged: (v) { if (v != null) selectedBatchId = v; },
            ),
            TextField(controller: destinationCtrl, decoration: const InputDecoration(labelText: 'Destination')),
            TextField(controller: driverCtrl, decoration: const InputDecoration(labelText: 'Transporter / Driver')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newTrip = LogisticsTrip(
                id: 'TRIP-${100 + DateTime.now().millisecond}',
                salesOrderId: 'SO-5001',
                driverName: driverCtrl.text,
                vehiclePlate: 'AEZ-8891',
                originWarehouse: 'WH-01 Harare Depot',
                destinationName: destinationCtrl.text,
                destinationLat: -17.8292,
                destinationLng: 31.0522,
                originLat: -17.8638,
                originLng: 31.0285,
                status: 'En Route',
                departureDate: '2026-07-24 08:00',
                eta: '2026-07-24 14:00',
                loadKg: 5000,
                hasProofOfDelivery: false,
              );
              ref.read(logisticsTripProvider.notifier).addTrip(newTrip);
              ref.read(auditLogProvider.notifier).addEntry(AuditLogEntry(
                id: 'LOG-${DateTime.now().millisecond}',
                action: 'Dispatched',
                entityType: 'LogisticsTrip',
                entityId: newTrip.id,
                performedBy: 'Logistics Officer',
                timestamp: 'Just now',
              ));
              Navigator.pop(context);
              ref.read(selectedTradeTabProvider.notifier).state = 7; // Route to Logistics
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dispatched Logistics Trip ${newTrip.id}'), backgroundColor: TradeColors.purple),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: TradeColors.purple, foregroundColor: Colors.white),
            child: const Text('Dispatch Shipment'),
          ),
        ],
      ),
    );
  }

  void _showRecordQcModal(BuildContext context, WidgetRef ref, List<StockBatch> batches) {
    String selectedBatchId = batches.isNotEmpty ? batches.first.id : 'BAT-001';
    final moistureCtrl = TextEditingController(text: '12.5');
    final weightCtrl = TextEditingController(text: '500');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Quality Control Inspection', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedBatchId,
              decoration: const InputDecoration(labelText: 'Select Batch'),
              items: batches.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.productName} (${b.id})'))).toList(),
              onChanged: (v) { if (v != null) selectedBatchId = v; },
            ),
            TextField(controller: moistureCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Moisture %')),
            TextField(controller: weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight Checked (Kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newQc = QualityCheck(
                id: 'QC-${100 + DateTime.now().millisecond}',
                batchId: selectedBatchId,
                productName: 'White Maize',
                inspector: 'Dr. K. Shumba',
                assignedGrade: GradeClass.a,
                passed: true,
                moisturePercent: double.tryParse(moistureCtrl.text) ?? 12.0,
                weightCheckedKg: double.tryParse(weightCtrl.text) ?? 500.0,
                notes: 'Inspection passed SAZ standard.',
                date: '2026-07-24',
              );
              ref.read(qualityCheckProvider.notifier).addCheck(newQc);
              ref.read(auditLogProvider.notifier).addEntry(AuditLogEntry(
                id: 'LOG-${DateTime.now().millisecond}',
                action: 'Recorded QC',
                entityType: 'QualityCheck',
                entityId: newQc.id,
                performedBy: 'Quality Inspector',
                timestamp: 'Just now',
              ));
              Navigator.pop(context);
              ref.read(selectedTradeTabProvider.notifier).state = 4; // Route to Quality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recorded QC Inspection ${newQc.id}'), backgroundColor: TradeColors.orange),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: TradeColors.orange, foregroundColor: Colors.white),
            child: const Text('Record QC'),
          ),
        ],
      ),
    );
  }

  void _showCreateSaleModal(BuildContext context, WidgetRef ref) {
    final buyerCtrl = TextEditingController(text: 'Mbare Fresh Wholesale Market');
    final productCtrl = TextEditingController(text: 'White Maize');
    final qtyCtrl = TextEditingController(text: '15000');
    final priceCtrl = TextEditingController(text: '48.00');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Sales Order', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: buyerCtrl, decoration: const InputDecoration(labelText: 'Buyer Name')),
            TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity (Kg)')),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price / 100kg (US\$)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyCtrl.text) ?? 10000;
              final price = double.tryParse(priceCtrl.text) ?? 48.0;
              final newSale = SalesOrder(
                id: 'SO-${5000 + DateTime.now().millisecond}',
                buyerName: buyerCtrl.text,
                buyerRegion: 'Harare',
                lines: [
                  SalesOrderLine(
                    productName: productCtrl.text,
                    quantityKg: qty,
                    unitPricePer100kg: price,
                  ),
                ],
                status: 'Confirmed',
                paymentStatus: 'Unpaid',
                orderDate: '2026-07-24',
                invoiceId: 'INV-${DateTime.now().millisecond}',
              );
              ref.read(salesOrderProvider.notifier).addOrder(newSale);
              ref.read(auditLogProvider.notifier).addEntry(AuditLogEntry(
                id: 'LOG-${DateTime.now().millisecond}',
                action: 'Created',
                entityType: 'SalesOrder',
                entityId: newSale.id,
                performedBy: 'Commercial Sales Desk',
                timestamp: 'Just now',
              ));
              Navigator.pop(context);
              ref.read(selectedTradeTabProvider.notifier).state = 6; // Route to Sales
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Created Sales Order ${newSale.id}'), backgroundColor: TradeColors.amber),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: TradeColors.amber, foregroundColor: Colors.white),
            child: const Text('Create Sale'),
          ),
        ],
      ),
    );
  }

  void _showAddSupplierModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final regionCtrl = TextEditingController(text: 'Mashonaland West');
    final productCtrl = TextEditingController(text: 'White Maize');
    final contactCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register New Supplier', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Supplier Enterprise Name')),
            TextField(controller: regionCtrl, decoration: const InputDecoration(labelText: 'Province / Region')),
            TextField(controller: productCtrl, decoration: const InputDecoration(labelText: 'Primary Product')),
            TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: 'Contact Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newSupplier = TradeSupplier(
                  id: 'SUP-0${DateTime.now().second}',
                  name: nameCtrl.text,
                  region: regionCtrl.text,
                  category: 'Grains',
                  trustScore: 0.90,
                  capacityTonnes: 350,
                  isVerified: true,
                  contactName: 'Manager',
                  contactPhone: contactCtrl.text.isNotEmpty ? contactCtrl.text : '+263 77 100 2000',
                  primaryProduct: productCtrl.text,
                  totalOrdersFulfilled: 1,
                  onboardedDate: '2026-07-24',
                );
                ref.read(tradeSupplierProvider.notifier).addSupplier(newSupplier);
                ref.read(auditLogProvider.notifier).addEntry(AuditLogEntry(
                  id: 'LOG-${DateTime.now().millisecond}',
                  action: 'Registered',
                  entityType: 'TradeSupplier',
                  entityId: newSupplier.id,
                  performedBy: 'Supplier Desk',
                  timestamp: 'Just now',
                ));
                Navigator.pop(context);
                ref.read(selectedTradeTabProvider.notifier).state = 1; // Route to Suppliers
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registered Supplier ${newSupplier.name}'), backgroundColor: TradeColors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: TradeColors.green, foregroundColor: Colors.white),
            child: const Text('Register Supplier'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
