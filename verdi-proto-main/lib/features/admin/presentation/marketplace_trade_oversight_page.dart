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
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGold = Color(0xFFF59E0B);
  static const textMuted = Color(0xFF94A3B8);

  final List<Map<String, dynamic>> _pendingListings = [
    {
      'id': 'LST-9921',
      'title': '50 MT White Non-GMO Maize',
      'category': 'Grains & Cereals',
      'seller': 'Kudakwashe Moyo',
      'location': 'Mufasa Estate, Chiredzi',
      'price': '\$295.00 / MT',
      'volume': '50 MT Available',
      'eudr': 'VERIFIED',
      'status': 'PENDING_APPROVAL',
      'imageUrl': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?auto=format&fit=crop&w=900&q=80',
      'harvestDate': '12 August 2026',
      'moisture': '12.4% (GMB Standard Passed)',
    },
    {
      'id': 'LST-8812',
      'title': '120 Bales Virginia Flue-Cured Tobacco',
      'category': 'Commercial Cash Crops',
      'seller': 'Bvuma Estates',
      'location': 'Chipinge, Manicaland',
      'price': '\$4.35 / Kg',
      'volume': '120 Bales (14,400 kg)',
      'eudr': 'VERIFIED',
      'status': 'PENDING_APPROVAL',
      'imageUrl': 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=900&q=80',
      'harvestDate': '05 August 2026',
      'moisture': '10.8% Grade A1',
    },
    {
      'id': 'LST-4401',
      'title': '300 Boxes Fresh Grade A Tomatoes',
      'category': 'Vegetables & Fresh',
      'seller': 'Goromonzi Producers Co-op',
      'location': 'Goromonzi, Mashonaland East',
      'price': '\$15.00 / Box (20kg)',
      'volume': '6,000 kg total',
      'eudr': 'VERIFIED',
      'status': 'PENDING_APPROVAL',
      'imageUrl': 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?auto=format&fit=crop&w=900&q=80',
      'harvestDate': '18 August 2026',
      'moisture': 'Fresh Harvest',
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showListingDetailsModal(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: cardBorder)),
        title: Row(
          children: [
            const Icon(Icons.verified_sharp, color: accentGreen),
            const SizedBox(width: 8),
            Text('Listing Moderation Audit', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['imageUrl'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 160, color: const Color(0xFF0B0F17), child: const Icon(Icons.image, color: textMuted)),
                ),
              ),
              const SizedBox(height: 14),
              Text(item['title'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              Text('Price: ${item['price']} • Category: ${item['category']}', style: const TextStyle(color: accentGreen, fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0B0F17), borderRadius: BorderRadius.circular(10), border: Border.all(color: cardBorder)),
                child: Column(
                  children: [
                    _infoRow('Producer / Seller', item['seller']),
                    _infoRow('Location', item['location']),
                    _infoRow('Available Volume', item['volume']),
                    _infoRow('Harvest Date', item['harvestDate']),
                    _infoRow('Moisture & Quality', item['moisture']),
                    _infoRow('EUDR Satellite Compliance', item['eudr']),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: textMuted)),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() => item['status'] = 'FLAGGED');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Listing ${item['id']} FLAGGED for inspection.'), backgroundColor: accentGold),
              );
            },
            style: OutlinedButton.styleFrom(foregroundColor: accentGold, side: const BorderSide(color: accentGold)),
            child: const Text('Flag Listing'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _pendingListings.remove(item));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Listing ${item['title']} APPROVED & LIVE on Marketplace!'), backgroundColor: accentGreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
            child: const Text('Approve & Publish'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: textMuted)),
          Flexible(child: Text(val, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Marketplace & Trade Floor Oversight', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Listing moderation queue, trade arbitration, and price floor controls', style: const TextStyle(fontSize: 12, color: textMuted)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
          child: TabBar(
            controller: _tabController,
            indicatorColor: accentGreen,
            labelColor: accentGreen,
            unselectedLabelColor: textMuted,
            tabs: const [
              Tab(text: 'Listing Moderation Queue'),
              Tab(text: 'Open Trade Disputes & Escrow'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 550,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildModerationQueueTab(),
              _buildDisputesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModerationQueueTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_pendingListings.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline, color: accentGreen, size: 44),
                  const SizedBox(height: 8),
                  Text('Moderation Queue Clear', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('All crop listings have been reviewed and published.', style: TextStyle(color: textMuted, fontSize: 12)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingListings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final item = _pendingListings[idx];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: const Color(0xFF0B0F17), child: const Icon(Icons.storefront, color: textMuted)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['title'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                            Text('Seller: ${item['seller']} • Location: ${item['location']}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                            Text('Price: ${item['price']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentGreen)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showListingDetailsModal(item),
                        style: ElevatedButton.styleFrom(backgroundColor: accentGreen, foregroundColor: Colors.white),
                        child: const Text('Review Listing'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDisputesTab() {
    return SingleChildScrollView(
      child: Column(
        children: _disputes.map((dsp) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
            child: Row(
              children: [
                const Icon(Icons.gavel, color: accentGold, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dispute ${dsp['id']} (Trade ${dsp['tradeId']})', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                      Text('Buyer: ${dsp['buyer']} vs Seller: ${dsp['seller']} • Amount: ${dsp['amount']}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                      Text('Issue: ${dsp['issue']}', style: const TextStyle(fontSize: 11, color: accentGold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dispute ${dsp['id']} escalated to Arbiter Console.'), backgroundColor: accentBlue),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                  child: const Text('Arbitrate'),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
