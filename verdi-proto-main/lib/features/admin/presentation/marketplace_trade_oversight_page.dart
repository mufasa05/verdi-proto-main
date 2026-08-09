import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dedicated Sovereign Control Console: Marketplace & Trade Floor Oversight
class MarketplaceTradeOversightPage extends StatefulWidget {
  const MarketplaceTradeOversightPage({super.key});

  @override
  State<MarketplaceTradeOversightPage> createState() => _MarketplaceTradeOversightPageState();
}

class _MarketplaceTradeOversightPageState extends State<MarketplaceTradeOversightPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentDanger = Color(0xFFEF4444);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  final List<Map<String, dynamic>> _priceFloors = [
    {'commodity': 'White Non-GMO Maize', 'unit': 'Per Metric Ton (MT)', 'floorPrice': 290.00, 'ceilingPrice': 350.00, 'authority': 'GMB Silo Floor Policy'},
    {'commodity': 'Flue-Cured Tobacco (Grade A)', 'unit': 'Per Kilogram (Kg)', 'floorPrice': 4.20, 'ceilingPrice': 5.80, 'authority': 'TIMB Auction Minimum'},
    {'commodity': 'Grade A Tomatoes (Fresh)', 'unit': 'Per Box (20Kg)', 'floorPrice': 14.50, 'ceilingPrice': 22.00, 'authority': 'Mbare Musika Daily Floor'},
    {'commodity': 'Winter Wheat (Hard Red)', 'unit': 'Per Metric Ton (MT)', 'floorPrice': 380.00, 'ceilingPrice': 440.00, 'authority': 'National Grain Reserve'},
    {'commodity': 'Soya Beans (Oilseed)', 'unit': 'Per Metric Ton (MT)', 'floorPrice': 410.00, 'ceilingPrice': 480.00, 'authority': 'Oil Expressers Association'},
  ];

  final List<Map<String, dynamic>> _pendingListings = [
    {
      'id': 'LST-9921',
      'title': '50 MT White Non-GMO Maize',
      'seller': 'Tendai Moyo (Mashonaland West)',
      'price': '\$295.00 / MT',
      'eudr': 'VERIFIED',
      'status': 'PENDING_APPROVAL',
    },
    {
      'id': 'LST-8812',
      'title': '120 Bales Virginia Flue-Cured Tobacco',
      'seller': 'Bvuma Estates (Chipinge)',
      'price': '\$4.35 / Kg',
      'eudr': 'VERIFIED',
      'status': 'PENDING_APPROVAL',
    },
    {
      'id': 'LST-4401',
      'title': '300 Boxes Fresh Grade A Tomatoes',
      'seller': 'Goromonzi Co-op',
      'price': '\$15.00 / Box',
      'eudr': 'VERIFIED',
      'status': 'PENDING_APPROVAL',
    },
  ];

  final List<Map<String, dynamic>> _disputes = [
    {
      'id': 'DSP-0091',
      'tradeId': 'TRD-88241',
      'buyer': 'Harare Fresh Hub',
      'seller': 'Goromonzi Co-op',
      'amount': '\$4,500.00',
      'issue': 'Buyer claims 10% moisture content mismatch on arrival at Mbare Musika.',
      'status': 'OPEN_ARBITRATION',
    },
    {
      'id': 'DSP-0042',
      'tradeId': 'TRD-11920',
      'buyer': 'National Foods Treasury',
      'seller': 'Tendai Moyo',
      'amount': '\$14,750.00',
      'issue': 'Logistics delay past 48hr delivery window due to refrigerated truck breakdown.',
      'status': 'OPEN_ARBITRATION',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marketplace Trade Floor & Price Policy Oversight',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'National commodity price floor publishing, listing moderation, and trade dispute arbitration.',
                    style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: accentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentGreen.withValues(alpha: 0.4)),
              ),
              child: Text(
                'TRADE FLOOR ACTIVE',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: accentGreen),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: accentGreen,
            labelColor: accentGreen,
            unselectedLabelColor: textMuted,
            tabs: const [
              Tab(text: 'Commodity Price Floors & Ceilings'),
              Tab(text: 'Listing Moderation Queue'),
              Tab(text: 'Escrow & Dispute Arbitration'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 900,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPriceFloorsTab(),
              _buildListingModerationTab(),
              _buildDisputesTab(),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 1: PRICE FLOORS ---
  Widget _buildPriceFloorsTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Official Sovereign Commodity Price Floors', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Updated floor prices published across all trade floors live.'), backgroundColor: accentGreen),
                );
              },
              icon: const Icon(Icons.publish, size: 16),
              label: const Text('Publish Prices Live'),
              style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),

        for (int i = 0; i < _priceFloors.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_priceFloors[i]['commodity'], style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${_priceFloors[i]['unit']} • Authority: ${_priceFloors[i]['authority']}', style: const TextStyle(color: textMuted, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Floor: \$${_priceFloors[i]['floorPrice'].toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: accentGreen)),
                        Text('Ceiling: \$${_priceFloors[i]['ceilingPrice'].toStringAsFixed(2)}', style: const TextStyle(color: accentBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(width: 14),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: accentGold),
                      onPressed: () => _showEditPriceModal(_priceFloors[i]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 2: LISTING MODERATION ---
  Widget _buildListingModerationTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text('Pending Marketplace Listing Moderation Queue', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),

        if (_pendingListings.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
            child: const Center(child: Text('No pending listings requiring moderation.', style: TextStyle(color: textMuted))),
          )
        else
          for (int i = 0; i < _pendingListings.length; i++) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_pendingListings[i]['title'], style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(_pendingListings[i]['price'], style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: accentGreen)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Seller: ${_pendingListings[i]['seller']} • EUDR Status: ${_pendingListings[i]['eudr']}', style: const TextStyle(color: textMuted, fontSize: 12)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _pendingListings.removeAt(i));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Listing APPROVED & published live to trade floor.'), backgroundColor: accentGreen),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Approve Listing'),
                        style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _pendingListings.removeAt(i));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Listing REJECTED with feedback to seller.'), backgroundColor: accentDanger),
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 16, color: accentDanger),
                        label: const Text('Reject Listing', style: TextStyle(color: accentDanger)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: accentDanger)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
      ],
    );
  }

  // --- TAB 3: DISPUTES ---
  Widget _buildDisputesTab() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text('Active Trade Escrow Dispute Arbitration Terminal', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),

        for (int i = 0; i < _disputes.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: accentGold)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gavel, color: accentGold, size: 20),
                        const SizedBox(width: 8),
                        Text('Dispute #${_disputes[i]['id']} (Trade ${_disputes[i]['tradeId']})', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    Text(_disputes[i]['amount'], style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: accentGold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Buyer: ${_disputes[i]['buyer']} • Seller: ${_disputes[i]['seller']}', style: const TextStyle(color: textMuted, fontSize: 12)),
                const SizedBox(height: 6),
                Text(_disputes[i]['issue'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _disputes.removeAt(i));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Escrow released to SELLER.'), backgroundColor: accentGreen),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                      child: const Text('Release Escrow to Seller', style: TextStyle(fontSize: 11)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _disputes.removeAt(i));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Escrow fully refunded to BUYER.'), backgroundColor: accentBlue),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white),
                      child: const Text('Full Refund to Buyer', style: TextStyle(fontSize: 11)),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _disputes.removeAt(i));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Escrow split 50/50 between Buyer and Seller.'), backgroundColor: accentGold),
                        );
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: accentGold)),
                      child: const Text('Split 50/50', style: TextStyle(color: accentGold, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showEditPriceModal(Map<String, dynamic> item) {
    final floorCtrl = TextEditingController(text: item['floorPrice'].toString());
    final ceilCtrl = TextEditingController(text: item['ceilingPrice'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        title: Text('Edit Floor Price: ${item['commodity']}', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: floorCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Minimum Floor Price (\$)', labelStyle: TextStyle(color: textMuted))),
            const SizedBox(height: 10),
            TextField(controller: ceilCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Maximum Ceiling Price (\$)', labelStyle: TextStyle(color: textMuted))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: textMuted))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item['floorPrice'] = double.tryParse(floorCtrl.text) ?? item['floorPrice'];
                item['ceilingPrice'] = double.tryParse(ceilCtrl.text) ?? item['ceilingPrice'];
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            child: const Text('Save Price Floor'),
          ),
        ],
      ),
    );
  }
}
