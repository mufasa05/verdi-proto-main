import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../auth/presentation/widgets/buyer_sub_role_dialog.dart';
import '../data/b2b_buyer_models.dart';

/// Full-Featured Commercial B2B Buyer (Retailer / Wholesaler) Command Hub
class B2bBuyerDashboardPage extends ConsumerStatefulWidget {
  const B2bBuyerDashboardPage({super.key});

  @override
  ConsumerState<B2bBuyerDashboardPage> createState() => _B2bBuyerDashboardPageState();
}

class _B2bBuyerDashboardPageState extends ConsumerState<B2bBuyerDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const bgDark = Color(0xFF070B12);
  static const cardDark = Color(0xFF0F172A);
  static const cardBorder = Color(0xFF1E293B);
  static const accentGreen = Color(0xFF10B981);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const accentDanger = Color(0xFFEF4444);
  static const textMuted = Color(0xFF94A3B8);

  // Spot Bulk Catalog
  final List<B2bBulkListingItem> _bulkListings = [
    B2bBulkListingItem(id: 'BLK-901', cropName: 'Grade A White Maize (Grain)', grade: 'Export Grade 1', availableTons: 250, minOrderTons: 30, pricePerTonUsd: 275.0, location: 'Mazowe Silos, Mashonaland Central', cooperative: 'Mazowe Grain Producers Union', packaging: 'Bulk Tipper / 50kg Bags', moisturePercent: 12.2, eudrCompliant: true, phytoCertified: true, harvestDate: 'August 2026 Harvest'),
    B2bBulkListingItem(id: 'BLK-902', cropName: 'Commercial Soya Beans', grade: 'High Protein Oilseed', availableTons: 140, minOrderTons: 20, pricePerTonUsd: 480.0, location: 'Banket Grain Hub, Mashonaland West', cooperative: 'Zvimba Agribusiness Cluster', packaging: 'Bulk Tipper', moisturePercent: 11.5, eudrCompliant: true, phytoCertified: true, harvestDate: 'Recent Dry Season Batch'),
    B2bBulkListingItem(id: 'BLK-903', cropName: 'Sugar Beans (Red Speckled)', grade: 'Premium Food Grade', availableTons: 85, minOrderTons: 10, pricePerTonUsd: 920.0, location: 'Chinhoyi Central Depot', cooperative: 'Makonde Bean Outgrowers', packaging: '50kg Poly Bags', moisturePercent: 10.8, eudrCompliant: true, phytoCertified: true, harvestDate: 'July 2026 Batch'),
    B2bBulkListingItem(id: 'BLK-904', cropName: 'Hass Avocados (Cold-Chain)', grade: 'Export Class 1', availableTons: 60, minOrderTons: 5, pricePerTonUsd: 1450.0, location: 'Chipinge Highland Orchards', cooperative: 'Eastern Highlands Fruit Pool', packaging: '4kg Cold Export Cartons', moisturePercent: 78.0, eudrCompliant: true, phytoCertified: true, harvestDate: 'Tree-Harvested 48h ago'),
    B2bBulkListingItem(id: 'BLK-905', cropName: 'Virginia Flue-Cured Tobacco', grade: 'Leaf Grade B1F', availableTons: 40, minOrderTons: 5, pricePerTonUsd: 3200.0, location: 'Karoi Auction Floors', cooperative: 'Hurungwe Growers Association', packaging: '100kg Wrapped Bales', moisturePercent: 14.0, eudrCompliant: true, phytoCertified: true, harvestDate: 'Cured & Graded'),
  ];

  // Reverse RFQ Tenders
  final List<B2bRfqTenderItem> _rfqTenders = [
    B2bRfqTenderItem(
      id: 'TND-881',
      title: 'Procurement Tender: 300 MT Non-GMO Soybeans for Harare Oil Mill',
      cropType: 'Soya Beans',
      requiredTons: 300,
      targetPricePerTonUsd: 475.0,
      deliveryLocation: 'Harare Industrial Sites Oil Plant',
      deadlineDate: '15 September 2026',
      status: 'Active Bidding',
      bids: [
        B2bTenderBid(bidderId: 'BID-01', supplierName: 'Mazowe Farmers Cooperative', offeredTons: 150, bidPricePerTonUsd: 470.0, deliveryDate: '10 Sept 2026', moistureGrade: 11.2, status: 'Accepted'),
        B2bTenderBid(bidderId: 'BID-02', supplierName: 'Bindura Agritech Aggregators', offeredTons: 150, bidPricePerTonUsd: 475.0, deliveryDate: '12 Sept 2026', moistureGrade: 11.8, status: 'Pending'),
        B2bTenderBid(bidderId: 'BID-03', supplierName: 'Midlands Grain Traders', offeredTons: 100, bidPricePerTonUsd: 490.0, deliveryDate: '18 Sept 2026', moistureGrade: 12.5, status: 'Pending'),
      ],
    ),
    B2bRfqTenderItem(
      id: 'TND-882',
      title: 'Forward Supply: 100 MT Export Grade Hass Avocados for UK Shipment',
      cropType: 'Avocados',
      requiredTons: 100,
      targetPricePerTonUsd: 1400.0,
      deliveryLocation: 'Beira Cold Port Facility / Harare Airport',
      deadlineDate: '28 August 2026',
      status: 'Active Bidding',
      bids: [
        B2bTenderBid(bidderId: 'BID-11', supplierName: 'Chipinge Avocado Growers Pool', offeredTons: 80, bidPricePerTonUsd: 1380.0, deliveryDate: '26 Aug 2026', moistureGrade: 78.5, status: 'Pending'),
      ],
    ),
  ];

  // Forward Contracts
  final List<B2bForwardContractItem> _forwardContracts = [
    B2bForwardContractItem(id: 'CTR-2026-001', contractNumber: 'VERDI-B2B-CTR-8819', supplierName: 'Mazowe Grain Producers Union', cropType: 'White Maize (Grade A)', totalTons: 500, agreedPricePerTonUsd: 270.0, totalValueUsd: 135000.0, startDate: '15 June 2026', expectedHarvestDate: '25 August 2026', deliveryWindow: '25–30 August 2026', status: 'In Transit', tranche1Paid: true, tranche2Paid: true, tranche3Paid: false),
    B2bForwardContractItem(id: 'CTR-2026-002', contractNumber: 'VERDI-B2B-CTR-7721', supplierName: 'Eastern Highlands Fruit Pool', cropType: 'Export Hass Avocados', totalTons: 80, agreedPricePerTonUsd: 1380.0, totalValueUsd: 110400.0, startDate: '01 July 2026', expectedHarvestDate: '05 September 2026', deliveryWindow: '05–10 September 2026', status: 'Active', tranche1Paid: true, tranche2Paid: false, tranche3Paid: false),
    B2bForwardContractItem(id: 'CTR-2026-003', contractNumber: 'VERDI-B2B-CTR-6610', supplierName: 'Makonde Bean Outgrowers', cropType: 'Red Speckled Sugar Beans', totalTons: 120, agreedPricePerTonUsd: 910.0, totalValueUsd: 109200.0, startDate: '10 May 2026', expectedHarvestDate: '15 July 2026', deliveryWindow: 'Delivered', status: 'Completed', tranche1Paid: true, tranche2Paid: true, tranche3Paid: true),
  ];

  // Reefer Fleet Telemetry
  final List<B2bReeferFreightItem> _reeferFreight = [
    B2bReeferFreightItem(id: 'LOG-771', tripRef: 'DISPATCH-HARARE-01', carrierName: 'Verdi Cold-Chain Fleet', truckType: '30T Refrigerated Reefer', regNumber: 'AFE-8819 / T-99', origin: 'Chipinge Cold Hub', destination: 'Harare Export Hub', currentTempC: 3.2, targetTempRange: '+2°C to +4°C', slaCompliance: true, eBolNumber: 'EBOL-ZIM-2026-881', eta: '3 hours 15 mins (Beatrice Tollgate)'),
    B2bReeferFreightItem(id: 'LOG-772', tripRef: 'DISPATCH-BULK-02', carrierName: 'Zambezi Bulk Hauliers', truckType: '34T Side-Tipper Interlink', regNumber: 'AEL-4402 / T-12', origin: 'Mazowe Grain Silo', destination: 'Bulawayo Malaleni Mill', currentTempC: 22.0, targetTempRange: 'Ambient Dry Grain', slaCompliance: true, eBolNumber: 'EBOL-ZIM-2026-904', eta: '5 hours 40 mins (Kwekwe Bypass)'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Executive Sourcing Header & Profile Switcher
              _buildExecutiveHeader(state),

              const SizedBox(height: 16),

              // 2. Commercial KPI Metric Strip
              _buildMetricKpiStrip(state),

              const SizedBox(height: 20),

              // 3. Navigation TabBar
              Container(
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cardBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: accentGreen,
                  indicatorWeight: 3,
                  labelColor: accentGreen,
                  unselectedLabelColor: textMuted,
                  tabs: const [
                    Tab(text: '📦 Bulk Lot Sourcing'),
                    Tab(text: '📋 Reverse RFQ Tenders'),
                    Tab(text: '📜 Forward Contracts'),
                    Tab(text: '🛡️ 3-Stage Escrow Vault'),
                    Tab(text: '🚚 Fleet & Cold-Chain IoT'),
                    Tab(text: '📈 SADC Price Terminal'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Tab Views
              SizedBox(
                height: 1200,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBulkLotSourcingTab(state),
                    _buildReverseRfqTendersTab(state),
                    _buildForwardContractsTab(state),
                    _buildEscrowVaultTab(state),
                    _buildFleetColdChainTab(state),
                    _buildSadcPriceTerminalTab(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveHeader(AppState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, color: accentBlue, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Commercial Sourcing & Wholesale Hub',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: accentGreen.withOpacity(0.5)),
                        ),
                        child: const Text('VERIFIED B2B ENTERPRISE', style: TextStyle(color: accentGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Multi-ton spot lots, outgrower forward contracts, multi-stage escrow & 34T haulage telemetry.',
                    style: TextStyle(color: textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final chosen = await BuyerSubRoleDialog.show(context, current: state.buyerSubRole);
              if (chosen != null) {
                ref.read(appStateProvider.notifier).setBuyerSubRole(chosen);
              }
            },
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: const Text('Switch to End-User Store', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricKpiStrip(AppState state) {
    return Row(
      children: [
        Expanded(child: _buildKpiCard('Contracted Volume', '1,480 MT', '+240 MT this month', accentGreen, Icons.inventory_2_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Active Escrow Locked', '\$412,500 USD', '3-Stage Tranche Vault', accentBlue, Icons.shield_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Active RFQ Tenders', '2 Live Tenders', '5 Supplier Bids Pending', accentGold, Icons.gavel_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard('Avg Landed Savings', '14.2% vs Spot', 'Direct Farmgate Arbitrage', const Color(0xFF8B5CF6), Icons.trending_down)),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, String subtext, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: textMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtext, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: BULK LOT SOURCING & MULTI-TON CATALOG
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBulkLotSourcingTab(AppState state) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Verified Multi-Ton Harvest Lots Ready for Dispatch', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: accentGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Text('100% EUDR & PHYTO COMPLIANT', style: TextStyle(color: accentGreen, fontSize: 10.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._bulkListings.map((item) => _buildBulkLotCard(item, state)),
      ],
    );
  }

  Widget _buildBulkLotCard(B2bBulkListingItem item, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.cropName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: accentBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                          child: Text(item.grade, style: const TextStyle(color: accentBlue, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('📍 ${item.location} • Supplier: ${item.cooperative}', style: const TextStyle(color: textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(state.currency.format(item.pricePerTonUsd), style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: accentGreen)),
                  const Text('per Metric Ton (MT)', style: TextStyle(color: textMuted, fontSize: 10.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Specs Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildSpecChip('Available: ${item.availableTons} MT', Icons.scale, accentGreen),
              _buildSpecChip('Min Order: ${item.minOrderTons} MT', Icons.shopping_bag_outlined, accentBlue),
              _buildSpecChip('Moisture: ${item.moisturePercent}%', Icons.water_drop_outlined, accentGold),
              _buildSpecChip('Packing: ${item.packaging}', Icons.inventory_2_outlined, textMuted),
              _buildSpecChip('EUDR Verified', Icons.verified, accentGreen),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: cardBorder, height: 1),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Harvest Date: ${item.harvestDate}', style: const TextStyle(color: textMuted, fontSize: 11.5)),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading EUDR Phytosanitary Lab Certificate for ${item.id}...'), backgroundColor: accentBlue),
                      );
                    },
                    icon: const Icon(Icons.file_download_outlined, size: 14),
                    label: const Text('Lab Certificate', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: cardBorder)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Initialized Escrow Vault Contract for ${item.availableTons} MT of ${item.cropName}.'), backgroundColor: accentGreen),
                      );
                    },
                    icon: const Icon(Icons.lock, size: 14),
                    label: const Text('Lock Escrow Contract', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: REVERSE RFQ & PROCUREMENT TENDERS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildReverseRfqTendersTab(AppState state) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reverse RFQ Bidding Tenders (Broadcasted to Outgrowers)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              onPressed: () => _showCreateTenderModal(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Publish New RFQ Tender', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 14),

        ..._rfqTenders.map((tender) => _buildTenderCard(tender, state)),
      ],
    );
  }

  Widget _buildTenderCard(B2bRfqTenderItem tender, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(tender.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: accentGold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(tender.status, style: const TextStyle(color: accentGold, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('🎯 Demand: ${tender.requiredTons} MT ${tender.cropType} • Target: ${state.currency.format(tender.targetPricePerTonUsd)}/MT • Delivery: ${tender.deliveryLocation}', style: const TextStyle(color: textMuted, fontSize: 12)),
          const SizedBox(height: 14),

          // Submitted Outgrower Bids Table
          Text('Submitted Outgrower / Cooperative Bids (${tender.bids.length})', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(color: const Color(0xFF070B12), borderRadius: BorderRadius.circular(10), border: Border.all(color: cardBorder)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tender.bids.length,
              separatorBuilder: (_, __) => const Divider(color: cardBorder, height: 1),
              itemBuilder: (context, idx) {
                final bid = tender.bids[idx];
                final isAccepted = bid.status == 'Accepted';
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: isAccepted ? accentGreen.withOpacity(0.2) : const Color(0xFF1E293B),
                    child: Icon(isAccepted ? Icons.check : Icons.person, color: isAccepted ? accentGreen : textMuted, size: 14),
                  ),
                  title: Text(bid.supplierName, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                  subtitle: Text('Offered: ${bid.offeredTons} MT @ ${state.currency.format(bid.bidPricePerTonUsd)}/MT • Moisture: ${bid.moistureGrade}% • Est. Delivery: ${bid.deliveryDate}', style: const TextStyle(color: textMuted, fontSize: 11)),
                  trailing: isAccepted
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: accentGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                          child: const Text('AWARDED', style: TextStyle(color: accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _rfqTenders.firstWhere((t) => t.id == tender.id);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Accepted bid from ${bid.supplierName}. Contract created in Forward Vault.'), backgroundColor: accentGreen),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                          child: const Text('Accept Bid', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: FORWARD SUPPLY CONTRACTS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildForwardContractsTab(AppState state) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text('Active Forward Supply Contracts & Outgrower Commitments', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),

        ..._forwardContracts.map((ctr) => _buildContractCard(ctr, state)),
      ],
    );
  }

  Widget _buildContractCard(B2bForwardContractItem ctr, AppState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ctr.contractNumber, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  Text('${ctr.cropType} • Supplier: ${ctr.supplierName}', style: const TextStyle(color: textMuted, fontSize: 12)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(state.currency.format(ctr.totalValueUsd), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: accentGreen)),
                  Text('${ctr.totalTons} MT @ ${state.currency.format(ctr.agreedPricePerTonUsd)}/MT', style: const TextStyle(color: textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tranche Status Steps
          Row(
            children: [
              _buildTrancheStepBadge('Tranche 1 (20% Advance)', ctr.tranche1Paid),
              const Icon(Icons.chevron_right, color: cardBorder, size: 18),
              _buildTrancheStepBadge('Tranche 2 (40% Farm Load)', ctr.tranche2Paid),
              const Icon(Icons.chevron_right, color: cardBorder, size: 18),
              _buildTrancheStepBadge('Tranche 3 (40% Weighbridge)', ctr.tranche3Paid),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Window: ${ctr.deliveryWindow}', style: const TextStyle(color: textMuted, fontSize: 11.5)),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing digital contract terms for ${ctr.contractNumber}...'), backgroundColor: accentBlue),
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 14),
                label: const Text('View Legal Agreement', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: cardBorder)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrancheStepBadge(String label, bool isPaid) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isPaid ? accentGreen.withOpacity(0.12) : const Color(0xFF070B12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isPaid ? accentGreen : cardBorder),
        ),
        child: Column(
          children: [
            Icon(isPaid ? Icons.check_circle : Icons.radio_button_unchecked, color: isPaid ? accentGreen : textMuted, size: 14),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: isPaid ? Colors.white : textMuted, fontSize: 9.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: 3-STAGE ESCROW VAULT
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildEscrowVaultTab(AppState state) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentBlue.withOpacity(0.4))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Corporate 3-Stage Escrow Protocol', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: accentGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                    child: const Text('BANK NOSTRO CLEARING ACTIVE', style: TextStyle(color: accentGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Funds are safeguarded in Reserve Bank / EcoCash Enterprise multi-sig vaults and only disbursed upon programmatic proof-of-performance.',
                style: TextStyle(color: textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // 3 Tranches Explainer Cards
              Row(
                children: [
                  Expanded(child: _buildTrancheCard('Tranche 1 (20%)', 'Advance Mobilization', 'Released on Contract Signature', accentBlue)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTrancheCard('Tranche 2 (40%)', 'Loading & EUDR Inspection', 'Released on Phyto/EUDR Pass', accentGold)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTrancheCard('Tranche 3 (40%)', 'Weighbridge & Lab Clearance', 'Released on Final Destination Lab Accept', accentGreen)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text('Active Escrow Tranche Disbursal Ledger', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),

        ..._forwardContracts.map((ctr) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ctr.contractNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('${ctr.cropType} • Total Vault: ${state.currency.format(ctr.totalValueUsd)}', style: const TextStyle(color: textMuted, fontSize: 11.5)),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Disbursing Tranche 2 for ${ctr.contractNumber}...'), backgroundColor: accentGreen),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                    child: const Text('Authorize Tranche 2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Escrow Vault Frozen for dispute mediation: ${ctr.contractNumber}'), backgroundColor: accentDanger),
                      );
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: accentDanger, side: const BorderSide(color: accentDanger), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                    child: const Text('Dispute & Freeze', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTrancheCard(String title, String subtitle, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF070B12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: textMuted, fontSize: 9.5)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 5: FLEET & REEFER COLD-CHAIN TELEMETRY
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildFleetColdChainTab(AppState state) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text('Commercial Freight & IoT Cold-Chain Surveillance', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),

        ..._reeferFreight.map((freight) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${freight.truckType} • Reg: ${freight.regNumber}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      Text('Carrier: ${freight.carrierName} • e-BOL: ${freight.eBolNumber}', style: const TextStyle(color: textMuted, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: freight.currentTempC <= 4.0 ? accentGreen.withOpacity(0.15) : accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: freight.currentTempC <= 4.0 ? accentGreen : accentGold),
                    ),
                    child: Text('REEFER TEMP: ${freight.currentTempC}°C', style: TextStyle(color: freight.currentTempC <= 4.0 ? accentGreen : accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('📍 Route: ${freight.origin} ➔ ${freight.destination}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('⏳ ETA: ${freight.eta}', style: const TextStyle(color: accentBlue, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Generating Digital Weighbridge Slip for ${freight.regNumber}...'), backgroundColor: accentBlue),
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 14),
                    label: const Text('Weighbridge Slip', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: cardBorder)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening live GPS mesh tracking for ${freight.tripRef}...'), backgroundColor: accentGreen),
                      );
                    },
                    icon: const Icon(Icons.navigation, size: 14),
                    label: const Text('Live Telemetry Mesh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 6: SADC COMMODITY PRICE TERMINAL
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSadcPriceTerminalTab(AppState state) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text('SADC Wholesale Commodity Price Arbitration Matrix', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Commodity', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Harare (Mbare)', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Bulawayo (Malaleni)', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Lusaka (Soweto)', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Johannesburg (JPM)', style: TextStyle(color: textMuted, fontWeight: FontWeight.bold))),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('White Maize (MT)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataCell(Text('\$275 USD', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold))),
                DataCell(Text('\$290 USD', style: TextStyle(color: Colors.white))),
                DataCell(Text('\$260 USD', style: TextStyle(color: Colors.white))),
                DataCell(Text('R 4,850 ZAR', style: TextStyle(color: Colors.white))),
              ]),
              DataRow(cells: [
                DataCell(Text('Soya Beans (MT)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataCell(Text('\$480 USD', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold))),
                DataCell(Text('\$495 USD', style: TextStyle(color: Colors.white))),
                DataCell(Text('\$465 USD', style: TextStyle(color: Colors.white))),
                DataCell(Text('R 8,200 ZAR', style: TextStyle(color: Colors.white))),
              ]),
              DataRow(cells: [
                DataCell(Text('Sugar Beans (MT)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataCell(Text('\$920 USD', style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold))),
                DataCell(Text('\$950 USD', style: TextStyle(color: Colors.white))),
                DataCell(Text('\$890 USD', style: TextStyle(color: Colors.white))),
                DataCell(Text('R 16,400 ZAR', style: TextStyle(color: Colors.white))),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateTenderModal() {
    final titleCtrl = TextEditingController(text: 'Supply Tender: 200 MT Sugar Beans for Supermarket Chain');
    final tonsCtrl = TextEditingController(text: '200');
    final priceCtrl = TextEditingController(text: '900');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        title: const Text('Publish Reverse RFQ Tender', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Tender Title', labelStyle: TextStyle(color: textMuted))),
            TextField(controller: tonsCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Tonnage Required (MT)', labelStyle: TextStyle(color: textMuted))),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Target Price per Ton (USD)', labelStyle: TextStyle(color: textMuted))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: textMuted))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _rfqTenders.add(
                  B2bRfqTenderItem(
                    id: 'TND-${DateTime.now().millisecondsSinceEpoch % 1000}',
                    title: titleCtrl.text,
                    cropType: 'Sugar Beans',
                    requiredTons: double.tryParse(tonsCtrl.text) ?? 100,
                    targetPricePerTonUsd: double.tryParse(priceCtrl.text) ?? 900,
                    deliveryLocation: 'Harare Distribution Hub',
                    deadlineDate: '30 September 2026',
                    status: 'Active Bidding',
                    bids: [],
                  ),
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Procurement Tender published to all verified outgrowers!'), backgroundColor: accentGreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            child: const Text('Broadcast Tender'),
          ),
        ],
      ),
    );
  }
}
