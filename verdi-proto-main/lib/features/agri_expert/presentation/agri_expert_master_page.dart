import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/chat_state.dart';
import '../data/agri_expert_models.dart';
import '../state/agri_expert_state.dart';

class AgriExpertMasterPage extends ConsumerStatefulWidget {
  const AgriExpertMasterPage({super.key});

  @override
  ConsumerState<AgriExpertMasterPage> createState() => _AgriExpertMasterPageState();
}

class _AgriExpertMasterPageState extends ConsumerState<AgriExpertMasterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final appState = ref.watch(appStateProvider);
    final persona = appState.expertPersona;
    final expertState = ref.watch(agriExpertProvider);
    final profile = expertState.profile.copyWith(activePersona: persona);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildExpertHeader(context, profile, persona),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: persona.color,
                  unselectedLabelColor: const Color(0xFF64748B),
                  indicatorColor: persona.color,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.dashboard_outlined, size: 18),
                      text: _getPersonaDeskTitle(persona),
                    ),
                    const Tab(
                      icon: Icon(Icons.campaign_outlined, size: 18),
                      text: 'Advisory Market & Ads',
                    ),
                    const Tab(
                      icon: Icon(Icons.videocam_outlined, size: 18),
                      text: 'Consultations & GPS Visits',
                    ),
                    const Tab(
                      icon: Icon(Icons.biotech_outlined, size: 18),
                      text: 'Diagnostics & GIS Rx Pad',
                    ),
                    const Tab(
                      icon: Icon(Icons.forum_outlined, size: 18),
                      text: 'Community Hub & Q&A',
                    ),
                    const Tab(
                      icon: Icon(Icons.account_balance_wallet_outlined, size: 18),
                      text: 'Wallet & Invoicing',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDivergentPersonaDesk(context, profile, persona, expertState),
            _buildAdvisoryMarketingDesk(context, expertState),
            _buildConsultationsTab(context, expertState),
            _buildDiagnosticAndRxTab(context, expertState),
            _buildCommunityAndKnowledgeTab(context, expertState),
            _buildWalletAndMonetizationTab(context, expertState),
          ],
        ),
      ),
    );
  }

  String _getPersonaDeskTitle(ExpertPersona persona) {
    switch (persona) {
      case ExpertPersona.independentConsultant:
        return 'Private Practice CRM';
      case ExpertPersona.governmentExtension:
        return 'Agritex Extension Hub';
      case ExpertPersona.companyAgronomist:
        return 'Corporate Scheme Desk';
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // IMMUTABLE EXPERT HEADER WITH STATE ACCREDITATION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildExpertHeader(BuildContext context, AgriExpertProfile profile, ExpertPersona persona) {
    final isStateVerified = persona == ExpertPersona.governmentExtension || profile.isVerifiedByState;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            persona.color.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with persona badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(persona.icon, size: 34, color: persona.color),
                    ),
                  ),
                  if (isStateVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD97706),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 18),

              // Expert Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.fullName,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isStateVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.shield, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'VERIFIED BY STATE',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${persona.badgeTitle} • ${profile.companyAffiliation}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.operatingDistrict,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Locked Persona Badge & Inquiry Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock, color: Colors.white70, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          persona.label,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _showPersonaInquiryDialog(context, persona),
                    child: const Text(
                      'Request Change Inquiry',
                      style: TextStyle(color: Colors.white70, fontSize: 10.5, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // KPI Stats row
          Row(
            children: [
              _buildHeaderStat('Consults Conducted', '${profile.completedConsultations}', Icons.chat),
              _buildHeaderStat('Satisfaction Score', '${profile.clientSatisfactionScore}%', Icons.star),
              _buildHeaderStat('Experience', '${profile.yearsOfExperience} Yrs', Icons.military_tech),
              if (persona == ExpertPersona.independentConsultant)
                _buildHeaderStat('Hourly Advisory', '\$${profile.hourlyRateUsd.toStringAsFixed(0)}/hr', Icons.attach_money),
              if (persona == ExpertPersona.governmentExtension)
                _buildHeaderStat('Assigned Wards', 'Wards 4, 5, 7', Icons.map),
              if (persona == ExpertPersona.companyAgronomist)
                _buildHeaderStat('Outgrower Blocks', 'Delta Block #12', Icons.corporate_fare),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DIVERGENT PERSONA DESK
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDivergentPersonaDesk(BuildContext context, AgriExpertProfile profile, ExpertPersona persona, AgriExpertState state) {
    switch (persona) {
      case ExpertPersona.independentConsultant:
        return _buildIndependentConsultantDesk(context, state);
      case ExpertPersona.governmentExtension:
        return _buildGovernmentExtensionDesk(context, state);
      case ExpertPersona.companyAgronomist:
        return _buildCorporateAgronomistDesk(context, state);
    }
  }

  // 👤 1. Independent Consultant Desk
  Widget _buildIndependentConsultantDesk(BuildContext context, AgriExpertState state) {
    final clients = state.consultantClients;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Private Advisory CRM & Retainer Management',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  ),
                  const Text('Manage commercial farm retainers, automated VAT billing, and whitelabel reports', style: TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddClientDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Client'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (clients.isEmpty)
            _buildEmptyStateCard(
              icon: Icons.business_center_outlined,
              title: 'No Private Retainer Clients Yet',
              description: 'When commercial estates book your agronomic retainers or precision advisory packages, their billing and SLA status will appear here.',
            )
          else
            ...clients.map((c) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), shape: BoxShape.circle),
                          child: const Icon(Icons.agriculture, color: Color(0xFF059669), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.clientName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              Text('${c.estateName} • ${c.hectarage.toStringAsFixed(0)} Ha (${c.primaryCrops})', style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFA7F3D0))),
                          child: Text('\$${c.monthlyBillingUsd.toStringAsFixed(0)} / mo', style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 15, color: Color(0xFF059669)),
                            const SizedBox(width: 4),
                            Text(c.slaStatus, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                          ],
                        ),
                        Text('Last Physical Visit: ${c.lastVisitDate}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  // 🏛️ 2. Government Extension Worker Desk
  Widget _buildGovernmentExtensionDesk(BuildContext context, AgriExpertState state) {
    final records = state.offlineRecords;
    final alerts = state.extensionAlerts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // State Verified Government Hub Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Ministry of Lands, Agriculture, Fisheries & Rural Development', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      SizedBox(height: 2),
                      Text('Agritex Rural Extension & Geospatial M&E System', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Deep link to government overview
                    ref.read(appStateProvider.notifier).setRole(UserRole.government);
                  },
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('Open Ministry Hub'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Offline inspection buffer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rural Offline Field Survey Buffer', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: state.isOfflineSyncing ? null : () => ref.read(agriExpertProvider.notifier).syncAllOfflineRecords(),
                icon: state.isOfflineSyncing
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.cloud_sync_outlined, size: 16),
                label: Text(state.isOfflineSyncing ? 'Syncing...' : 'Sync to National Cloud'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (records.isEmpty)
            _buildEmptyStateCard(
              icon: Icons.wifi_off_outlined,
              title: 'No Offline Field Surveys Stored',
              description: 'Conduct field inspections in low-connectivity areas. Records will automatically cache locally and sync to the Agritex central registry.',
            )
          else
            ...records.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: r.isSyncedToCloud ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                  child: Icon(r.isSyncedToCloud ? Icons.cloud_done : Icons.cloud_off, color: r.isSyncedToCloud ? const Color(0xFF059669) : const Color(0xFFD97706), size: 20),
                ),
                title: Text('${r.farmerName} • ${r.cropType}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('National ID: ${r.farmerNationalId} • ${r.wardNumber}\nObservation: ${r.observedPest}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                trailing: Text(r.recordedAt, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.bold)),
              ),
            )),

          const SizedBox(height: 20),

          // Emergency Broadcast Dispatcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Emergency Mass SMS & Voice Broadcaster', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showBroadcastDialog(context),
                icon: const Icon(Icons.cell_tower, size: 16),
                label: const Text('New Broadcast'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (alerts.isEmpty)
            _buildEmptyStateCard(
              icon: Icons.campaign_outlined,
              title: 'No Emergency Alerts Dispatched',
              description: 'Broadcast instant pest outbreak warnings and frost alerts to thousands of registered smallholders via SMS and native voice-notes.',
            )
          else
            ...alerts.map((a) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFFEE2E2), child: Icon(Icons.warning_amber, color: Color(0xFFDC2626))),
                title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                subtitle: Text('${a.targetWardDistrict} • Recipients: ${a.recipientFarmersCount} Farmers • Channel: ${a.channel}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                trailing: Text(a.sentAt, style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.bold)),
              ),
            )),
        ],
      ),
    );
  }

  // 🏢 3. Corporate Agronomist Desk
  Widget _buildCorporateAgronomistDesk(BuildContext context, AgriExpertState state) {
    final tasks = state.corporateTasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Air-Gapped Firewall Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield, color: Color(0xFF7C3AED), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Corporate Data Firewall Active: Outgrower contract data and proprietary fertilizer blends are isolated from public/independent consultant visibility.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF5B21B6), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Priority Outgrower Task Dispatches (2h Emergency SLA)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (tasks.isEmpty)
            _buildEmptyStateCard(
              icon: Icons.assignment_outlined,
              title: 'No Active Corporate Dispatches',
              description: 'Urgent pest anomalies reported by contracted outgrower scheme farmers will route to this dashboard for rapid field dispatch.',
            )
          else
            ...tasks.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                          child: Text(t.urgency, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(t.outgrowerBlock, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(6)),
                          child: Text(t.status, style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Contract Farmer: ${t.farmerName} • Crop: ${t.targetCrop}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Issue: ${t.issueReported}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF7C3AED)),
                          const SizedBox(width: 6),
                          Expanded(child: Text('Central Warehouse Match: ${t.inStockWarehouseSku}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5B21B6)))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: ADVISORY SERVICE MARKETING & ADVERTS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAdvisoryMarketingDesk(BuildContext context, AgriExpertState state) {
    final listings = state.serviceListings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Advisory Service Listings & Farmer Advertising', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Text('Market your specialized services directly to commercial and smallholder farmers', style: TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateServiceListingDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create Advert'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (listings.isEmpty)
            _buildEmptyStateCard(
              icon: Icons.campaign_outlined,
              title: 'No Advertised Services Published',
              description: 'Publish your soil testing, EUDR compliance, or drone survey packages to showcase on the Farmer Home screen and marketplace directory.',
            )
          else
            ...listings.map((l) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF16A34A).withOpacity(0.12), shape: BoxShape.circle),
                          child: const Icon(Icons.verified, color: Color(0xFF16A34A), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(l.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
                                  ),
                                  Text(
                                    l.priceUsd > 0 ? '\$${l.priceUsd.toStringAsFixed(0)} ${l.pricingUnit}' : 'Free Extension Service',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(l.description, style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.35, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                    child: Text(l.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                                    child: Text(l.deliveryMode, style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                                  ),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      final session = ConsultationSession(
                                        id: 'CONS-${DateTime.now().millisecondsSinceEpoch % 1000}',
                                        farmerName: 'Kudakwashe Moyo',
                                        farmName: 'Mazowe Citrus Plot',
                                        districtLocation: l.locationDistrict,
                                        cropOrLivestock: 'Commercial Crops',
                                        type: ConsultationType.physicalFarmVisit,
                                        scheduledDate: 'Tomorrow',
                                        scheduledTimeSlot: '10:00 - 11:30',
                                        feeUsd: l.priceUsd,
                                        status: ConsultationStatus.scheduled,
                                        summaryNotes: 'Booked advert: ${l.title}',
                                      );
                                      ref.read(agriExpertProvider.notifier).addConsultation(session);

                                      // Open direct chat thread with post owner
                                      ref.read(chatProvider.notifier).startOrGetThread(
                                        '${l.expertName} (Agri-Expert)',
                                        'Service: ${l.title}',
                                        'Hello ${l.expertName}, I have booked your service: "${l.title}". I would like to consult on my farm.',
                                        'Expert Advisory',
                                      );

                                      // Navigate to My Chats
                                      ref.read(appStateProvider.notifier).setNavIndex(2);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Booked ${l.title}! Opening direct chat with ${l.expertName}...')),
                                      );
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline, size: 14),
                                    label: const Text('Book & Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF16A34A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: CONSULTATIONS & GPS VISITS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildConsultationsTab(BuildContext context, AgriExpertState state) {
    final consults = state.consultations;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active & Scheduled Consultations', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
              ElevatedButton.icon(
                onPressed: () => _showAddConsultationDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Schedule Consult'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (consults.isEmpty)
            _buildEmptyStateCard(
              icon: Icons.videocam_outlined,
              title: 'No Consultations Scheduled',
              description: 'When farmers request remote video tele-agronomy sessions or physical farm visits, they will show up in your calendar here.',
            )
          else
            ...consults.map((c) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF3B82F6).withOpacity(0.12),
                          child: Icon(c.type.icon, color: const Color(0xFF2563EB), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.farmerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('${c.farmName} • ${c.districtLocation}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: c.status.color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                          child: Text(c.status.label, style: TextStyle(color: c.status.color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Target: ${c.cropOrLivestock}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('${c.scheduledDate} (${c.scheduledTimeSlot})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Notes: ${c.summaryNotes}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                    if (c.status == ConsultationStatus.scheduled) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              ref.read(agriExpertProvider.notifier).completeConsultation(c.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Consultation completed! Fee credited to wallet.')),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: const Text('Complete & Sign'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: DIAGNOSTICS & GIS RX PAD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDiagnosticAndRxTab(BuildContext context, AgriExpertState state) {
    final cases = state.diagnosticCases;
    final prescriptions = state.prescriptions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diagnostic Cases & Geospatial Pinpointer', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
              ElevatedButton.icon(
                onPressed: () => _showIssuePrescriptionDialog(context),
                icon: const Icon(Icons.edit_note, size: 16),
                label: const Text('Issue Digital Rx'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (cases.isEmpty && prescriptions.isEmpty)
            _buildEmptyStateCard(
              icon: Icons.biotech_outlined,
              title: 'No Diagnostic Cases Analyzed',
              description: 'Upload leaf scan photos or review crop pathology alerts. You can pinpoint anomalies directly on the GIS geospatial map and issue digital prescriptions.',
            )
          else ...[
            ...cases.map((d) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(backgroundColor: Color(0xFFFEE2E2), child: Icon(Icons.bug_report, color: Color(0xFFDC2626))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.detectedAnomaly, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('${d.farmerName} • ${d.farmName} (${d.district})', style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFDC2626).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text('${(d.aiConfidenceScore * 100).toStringAsFixed(0)}% Match', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Symptoms: ${d.symptomDescription}', style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    // Geospatial GPS coordinates bar
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFBBF7D0))),
                      child: Row(
                        children: [
                          const Icon(Icons.pin_drop, color: Color(0xFF16A34A), size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Geospatial Anomaly GPS: ${d.gpsLat.toStringAsFixed(4)}, ${d.gpsLng.toStringAsFixed(4)} (${d.district})',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ref.read(appStateProvider.notifier).setNavIndex(7); // Jump to Geospatial map
                            },
                            child: const Text('View on GIS Map →', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 5: COMMUNITY HUB & Q&A
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCommunityAndKnowledgeTab(BuildContext context, AgriExpertState state) {
    final posts = state.communityPosts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cross-Stakeholder Agri Community', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Text('Post agronomic field updates, answer farmer questions, and publish bulletins', style: TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateCommunityPostDialog(context),
                icon: const Icon(Icons.post_add, size: 16),
                label: const Text('Post Update'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (posts.isEmpty)
            _buildEmptyStateCard(
              icon: Icons.forum_outlined,
              title: 'No Community Bulletins Yet',
              description: 'Publish your first agronomy field update to advise farmers on crop scouting, fertilizer timing, and pest management.',
            )
          else
            ...posts.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 14),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF16A34A).withOpacity(0.12),
                          child: const Icon(Icons.person, color: Color(0xFF16A34A)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(p.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(width: 6),
                                  if (p.isVerifiedByState)
                                    const Icon(Icons.verified, color: Color(0xFFD97706), size: 15),
                                ],
                              ),
                              Text('${p.authorRoleTitle} • ${p.districtLocation} • ${p.timestamp}', style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                          child: Text(p.cropCategory, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(p.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(p.content, style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4)),
                    const Divider(height: 24),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.thumb_up_alt_outlined, size: 18, color: Color(0xFF16A34A)),
                          onPressed: () => ref.read(agriExpertProvider.notifier).upvoteCommunityPost(p.id),
                        ),
                        Text('${p.upvotes} Upvotes', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                        const Spacer(),
                        Text('${p.comments.length} Comments', style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 6: WALLET & MONETIZATION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWalletAndMonetizationTab(BuildContext context, AgriExpertState state) {
    final profile = state.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Advisory Escrow Balance', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('\$${profile.walletBalanceUsd.toStringAsFixed(2)}', style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Instant Cashout requested to EcoCash / USD Nostro!')),
                    );
                  },
                  icon: const Icon(Icons.account_balance_wallet, size: 16),
                  label: const Text('Instant Cashout'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Advisory Pricing Rates', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.timer_outlined, color: Color(0xFF16A34A)),
                  title: const Text('Hourly Remote Consultation'),
                  trailing: Text('\$${profile.hourlyRateUsd.toStringAsFixed(2)} / hr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: Color(0xFF3B82F6)),
                  title: const Text('Physical Farm Inspection Visit'),
                  trailing: Text('\$${profile.farmVisitRateUsd.toStringAsFixed(2)} / visit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined, color: Color(0xFF8B5CF6)),
                  title: const Text('Monthly Precision Agronomy Retainer'),
                  trailing: Text('\$${profile.monthlyRetainerRateUsd.toStringAsFixed(2)} / mo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DIALOGS & ACTION MODALS
  // ───────────────────────────────────────────────────────────────────────────
  void _showPersonaInquiryDialog(BuildContext context, ExpertPersona currentPersona) {
    final reasonCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    ExpertPersona requested = ExpertPersona.governmentExtension;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.assignment_ind_outlined, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('Persona Change Inquiry', style: TextStyle(fontSize: 17)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Persona: ${currentPersona.label}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 12),
              const Text('Requested Classification:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 6),
              DropdownButtonFormField<ExpertPersona>(
                value: requested,
                items: ExpertPersona.values.where((p) => p != currentPersona).map((p) {
                  return DropdownMenuItem(value: p, child: Text(p.label));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => requested = val);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(labelText: 'Accreditation / Agritex ID Ref', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Justification / Reason for Transfer', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final inquiry = PersonaChangeInquiry(
                  id: 'INQ-${DateTime.now().millisecondsSinceEpoch % 1000}',
                  expertId: 'EXP-01',
                  expertName: 'Dr. Nyasha Sibanda',
                  currentPersona: currentPersona,
                  requestedPersona: requested,
                  justification: reasonCtrl.text.trim(),
                  accreditationRef: refCtrl.text.trim(),
                  submittedAt: 'Just now',
                );
                ref.read(agriExpertProvider.notifier).submitPersonaChangeInquiry(inquiry);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inquiry submitted! Our verification board will review your credentials within 24-48 hours.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
              child: const Text('Submit Inquiry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateServiceListingDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String category = 'Soil Science & Fertility';
    String mode = 'On-Site Field Visit';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Publish Advisory Service Listing'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Service Title', hintText: 'e.g. Complete Soil Assay & Lime Blending'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'Outline what the farmer receives...'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price in USD (0 for Free Extension)', prefixText: '\$ '),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                final listing = AdvisoryServiceListing(
                  id: 'SRV-${DateTime.now().millisecondsSinceEpoch % 1000}',
                  expertId: 'EXP-01',
                  expertName: 'Dr. Nyasha Sibanda',
                  expertPersona: ref.read(appStateProvider).expertPersona,
                  title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Custom Agronomy Service',
                  description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : 'Specialized precision farming advisory.',
                  category: category,
                  priceUsd: price,
                  pricingUnit: price == 0 ? 'Free Service' : '/ visit',
                  deliveryMode: mode,
                  locationDistrict: 'Mashonaland & Harare',
                  createdAt: 'Today',
                );
                ref.read(agriExpertProvider.notifier).addServiceListing(listing);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Advisory advert published to Farmer Marketplace! 📢')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              child: const Text('Publish Advert'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCommunityPostDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String crop = 'Maize & Cereals';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Post Community Field Bulletin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Bulletin Title', hintText: 'e.g. Fall Armyworm Alert'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Agronomic Guidance & Advisory', hintText: 'Detail steps farmers should take...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final post = CommunityPost(
                id: 'POST-${DateTime.now().millisecondsSinceEpoch % 1000}',
                authorName: 'Dr. Nyasha Sibanda',
                authorRoleTitle: 'Agronomy Specialist',
                cropCategory: crop,
                districtLocation: 'Mashonaland',
                title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Field Advisory Update',
                content: contentCtrl.text.trim().isNotEmpty ? contentCtrl.text.trim() : 'Routine crop scouting advisory.',
                timestamp: 'Just now',
              );
              ref.read(agriExpertProvider.notifier).addCommunityPost(post);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Update posted to Community Hub! 🌾')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            child: const Text('Post Bulletin'),
          ),
        ],
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final wardCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dispatch Emergency Mass Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Alert Heading')),
            const SizedBox(height: 10),
            TextField(controller: wardCtrl, decoration: const InputDecoration(labelText: 'Target Wards (e.g. Ward 4 & 5)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final alert = ExtensionBroadcastAlert(
                id: 'ALR-${DateTime.now().millisecondsSinceEpoch % 1000}',
                title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Emergency Advisory',
                targetWardDistrict: wardCtrl.text.trim().isNotEmpty ? wardCtrl.text.trim() : 'Mazowe Ward 4',
                recipientFarmersCount: 850,
                alertType: 'Pest Outbreak Alert',
                channel: 'SMS & Voice-Note',
                sentAt: 'Just now',
              );
              ref.read(agriExpertProvider.notifier).broadcastGovernmentAlert(alert);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency SMS Broadcast sent to 850 farmers! 📡')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
            child: const Text('Dispatch SMS Broadcast'),
          ),
        ],
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final estateCtrl = TextEditingController();
    final haCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Onboard Retainer Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Farmer / Estate Name')),
            const SizedBox(height: 10),
            TextField(controller: estateCtrl, decoration: const InputDecoration(labelText: 'Location / Estate')),
            const SizedBox(height: 10),
            TextField(controller: haCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hectarage (Ha)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final client = ConsultantClient(
                id: 'CLI-${DateTime.now().millisecondsSinceEpoch % 1000}',
                clientName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'New Client Estate',
                estateName: estateCtrl.text.trim().isNotEmpty ? estateCtrl.text.trim() : 'Mazowe Valley',
                hectarage: double.tryParse(haCtrl.text.trim()) ?? 50.0,
                primaryCrops: 'Maize & Soybeans',
                pricingTier: 'Standard Retainer',
                monthlyBillingUsd: 350.0,
                slaStatus: '24/7 Priority Emergency SLA',
                lastVisitDate: 'Today',
              );
              ref.read(agriExpertProvider.notifier).addConsultantClient(client);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Retainer client onboarded successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            child: const Text('Onboard Client'),
          ),
        ],
      ),
    );
  }

  void _showAddConsultationDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final farmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule New Consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Farmer Name')),
            const SizedBox(height: 10),
            TextField(controller: farmCtrl, decoration: const InputDecoration(labelText: 'Farm Location')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final session = ConsultationSession(
                id: 'CONS-${DateTime.now().millisecondsSinceEpoch % 1000}',
                farmerName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'Farmer T. Hove',
                farmName: farmCtrl.text.trim().isNotEmpty ? farmCtrl.text.trim() : 'Mazowe Farm',
                districtLocation: 'Mazowe District',
                cropOrLivestock: 'Maize & Horticulture',
                type: ConsultationType.videoCall,
                scheduledDate: 'Today',
                scheduledTimeSlot: '15:00 - 15:45',
                feeUsd: 45.0,
                status: ConsultationStatus.scheduled,
                summaryNotes: 'Scheduled remote diagnostic assessment.',
              );
              ref.read(agriExpertProvider.notifier).addConsultation(session);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Consultation booked in calendar!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showIssuePrescriptionDialog(BuildContext context) {
    final farmerCtrl = TextEditingController();
    final cropCtrl = TextEditingController();
    final condCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Issue Digital Agronomy Prescription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: farmerCtrl, decoration: const InputDecoration(labelText: 'Farmer Name')),
            const SizedBox(height: 10),
            TextField(controller: cropCtrl, decoration: const InputDecoration(labelText: 'Target Crop')),
            const SizedBox(height: 10),
            TextField(controller: condCtrl, decoration: const InputDecoration(labelText: 'Diagnosed Anomaly / Condition')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final rx = DigitalPrescription(
                id: 'RX-${DateTime.now().millisecondsSinceEpoch % 1000}',
                prescriptionNumber: 'RX-ZW-2026-${DateTime.now().millisecondsSinceEpoch % 1000}',
                farmName: 'Mazowe Field Plot',
                farmerName: farmerCtrl.text.trim().isNotEmpty ? farmerCtrl.text.trim() : 'Farai Mutasa',
                crop: cropCtrl.text.trim().isNotEmpty ? cropCtrl.text.trim() : 'Maize',
                diagnosedCondition: condCtrl.text.trim().isNotEmpty ? condCtrl.text.trim() : 'Fall Armyworm',
                items: const [
                  PrescriptionInputItem(
                    inputName: 'Coragen 200 SC',
                    category: 'Bio-Selective Insecticide',
                    dosagePerHectare: '150 ml / ha',
                    applicationMethod: 'Targeted Whorl Knapsack Spray',
                    phiSafetyDays: '14 Days',
                    safetyWarning: 'Wear PPE.',
                  ),
                ],
                issuingExpert: 'Dr. Nyasha Sibanda',
                createdAt: '2026-08-24',
              );
              ref.read(agriExpertProvider.notifier).issuePrescription(rx);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Digital Rx signed and synced to GIS! 📜')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            child: const Text('Sign & Issue'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard({required IconData icon, required String title, required String description}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 14),
            Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
            const SizedBox(height: 6),
            Text(description, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
