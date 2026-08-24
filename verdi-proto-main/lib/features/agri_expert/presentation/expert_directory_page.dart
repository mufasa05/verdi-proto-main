import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/agri_expert_models.dart';
import '../state/agri_expert_state.dart';
import '../../../state/app_state.dart';
import '../../../state/chat_state.dart';

class ExpertDirectoryPage extends ConsumerStatefulWidget {
  const ExpertDirectoryPage({super.key});

  @override
  ConsumerState<ExpertDirectoryPage> createState() => _ExpertDirectoryPageState();
}

class _ExpertDirectoryPageState extends ConsumerState<ExpertDirectoryPage> {
  String _searchQuery = '';
  String _selectedDistrict = 'All Locations';
  String _selectedCategory = 'All Services';

  final List<String> _districts = [
    'All Locations',
    'Mazowe & Chinhoyi',
    'Harare & Mashonaland',
    'Mutare & Manicaland',
    'Midlands (Gweru)',
    'Matabeleland South',
  ];

  final List<String> _categories = [
    'All Services',
    'Soil Science & Fertility',
    'Pest & Disease Control',
    'EUDR & Export Compliance',
    'Irrigation & Water Engineering',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agriExpertProvider);
    final allListings = state.serviceListings;

    final filtered = allListings.where((l) {
      final matchesSearch = l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.expertName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All Services' || l.category == _selectedCategory;
      final matchesDistrict = _selectedDistrict == 'All Locations' ||
          l.locationDistrict.toLowerCase().contains(_selectedDistrict.toLowerCase()) ||
          l.locationDistrict == 'All Zimbabwe & SADC';
      return matchesSearch && matchesCategory && matchesDistrict;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Agri-Expert Advisory Directory',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search soil test, pest diagnostics, agronomist...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._districts.map((d) {
                        final isSel = _selectedDistrict == d;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(d, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : const Color(0xFF334155))),
                            selected: isSel,
                            selectedColor: const Color(0xFF16A34A),
                            backgroundColor: const Color(0xFFF1F5F9),
                            onSelected: (val) => setState(() => _selectedDistrict = d),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : const Color(0xFF334155))),
                            selected: isSel,
                            selectedColor: const Color(0xFF2563EB),
                            backgroundColor: const Color(0xFFF1F5F9),
                            onSelected: (val) => setState(() => _selectedCategory = cat),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Listing cards
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No Expert Services Found', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Try adjusting your search query or location filter.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      return _buildDirectoryCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryCard(BuildContext context, AdvisoryServiceListing item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: item.expertPersona.color.withOpacity(0.12),
                  child: Icon(item.expertPersona.icon, color: item.expertPersona.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.expertName,
                              style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                          ),
                          if (item.isVerifiedByState) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.verified, color: Colors.white, size: 10),
                                  SizedBox(width: 3),
                                  Text('STATE VERIFIED', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${item.expertPersona.label} • ${item.locationDistrict}', style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Text(
                  item.priceUsd > 0 ? '\$${item.priceUsd.toStringAsFixed(0)}' : 'FREE',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: item.priceUsd > 0 ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(item.description, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.35, fontWeight: FontWeight.w500)),
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                  child: Text(item.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                  child: Text(item.deliveryMode, style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    final session = ConsultationSession(
                      id: 'CONS-${DateTime.now().millisecondsSinceEpoch % 1000}',
                      farmerName: 'Kudakwashe Moyo',
                      farmName: 'Mazowe Citrus Plot',
                      districtLocation: item.locationDistrict,
                      cropOrLivestock: 'Commercial Crops',
                      type: ConsultationType.physicalFarmVisit,
                      scheduledDate: 'Tomorrow',
                      scheduledTimeSlot: '10:00 - 11:30',
                      feeUsd: item.priceUsd,
                      status: ConsultationStatus.scheduled,
                      summaryNotes: 'Booked service: ${item.title}',
                    );
                    ref.read(agriExpertProvider.notifier).addConsultation(session);

                    // Start direct chat thread with the owner of the post
                    ref.read(chatProvider.notifier).startOrGetThread(
                      '${item.expertName} (Agri-Expert)',
                      'Service: ${item.title}',
                      'Hello ${item.expertName}, I have booked your service: "${item.title}" (${item.priceUsd > 0 ? '\$${item.priceUsd.toStringAsFixed(0)} ${item.pricingUnit}' : 'FREE Extension'}). I look forward to communicating with you.',
                      'Expert Advisory',
                    );

                    // Navigate directly to My Chats module (Nav Index 2)
                    ref.read(appStateProvider.notifier).setNavIndex(2);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booked ${item.title} with ${item.expertName}! Opening direct chat...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Book Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
