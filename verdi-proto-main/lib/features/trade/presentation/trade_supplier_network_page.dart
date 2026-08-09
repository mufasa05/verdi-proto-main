import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trade_models.dart';
import '../providers/trade_providers.dart';
import '../widgets/trade_widgets.dart';

class TradeSupplierNetworkPage extends ConsumerStatefulWidget {
  const TradeSupplierNetworkPage({super.key});

  @override
  ConsumerState<TradeSupplierNetworkPage> createState() =>
      _TradeSupplierNetworkPageState();
}

class _TradeSupplierNetworkPageState
    extends ConsumerState<TradeSupplierNetworkPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  TradeSupplier? _selectedSupplier;

  final _categories = ['All', 'Grains', 'Vegetables', 'Fruits', 'Unverified'];
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TradeSupplier> _filtered(List<TradeSupplier> all) {
    return all.where((s) {
      final matchCat = _selectedCategory == 'All'
          ? true
          : _selectedCategory == 'Unverified'
              ? !s.isVerified
              : s.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.region.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.primaryProduct.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(tradeSupplierProvider);
    final filtered = _filtered(suppliers);

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;
      final supplierList = _SupplierList(
        suppliers: filtered,
        selectedId: _selectedSupplier?.id,
        onSelect: (s) => setState(() => _selectedSupplier = s),
        searchController: _searchController,
        categories: _categories,
        selectedCategory: _selectedCategory,
        onCategoryChanged: (c) => setState(() => _selectedCategory = c),
        onSearchChanged: (q) => setState(() => _searchQuery = q),
        onVerify: (id) => ref.read(tradeSupplierProvider.notifier).verifySupplier(id),
      );

      if (isWide && _selectedSupplier != null) {
        return Row(
          children: [
            Expanded(flex: 5, child: supplierList),
            const VerticalDivider(width: 1, color: TradeColors.border),
            Expanded(
              flex: 3,
              child: _SupplierDetailPanel(
                supplier: _selectedSupplier!,
                purchaseOrders: ref.watch(purchaseOrderProvider),
                onClose: () => setState(() => _selectedSupplier = null),
                onVerify: () => ref.read(tradeSupplierProvider.notifier).verifySupplier(_selectedSupplier!.id),
              ),
            ),
          ],
        );
      }
      return supplierList;
    });
  }
}

// =============================================================================
// SUPPLIER LIST
// =============================================================================

class _SupplierList extends StatelessWidget {
  final List<TradeSupplier> suppliers;
  final String? selectedId;
  final ValueChanged<TradeSupplier> onSelect;
  final TextEditingController searchController;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onVerify;

  const _SupplierList({
    required this.suppliers,
    required this.selectedId,
    required this.onSelect,
    required this.searchController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearchChanged,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TradePageHeader(
            title: 'Supplier Network',
            subtitle: 'Manage verified suppliers across the value chain.',
            actions: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Supplier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradeColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          // Search
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search suppliers, regions, products…',
              prefixIcon: const Icon(Icons.search, color: TradeColors.muted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: TradeColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: TradeColors.border),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TradeFilterRow(
            filters: categories,
            selected: selectedCategory,
            onSelect: onCategoryChanged,
          ),
          const SizedBox(height: 16),
          // Supplier cards
          if (suppliers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No suppliers match your filters.', style: TextStyle(color: TradeColors.muted)),
              ),
            )
          else
            for (final s in suppliers) ...[
              _SupplierCard(
                supplier: s,
                isSelected: s.id == selectedId,
                onTap: () => onSelect(s),
                onVerify: () => onVerify(s.id),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final TradeSupplier supplier;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onVerify;

  const _SupplierCard({
    required this.supplier,
    required this.isSelected,
    required this.onTap,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TradeColors.green.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? TradeColors.green : TradeColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            TrustScoreRing(score: supplier.trustScore),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          supplier.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: TradeColors.dark,
                          ),
                        ),
                      ),
                      if (supplier.isVerified)
                        const Icon(Icons.verified, color: TradeColors.blue, size: 18)
                      else
                        InkWell(
                          onTap: onVerify,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: TradeColors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Verify', style: TextStyle(fontSize: 11, color: TradeColors.orange, fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: TradeColors.muted),
                          const SizedBox(width: 4),
                          Text(supplier.region, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.category_outlined, size: 13, color: TradeColors.muted),
                          const SizedBox(width: 4),
                          Text(supplier.category, style: const TextStyle(fontSize: 12, color: TradeColors.muted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TradeProgressBar(
                    value: supplier.trustScore,
                    label: 'Trust Score',
                    trailingLabel: '${supplier.reliabilityPct.round()}%',
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

// =============================================================================
// SUPPLIER DETAIL PANEL
// =============================================================================

class _SupplierDetailPanel extends StatelessWidget {
  final TradeSupplier supplier;
  final List<PurchaseOrder> purchaseOrders;
  final VoidCallback onClose;
  final VoidCallback onVerify;

  const _SupplierDetailPanel({
    required this.supplier,
    required this.purchaseOrders,
    required this.onClose,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final supplierOrders = purchaseOrders.where((po) => po.supplierId == supplier.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  supplier.name,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: TradeColors.dark),
                ),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (supplier.isVerified) ...[
                const Icon(Icons.verified, color: TradeColors.blue, size: 16),
                const SizedBox(width: 4),
                const Text('Verified Supplier', style: TextStyle(color: TradeColors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
              ] else ...[
                const Icon(Icons.pending_outlined, color: TradeColors.orange, size: 16),
                const SizedBox(width: 4),
                const Text('Pending Verification', style: TextStyle(color: TradeColors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          const SizedBox(height: 16),
          TradeSectionCard(
            title: 'Contact',
            child: Column(
              children: [
                MetricRow(label: 'Name', value: supplier.contactName),
                MetricRow(label: 'Phone', value: supplier.contactPhone),
                MetricRow(label: 'Region', value: supplier.region),
                MetricRow(label: 'Primary Product', value: supplier.primaryProduct),
                MetricRow(label: 'Category', value: supplier.category),
                MetricRow(label: 'Onboarded', value: supplier.onboardedDate),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TradeSectionCard(
            title: 'Performance',
            child: Column(
              children: [
                TradeProgressBar(
                  value: supplier.trustScore,
                  label: 'Trust Score',
                  trailingLabel: '${supplier.reliabilityPct.round()}%',
                ),
                const SizedBox(height: 12),
                MetricRow(label: 'Orders Fulfilled', value: '${supplier.totalOrdersFulfilled}'),
                MetricRow(label: 'Capacity', value: '${supplier.capacityTonnes.round()} tonnes'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TradeSectionCard(
            title: 'Purchase Orders',
            child: supplierOrders.isEmpty
                ? const Text('No orders yet.', style: TextStyle(color: TradeColors.muted))
                : Column(
                    children: supplierOrders
                        .map((po) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${po.id} • ${po.productName}',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                        Text('${po.quantityKg.round()}kg • ${po.date}',
                                            style: const TextStyle(fontSize: 11, color: TradeColors.muted)),
                                      ],
                                    ),
                                  ),
                                  TradeBadge(label: po.status),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          if (!supplier.isVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onVerify,
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: const Text('Verify Supplier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TradeColors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
