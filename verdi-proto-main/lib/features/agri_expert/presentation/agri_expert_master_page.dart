import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/agri_expert_models.dart';
import '../state/agri_expert_state.dart';

class AgriExpertMasterPage extends ConsumerStatefulWidget {
  const AgriExpertMasterPage({super.key});

  @override
  ConsumerState<AgriExpertMasterPage> createState() => _AgriExpertMasterPageState();
}

class _AgriExpertMasterPageState extends ConsumerState<AgriExpertMasterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const bgDark = Color(0xFF060B14);
  static const cardDark = Color(0xFF0D1626);
  static const cardBorder = Color(0xFF1E293B);
  static const emerald = Color(0xFF10B981);
  static const cyan = Color(0xFF00F0FF);
  static const amber = Color(0xFFFF9F1C);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
  static const textMuted = Color(0xFF94A3B8);

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
    final state = ref.watch(agriExpertProvider);
    final notifier = ref.read(agriExpertProvider.notifier);
    final profile = state.profile;
    final activePersona = state.activePersona;

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Executive Top Header with Multi-Persona Switcher
            _buildExecutiveHeader(profile, activePersona, notifier),

            // 2. Custom Modern Tab Navigation Bar
            Container(
              decoration: const BoxDecoration(
                color: cardDark,
                border: Border(bottom: BorderSide(color: cardBorder)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: activePersona.color,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: textMuted,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: [
                  const Tab(icon: Icon(Icons.badge_outlined, size: 18), text: 'Profile & Discovery'),
                  Tab(
                    icon: const Icon(Icons.video_camera_front_outlined, size: 18),
                    text: 'Consultations (${state.consultations.where((c) => c.status == ConsultationStatus.scheduled).length})',
                  ),
                  const Tab(icon: Icon(Icons.biotech_outlined, size: 18), text: 'Diagnostic & Rx Pad'),
                  const Tab(icon: Icon(Icons.menu_book_outlined, size: 18), text: 'Knowledge & Q&A'),
                  Tab(
                    icon: Icon(activePersona.icon, size: 18),
                    text: '${activePersona.label} Desk',
                  ),
                  const Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 18), text: 'Wallet & Monetization'),
                ],
              ),
            ),

            // 3. Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileDiscoveryTab(state, notifier),
                  _buildConsultationsTab(state, notifier),
                  _buildDiagnosticRxTab(state, notifier),
                  _buildKnowledgeBaseTab(state, notifier),
                  _buildPersonaOperationsDeskTab(state, notifier),
                  _buildWalletMonetizationTab(state, notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. EXECUTIVE HEADER & MULTI-PERSONA SWITCHER BAR
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildExecutiveHeader(AgriExpertProfile profile, ExpertPersona activePersona, AgriExpertNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardDark,
        border: const Border(bottom: BorderSide(color: cardBorder)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Expert Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: activePersona.color.withOpacity(0.18),
                child: Icon(Icons.science, color: activePersona.color, size: 28),
              ),
              const SizedBox(width: 14),

              // Expert Title & Identity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.fullName,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: activePersona.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: activePersona.color),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 12, color: activePersona.color),
                              const SizedBox(width: 4),
                              Text(activePersona.badgeTitle, style: TextStyle(color: activePersona.color, fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.yearsOfExperience} Yrs Exp • ⭐ ${profile.rating} (${profile.reviewsCount} Reviews) • ${profile.operatingDistrict}',
                      style: const TextStyle(fontSize: 11.5, color: textMuted),
                    ),
                  ],
                ),
              ),

              // Wallet & Satisfaction Metric Pills
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: emerald.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('ADVISORY ESCROW WALLET', style: TextStyle(fontSize: 8.5, color: textMuted, fontWeight: FontWeight.bold)),
                    Text(
                      'US\$ ${profile.walletBalanceUsd.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: emerald, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Multi-Persona Mode Selector Pill Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: ExpertPersona.values.map((persona) {
                final isSelected = activePersona == persona;
                return Expanded(
                  child: InkWell(
                    onTap: () => notifier.switchPersona(persona),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? persona.color.withOpacity(0.18) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? persona.color : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            persona.icon,
                            size: 15,
                            color: isSelected ? persona.color : textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            persona.label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: PROFILE & EXPERT DIRECTORY DISCOVERY
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildProfileDiscoveryTab(AgriExpertState state, AgriExpertNotifier notifier) {
    final p = state.profile;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio & Credentials Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Professional Summary & Bio', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: emerald.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: emerald)),
                      child: const Text('PUBLIC DIRECTORY ACTIVE', style: TextStyle(color: emerald, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(p.bio, style: const TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1), height: 1.4)),
                const SizedBox(height: 16),

                // Specialization Tags
                const Text('Core Specialization Domains', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: p.specializations.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cyan.withOpacity(0.3)),
                      ),
                      child: Text(s, style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Verified Degrees & Licenses
          Text('Verified Credentials & Professional Licenses', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: p.credentials.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final c = p.credentials[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: amber.withOpacity(0.15),
                      radius: 18,
                      child: const Icon(Icons.school_outlined, color: amber, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                          Text('${c.institution} • Awarded ${c.yearAwarded}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          Text('License ID: ${c.credentialId}', style: const TextStyle(fontSize: 10.5, color: emerald, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                    const Icon(Icons.verified, color: emerald, size: 20),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Advisory Service Rate Cards
          Text('Advisory Service Pricing & Booking Rates', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildRateCard('Remote Video / Voice', 'US\$ ${p.hourlyRateUsd.toStringAsFixed(0)} / hr', 'Instant in-app tele-agronomy', Icons.videocam_outlined, cyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRateCard('On-Site GPS Farm Visit', 'US\$ ${p.farmVisitRateUsd.toStringAsFixed(0)} / visit', 'Full field inspection + soil probe', Icons.location_on_outlined, amber),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRateCard('Seasonal Retainer', 'US\$ ${p.monthlyRetainerRateUsd.toStringAsFixed(0)} / mo', 'Unlimited chat + 2 visits/mo', Icons.all_inclusive_outlined, emerald),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(String title, String price, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMuted)),
          const SizedBox(height: 4),
          Text(price, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10.5, color: textMuted.withOpacity(0.8))),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: CONSULTATIONS & FIELD VISITS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildConsultationsTab(AgriExpertState state, AgriExpertNotifier notifier) {
    final list = state.consultations;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scheduled Consultations & Field Visits', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Active remote tele-agronomy sessions and physical farm inspection schedule.', style: TextStyle(fontSize: 11.5, color: textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showBookConsultationDialog(context, notifier),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Schedule Consult', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: emerald, foregroundColor: bgDark),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final c = list[idx];
              final isCompleted = c.status == ConsultationStatus.completed;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.status.color.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: c.type == ConsultationType.videoCall ? cyan.withOpacity(0.15) : amber.withOpacity(0.15),
                          radius: 18,
                          child: Icon(c.type.icon, color: c.type == ConsultationType.videoCall ? cyan : amber, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${c.farmerName} • ${c.farmName}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              Text('${c.cropOrLivestock} • ${c.districtLocation}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.status.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: c.status.color.withOpacity(0.4)),
                          ),
                          child: Text(c.status.label, style: TextStyle(color: c.status.color, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Notes: ${c.summaryNotes}', style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), fontStyle: FontStyle.italic)),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: cyan),
                            const SizedBox(width: 6),
                            Text('${c.scheduledDate} (${c.scheduledTimeSlot}) • Fee: US\$ ${c.feeUsd.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11.5, color: cyan, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (!isCompleted)
                          Row(
                            children: [
                              if (c.type == ConsultationType.videoCall)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Connecting to encrypted video call room with ${c.farmerName}... 🎥'), backgroundColor: blue),
                                    );
                                  },
                                  icon: const Icon(Icons.videocam, size: 14),
                                  label: const Text('Launch Video', style: TextStyle(fontSize: 11)),
                                  style: OutlinedButton.styleFrom(foregroundColor: cyan, side: const BorderSide(color: cyan)),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  notifier.completeConsultation(c.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Consultation completed! US\$ ${c.feeUsd.toStringAsFixed(2)} added to advisory wallet.'), backgroundColor: emerald),
                                  );
                                },
                                icon: const Icon(Icons.check, size: 14),
                                label: const Text('Complete & Sign', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(backgroundColor: emerald, foregroundColor: bgDark),
                              ),
                            ],
                          ),
                      ],
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 3: DIAGNOSTIC & DIGITAL PRESCRIPTION PAD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildDiagnosticRxTab(AgriExpertState state, AgriExpertNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnostic Anomaly Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pest & Soil Anomaly Reviews', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: purple.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: purple)),
                child: const Text('AI MULTISPECTRAL ENGINE ACTIVE', style: TextStyle(color: purple, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.diagnosticCases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final d = state.diagnosticCases[idx];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: amber.withOpacity(0.15),
                          radius: 18,
                          child: const Icon(Icons.bug_report_outlined, color: amber, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${d.crop} • ${d.farmName}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                              Text('Farmer: ${d.farmerName} • Reported ${d.timestamp}', style: const TextStyle(fontSize: 11, color: textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: amber.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: amber)),
                          child: Text('${(d.aiConfidenceScore * 100).toStringAsFixed(0)}% AI CONFIDENCE', style: const TextStyle(color: amber, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Detected Anomaly: ${d.detectedAnomaly}', style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12.5, fontWeight: FontWeight.bold)),
                    Text('Symptoms: ${d.symptomDescription}', style: const TextStyle(color: textMuted, fontSize: 11.5)),
                    const SizedBox(height: 10),

                    // Soil Nutrient Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBorder)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Soil pH: ${d.soilPh}', style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text('N: ${d.nitrogenPpm} ppm', style: const TextStyle(color: emerald, fontSize: 11)),
                          Text('P: ${d.phosphorusPpm} ppm', style: const TextStyle(color: amber, fontSize: 11)),
                          Text('K: ${d.potassiumPpm} ppm', style: const TextStyle(color: purple, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Prescription pad generation button
                    ElevatedButton.icon(
                      onPressed: () => _showDigitalPrescriptionModal(context, d, notifier),
                      icon: const Icon(Icons.edit_note, size: 16),
                      label: const Text('Open Digital Prescription Pad', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: cyan, foregroundColor: bgDark),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Active Digital Prescriptions List
          Text('Issued Digital Agronomy Prescriptions (${state.prescriptions.length})', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.prescriptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final rx = state.prescriptions[idx];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: emerald.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rx #: ${rx.prescriptionNumber}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: emerald)),
                        Text(rx.createdAt, style: const TextStyle(color: textMuted, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${rx.farmName} (${rx.farmerName}) • Target: ${rx.crop}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Condition: ${rx.diagnosedCondition}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                    const SizedBox(height: 10),

                    // Inputs list
                    Column(
                      children: rx.items.map((it) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBorder)),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 14, color: emerald),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${it.inputName} (${it.dosagePerHectare}) - ${it.applicationMethod}', style: const TextStyle(fontSize: 11.5, color: Colors.white)),
                              ),
                              Text(it.phiSafetyDays, style: const TextStyle(fontSize: 10.5, color: amber, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    Text(rx.eudrComplianceNotice, style: const TextStyle(fontSize: 10.5, color: cyan, fontStyle: FontStyle.italic)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 4: KNOWLEDGE BASE & CONTENT HUB
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildKnowledgeBaseTab(AgriExpertState state, AgriExpertNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Farming Guides & Agronomic Publications', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Publish articles, spray calendars, and EUDR compliance guides for smallholders.', style: TextStyle(fontSize: 11.5, color: textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showPublishArticleModal(context, notifier),
                icon: const Icon(Icons.post_add, size: 16),
                label: const Text('Publish Guide', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: amber, foregroundColor: bgDark),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.articles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final art = state.articles[idx];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: blue.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: blue.withOpacity(0.3))),
                          child: Text(art.category, style: const TextStyle(color: blue, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                        Text('${art.readTimeMinutes} min read • Published ${art.publishedDate}', style: const TextStyle(fontSize: 11, color: textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(art.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(art.excerpt, style: const TextStyle(fontSize: 12, color: textMuted, height: 1.3)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.download, size: 14, color: emerald),
                        const SizedBox(width: 4),
                        Text('${art.downloadsCount} Farmer Downloads', style: const TextStyle(fontSize: 11, color: emerald, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 14),
                        const Icon(Icons.thumb_up_alt_outlined, size: 14, color: amber),
                        const SizedBox(width: 4),
                        Text('${art.likesCount} Upvotes', style: const TextStyle(fontSize: 11, color: amber)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Community Farmer Q&A Forum
          Text('Farmer Community Q&A Board', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.communityQnAs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final q = state.communityQnAs[idx];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: cardBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline, color: amber, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${q.questionTitle} (${q.cropTag})', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                        ),
                        Text('Asked by ${q.farmerName}', style: const TextStyle(fontSize: 11, color: textMuted)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(q.questionDetail, style: const TextStyle(fontSize: 12, color: textMuted)),
                    const SizedBox(height: 10),

                    // Expert Verified Answer Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: emerald.withOpacity(0.3))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified, color: emerald, size: 14),
                              const SizedBox(width: 6),
                              Text('Verified Advice by ${q.expertName}', style: const TextStyle(fontSize: 11, color: emerald, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(q.expertAnswer, style: const TextStyle(fontSize: 12, color: Color(0xFFF1F5F9), height: 1.35)),
                        ],
                      ),
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 5: DYNAMIC PERSONA OPERATIONS DESK
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPersonaOperationsDeskTab(AgriExpertState state, AgriExpertNotifier notifier) {
    switch (state.activePersona) {
      case ExpertPersona.independentConsultant:
        return _buildIndependentConsultantDesk(state, notifier);
      case ExpertPersona.governmentExtension:
        return _buildGovernmentExtensionDesk(state, notifier);
      case ExpertPersona.companyAgronomist:
        return _buildCorporateAgronomistDesk(state, notifier);
    }
  }

  // 👤 1. Independent Consultant Desk
  Widget _buildIndependentConsultantDesk(AgriExpertState state, AgriExpertNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: emerald.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: emerald.withOpacity(0.3))),
            child: Row(
              children: [
                const Icon(Icons.business_center, color: emerald, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Independent Consultant Business Suite', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                      Text('Manage private client CRM lists, automated VAT invoices, custom pricing tiers, and branded whitelabel soil/crop reports.', style: TextStyle(color: textMuted, fontSize: 11.5)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exporting whitelabeled agronomy PDF report with your private logo... 📄'), backgroundColor: emerald),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 14),
                  label: const Text('Export Branded PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: emerald, foregroundColor: bgDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Private Client CRM Table
          Text('Private Client CRM & Retainers (${state.consultantClients.length})', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.consultantClients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final cli = state.consultantClients[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: emerald.withOpacity(0.15), radius: 18, child: const Icon(Icons.person_pin, color: emerald, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${cli.clientName} • ${cli.estateName}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.white)),
                          Text('${cli.hectarage} Ha • Crops: ${cli.primaryCrops}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          Text('SLA: ${cli.slaStatus}', style: const TextStyle(fontSize: 10.5, color: cyan)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('US\$ ${cli.monthlyBillingUsd.toStringAsFixed(0)}/mo', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: emerald, fontSize: 14)),
                        Text(cli.pricingTier, style: const TextStyle(fontSize: 10, color: textMuted)),
                      ],
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

  // 🏛️ 2. Government Extension Desk
  Widget _buildGovernmentExtensionDesk(AgriExpertState state, AgriExpertNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: blue.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: blue.withOpacity(0.3))),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: blue, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Government Agritex Extension Operations Desk', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                      Text('Geofenced territory assignment, offline field data capture forms for remote rural wards, and emergency mass broadcast alerts.', style: TextStyle(color: textMuted, fontSize: 11.5)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showMassBroadcastDialog(context, notifier),
                  icon: const Icon(Icons.broadcast_on_personal, size: 14),
                  label: const Text('Mass Alert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: blue, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Offline Rural Field Capture Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Offline Rural Field Data Buffer (${state.offlineRecords.length})', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              OutlinedButton.icon(
                onPressed: () {
                  notifier.syncAllOfflineRecords();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Syncing all offline rural field inspection forms to National Agritex cloud... ☁️'), backgroundColor: blue),
                  );
                },
                icon: const Icon(Icons.sync, size: 14),
                label: const Text('Sync All to Cloud', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(foregroundColor: blue, side: const BorderSide(color: blue)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.offlineRecords.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final r = state.offlineRecords[idx];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: r.isSyncedToCloud ? emerald.withOpacity(0.15) : amber.withOpacity(0.15),
                      radius: 16,
                      child: Icon(r.isSyncedToCloud ? Icons.cloud_done : Icons.cloud_off, color: r.isSyncedToCloud ? emerald : amber, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r.farmerName} • ID: ${r.farmerNationalId}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                          Text('${r.wardNumber} • Crop: ${r.cropType}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          Text('Moisture: ${r.soilMoistureBand} • Pest: ${r.observedPest}', style: const TextStyle(fontSize: 10.5, color: cyan)),
                        ],
                      ),
                    ),
                    Text(r.isSyncedToCloud ? 'SYNCED' : 'CACHED OFFLINE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: r.isSyncedToCloud ? emerald : amber)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🏢 3. Corporate Agronomist Desk
  Widget _buildCorporateAgronomistDesk(AgriExpertState state, AgriExpertNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: purple.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: purple.withOpacity(0.3))),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: purple, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Corporate Outgrower Enterprise Firewall', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                      Text('Air-gapped proprietary outgrower yield analytics and warehouse inventory SKU synchronization for commercial contract schemes.', style: TextStyle(color: textMuted, fontSize: 11.5)),
                    ],
                  ),
                ),
                Text('FIREWALL ENFORCED', style: TextStyle(color: purple, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Priority Outgrower Task Dispatches (${state.corporateTasks.length})', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.corporateTasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final t = state.corporateTasks[idx];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.outgrowerBlock, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: purple)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: amber.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: amber)),
                          child: Text(t.urgency, style: const TextStyle(color: amber, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Contract Grower: ${t.farmerName} • Target: ${t.targetCrop}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Reported: ${t.issueReported}', style: const TextStyle(fontSize: 11.5, color: textMuted)),
                    const SizedBox(height: 10),

                    // Warehouse Input SKU Recommendation Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: cyan.withOpacity(0.3))),
                      child: Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 16, color: cyan),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Warehouse In-Stock SKU: ${t.inStockWarehouseSku}', style: const TextStyle(fontSize: 11, color: cyan)),
                          ),
                        ],
                      ),
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

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 6: WALLET & MONETIZATION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWalletMonetizationTab(AgriExpertState state, AgriExpertNotifier notifier) {
    final p = state.profile;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Balance Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [emerald.withOpacity(0.18), bgDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: emerald.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL ADVISORY REVENUE & ESCROW BALANCE', style: TextStyle(fontSize: 10.5, color: textMuted, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('US\$ ${p.walletBalanceUsd.toStringAsFixed(2)}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Instant Payout Request sent to EcoCash USD (+263 77 412 9081)... 💰'), backgroundColor: emerald),
                        );
                      },
                      icon: const Icon(Icons.payments, size: 16),
                      label: const Text('Withdraw Payout', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: emerald, foregroundColor: bgDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Performance Stats
          Text('Key Performance Metrics', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _buildMetricTile('Completed Consults', '${p.completedConsultations}', Icons.task_alt, cyan)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Client Satisfaction', '${p.clientSatisfactionScore}%', Icons.sentiment_very_satisfied, emerald)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricTile('Avg Response Time', '< 15 mins', Icons.timer, amber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(val, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10.5, color: textMuted)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MODALS & DIALOGS
  // ───────────────────────────────────────────────────────────────────────────
  void _showBookConsultationDialog(BuildContext context, AgriExpertNotifier notifier) {
    final farmerCtrl = TextEditingController();
    final farmCtrl = TextEditingController();
    final districtCtrl = TextEditingController();
    final cropCtrl = TextEditingController();
    ConsultationType selType = ConsultationType.videoCall;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              backgroundColor: cardDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: cardBorder)),
              title: const Text('Schedule Advisory Consultation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: farmerCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Farmer Name', hintText: 'e.g. Tariro Hove', labelStyle: TextStyle(color: textMuted)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: farmCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Farm / Scheme Name', hintText: 'e.g. Mazowe Valley Hub', labelStyle: TextStyle(color: textMuted)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: districtCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'District / Location', hintText: 'e.g. Mazowe Ward 4', labelStyle: TextStyle(color: textMuted)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cropCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Target Crop / Animal', hintText: 'e.g. Hybrid Maize (SC719)', labelStyle: TextStyle(color: textMuted)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: textMuted))),
                ElevatedButton(
                  onPressed: () {
                    final newSession = ConsultationSession(
                      id: 'CONS-${DateTime.now().millisecondsSinceEpoch % 1000}',
                      farmerName: farmerCtrl.text.trim().isEmpty ? 'Farmer Partner' : farmerCtrl.text.trim(),
                      farmName: farmCtrl.text.trim().isEmpty ? 'Regional Scheme' : farmCtrl.text.trim(),
                      districtLocation: districtCtrl.text.trim().isEmpty ? 'Mashonaland' : districtCtrl.text.trim(),
                      cropOrLivestock: cropCtrl.text.trim().isEmpty ? 'Maize' : cropCtrl.text.trim(),
                      type: selType,
                      scheduledDate: 'Today',
                      scheduledTimeSlot: '16:00 - 16:45',
                      feeUsd: 45.0,
                    );
                    notifier.addConsultation(newSession);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Consultation scheduled successfully! 📅'), backgroundColor: emerald),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: emerald, foregroundColor: bgDark),
                  child: const Text('Confirm Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDigitalPrescriptionModal(BuildContext context, DiagnosticCase diag, AgriExpertNotifier notifier) {
    final inputNameCtrl = TextEditingController(text: 'Coragen 200 SC');
    final dosageCtrl = TextEditingController(text: '150 ml / ha in 200L water');
    final phiCtrl = TextEditingController(text: '14 Days PHI');
    final methodCtrl = TextEditingController(text: 'Targeted Whorl Knapsack Direct Spray');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: cardBorder)),
          title: Row(
            children: [
              const Icon(Icons.edit_document, color: cyan),
              const SizedBox(width: 8),
              Text('Digital Prescription Pad (#RX-${DateTime.now().millisecondsSinceEpoch % 10000})', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prescribing for: ${diag.farmName} (${diag.farmerName})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Diagnosis: ${diag.detectedAnomaly}', style: const TextStyle(color: textMuted, fontSize: 11.5)),
                const SizedBox(height: 14),
                TextField(
                  controller: inputNameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Recommended Crop Input / Chemical', labelStyle: TextStyle(color: textMuted)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dosageCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Dosage per Hectare', labelStyle: TextStyle(color: textMuted)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: methodCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Application Method', labelStyle: TextStyle(color: textMuted)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phiCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Pre-Harvest Interval (PHI)', labelStyle: TextStyle(color: textMuted)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: textMuted))),
            ElevatedButton.icon(
              onPressed: () {
                final rx = DigitalPrescription(
                  id: 'RX-${DateTime.now().millisecondsSinceEpoch % 10000}',
                  prescriptionNumber: 'RX-ZIM-2026-${DateTime.now().millisecondsSinceEpoch % 10000}',
                  farmName: diag.farmName,
                  farmerName: diag.farmerName,
                  crop: diag.crop,
                  diagnosedCondition: diag.detectedAnomaly,
                  items: [
                    PrescriptionInputItem(
                      inputName: inputNameCtrl.text.trim().isEmpty ? 'Coragen 200 SC' : inputNameCtrl.text.trim(),
                      category: 'Bio-Selective Protection',
                      dosagePerHectare: dosageCtrl.text.trim().isEmpty ? '150 ml/ha' : dosageCtrl.text.trim(),
                      applicationMethod: methodCtrl.text.trim().isEmpty ? 'Direct Whorl Spray' : methodCtrl.text.trim(),
                      phiSafetyDays: phiCtrl.text.trim().isEmpty ? '14 Days PHI' : phiCtrl.text.trim(),
                      safetyWarning: 'Wear protective gear during application.',
                    ),
                  ],
                  issuingExpert: 'Dr. Nyasha Sibanda',
                  createdAt: '2026-08-24',
                );
                notifier.issuePrescription(rx);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('e-Prescription #${rx.prescriptionNumber} signed and transmitted to farmer! 📋'), backgroundColor: emerald),
                );
              },
              icon: const Icon(Icons.send, size: 14),
              label: const Text('Sign & Transmit Rx', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: cyan, foregroundColor: bgDark),
            ),
          ],
        );
      },
    );
  }

  void _showPublishArticleModal(BuildContext context, AgriExpertNotifier notifier) {
    final titleCtrl = TextEditingController();
    final excerptCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: cardBorder)),
          title: const Text('Publish Farming Guide / Knowledge Article', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Guide Title', hintText: 'e.g. Managing Fall Armyworm in Sandy Loam', labelStyle: TextStyle(color: textMuted)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: excerptCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Short Excerpt / Summary', labelStyle: TextStyle(color: textMuted)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Full Guide Content & Recommendations', labelStyle: TextStyle(color: textMuted)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: textMuted))),
            ElevatedButton.icon(
              onPressed: () {
                final art = KnowledgeArticle(
                  id: 'ART-${DateTime.now().millisecondsSinceEpoch % 1000}',
                  title: titleCtrl.text.trim().isEmpty ? 'Agronomy Best Practices Guide' : titleCtrl.text.trim(),
                  category: 'Crop Nutrition & Protection',
                  excerpt: excerptCtrl.text.trim().isEmpty ? 'Essential field guidance for smallholder farmers.' : excerptCtrl.text.trim(),
                  fullContent: contentCtrl.text.trim().isEmpty ? 'Follow certified agronomic procedures.' : contentCtrl.text.trim(),
                  author: 'Dr. Nyasha Sibanda',
                  publishedDate: 'Today',
                );
                notifier.publishArticle(art);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Knowledge article published to farmer resource center! 📚'), backgroundColor: amber),
                );
              },
              icon: const Icon(Icons.publish, size: 14),
              label: const Text('Publish Guide', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: amber, foregroundColor: bgDark),
            ),
          ],
        );
      },
    );
  }

  void _showMassBroadcastDialog(BuildContext context, AgriExpertNotifier notifier) {
    final titleCtrl = TextEditingController();
    final districtCtrl = TextEditingController(text: 'Mazowe District (Wards 4, 5, 7)');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: cardBorder)),
          title: const Text('Broadcast Emergency SMS & Voice Alert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Alert Message / Notice', hintText: 'e.g. Fall Armyworm Scout Alert', labelStyle: TextStyle(color: textMuted)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: districtCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Target Geofenced Ward / District', labelStyle: TextStyle(color: textMuted)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: textMuted))),
            ElevatedButton.icon(
              onPressed: () {
                final alr = ExtensionBroadcastAlert(
                  id: 'ALR-${DateTime.now().millisecondsSinceEpoch % 1000}',
                  title: titleCtrl.text.trim().isEmpty ? 'Pest Outbreak Alert' : titleCtrl.text.trim(),
                  targetWardDistrict: districtCtrl.text.trim(),
                  recipientFarmersCount: 1840,
                  alertType: 'Emergency Extension Alert',
                  channel: 'SMS Broadcast & Voice Note',
                  sentAt: 'Just Now',
                );
                notifier.broadcastGovernmentAlert(alr);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mass SMS & Voice alert broadcasted to 1,840 farmers in district! 📢'), backgroundColor: blue),
                );
              },
              icon: const Icon(Icons.send, size: 14),
              label: const Text('Transmit Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: blue, foregroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }
}
