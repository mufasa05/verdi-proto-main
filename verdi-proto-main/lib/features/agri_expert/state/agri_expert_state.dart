import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/agri_expert_models.dart';

class AgriExpertState {
  final AgriExpertProfile profile;
  final ExpertPersona activePersona;
  final List<ConsultationSession> consultations;
  final List<DiagnosticCase> diagnosticCases;
  final List<DigitalPrescription> prescriptions;
  final List<KnowledgeArticle> articles;
  final List<CommunityQnA> communityQnAs;
  final List<ConsultantClient> consultantClients;
  final List<ExtensionBroadcastAlert> extensionAlerts;
  final List<CorporateTaskDispatch> corporateTasks;
  final List<OfflineFieldRecord> offlineRecords;
  final bool isOfflineSyncing;

  const AgriExpertState({
    required this.profile,
    required this.activePersona,
    required this.consultations,
    required this.diagnosticCases,
    required this.prescriptions,
    required this.articles,
    required this.communityQnAs,
    required this.consultantClients,
    required this.extensionAlerts,
    required this.corporateTasks,
    required this.offlineRecords,
    this.isOfflineSyncing = false,
  });

  AgriExpertState copyWith({
    AgriExpertProfile? profile,
    ExpertPersona? activePersona,
    List<ConsultationSession>? consultations,
    List<DiagnosticCase>? diagnosticCases,
    List<DigitalPrescription>? prescriptions,
    List<KnowledgeArticle>? articles,
    List<CommunityQnA>? communityQnAs,
    List<ConsultantClient>? consultantClients,
    List<ExtensionBroadcastAlert>? extensionAlerts,
    List<CorporateTaskDispatch>? corporateTasks,
    List<OfflineFieldRecord>? offlineRecords,
    bool? isOfflineSyncing,
  }) {
    return AgriExpertState(
      profile: profile ?? this.profile,
      activePersona: activePersona ?? this.activePersona,
      consultations: consultations ?? this.consultations,
      diagnosticCases: diagnosticCases ?? this.diagnosticCases,
      prescriptions: prescriptions ?? this.prescriptions,
      articles: articles ?? this.articles,
      communityQnAs: communityQnAs ?? this.communityQnAs,
      consultantClients: consultantClients ?? this.consultantClients,
      extensionAlerts: extensionAlerts ?? this.extensionAlerts,
      corporateTasks: corporateTasks ?? this.corporateTasks,
      offlineRecords: offlineRecords ?? this.offlineRecords,
      isOfflineSyncing: isOfflineSyncing ?? this.isOfflineSyncing,
    );
  }
}

class AgriExpertNotifier extends StateNotifier<AgriExpertState> {
  AgriExpertNotifier()
      : super(
          AgriExpertState(
            profile: const AgriExpertProfile(
              id: 'EXP-ZIM-0994',
              fullName: 'Dr. Nyasha Sibanda (Chief Agronomist & Soil Scientist)',
              email: 'dr.sibanda@agri-sovereign.org',
              phone: '+263 77 412 9081',
              bio: 'BSc Agronomy (UZ), MSc Precision Soil Fertility (Wageningen). 14+ years advancing commercial irrigation, regenerative soil health, EUDR compliance, and pest mitigation across SADC.',
              specializations: [
                'Soil Chemistry & Fertilizer Plans',
                'Pest & Fall Armyworm Pathology',
                'Precision Drip Irrigation',
                'EUDR Zero-Deforestation Compliance',
                'Horticulture & Greenhouse Crops',
                'Outgrower Contract Schemes',
              ],
              credentials: [
                ExpertCredential(
                  title: 'MSc Soil Science & Crop Nutrition',
                  institution: 'Wageningen University',
                  yearAwarded: '2016',
                  credentialId: 'WUR-SOIL-9941',
                ),
                ExpertCredential(
                  title: 'Certified Agronomy Professional License',
                  institution: 'Zimbabwe Agricultural Professional Board (ZAPB)',
                  yearAwarded: '2014',
                  credentialId: 'ZAPB-LIC-2014-049',
                ),
                ExpertCredential(
                  title: 'EUDR SADC Lead Inspector Certificate',
                  institution: 'Southern Africa EUDR Assurance Body',
                  yearAwarded: '2024',
                  credentialId: 'EUDR-INSP-9910',
                ),
              ],
              yearsOfExperience: 14,
              rating: 4.98,
              reviewsCount: 112,
              hourlyRateUsd: 45.00,
              farmVisitRateUsd: 120.00,
              monthlyRetainerRateUsd: 350.00,
              operatingDistrict: 'Mashonaland West & Central (Mazowe Corridor)',
              companyAffiliation: 'Sovereign Agronomy Group & Delta Outgrower Scheme',
              activePersona: ExpertPersona.independentConsultant,
              walletBalanceUsd: 3450.00,
              completedConsultations: 158,
              clientSatisfactionScore: 99.2,
            ),
            activePersona: ExpertPersona.independentConsultant,
            consultations: [
              const ConsultationSession(
                id: 'CONS-901',
                farmerName: 'Kudakwashe Moyo',
                farmName: 'Mazowe Valley Citrus & Maize Estate',
                districtLocation: 'Mazowe Ward 4, Mashonaland Central',
                cropOrLivestock: 'Maize (Hybrid SC719) - 120 Ha',
                type: ConsultationType.videoCall,
                scheduledDate: 'Today',
                scheduledTimeSlot: '14:30 - 15:15',
                feeUsd: 45.00,
                status: ConsultationStatus.scheduled,
                summaryNotes: 'Severe leaf chlorosis observed on Field B pivot. Need immediate soil nitrogen topdressing advice.',
                farmGpsLat: -17.5120,
                farmGpsLng: 31.0210,
              ),
              const ConsultationSession(
                id: 'CONS-902',
                farmerName: 'Tariro Hove',
                farmName: 'Nyabira Commercial Horticulture Hub',
                districtLocation: 'Zvimba / Nyabira',
                cropOrLivestock: 'Export Fine Green Beans - 35 Ha',
                type: ConsultationType.physicalFarmVisit,
                scheduledDate: 'Tomorrow',
                scheduledTimeSlot: '09:00 - 12:30',
                feeUsd: 120.00,
                status: ConsultationStatus.scheduled,
                summaryNotes: 'Pre-export EUDR chemical residue check & drip irrigation fertigation balance verification.',
                farmGpsLat: -17.6521,
                farmGpsLng: 30.8412,
              ),
              const ConsultationSession(
                id: 'CONS-903',
                farmerName: 'Blessing Musona',
                farmName: 'Glendale Outgrower Block C',
                districtLocation: 'Glendale, Mashonaland Central',
                cropOrLivestock: 'Soybeans & Wheat',
                type: ConsultationType.inAppChat,
                scheduledDate: 'Yesterday',
                scheduledTimeSlot: '11:00 AM',
                feeUsd: 30.00,
                status: ConsultationStatus.completed,
                summaryNotes: 'Prescribed Bio-Nemacur soil drench for nematode containment. e-Prescription #RX-2026-9081 issued.',
                prescriptionId: 'RX-2026-9081',
                farmGpsLat: -17.3812,
                farmGpsLng: 31.0894,
              ),
            ],
            diagnosticCases: [
              const DiagnosticCase(
                id: 'DIAG-401',
                farmerName: 'Farai Mutasa',
                farmName: 'Chinhoyi River Basin Farm',
                crop: 'White Maize (SeedCo 727)',
                symptomDescription: 'Windowing of upper whorl leaves and frass deposit inside stem nodes.',
                detectedAnomaly: 'Fall Armyworm (Spodoptera frugiperda) Stage 3 Larvae',
                aiConfidenceScore: 0.96,
                severity: 'Critical',
                soilPh: 5.8,
                nitrogenPpm: 28.0,
                phosphorusPpm: 12.0,
                potassiumPpm: 125.0,
                status: 'Diagnosed',
                timestamp: '2 hours ago',
                linkedPrescription: DigitalPrescription(
                  id: 'RX-2026-9082',
                  prescriptionNumber: 'RX-ZIM-2026-9082',
                  farmName: 'Chinhoyi River Basin Farm',
                  farmerName: 'Farai Mutasa',
                  crop: 'White Maize',
                  diagnosedCondition: 'Fall Armyworm Infestation (Economic Threshold Exceeded)',
                  items: [
                    PrescriptionInputItem(
                      inputName: 'Coragen 200 SC (Chlorantraniliprole)',
                      category: 'Bio-Selective Insecticide',
                      dosagePerHectare: '150 ml / ha in 200L water',
                      applicationMethod: 'Targeted Whorl Knapsack Direct Spray',
                      phiSafetyDays: '14 Days Pre-Harvest',
                      warehouseSku: 'WH-INS-CORA-200',
                      safetyWarning: 'Wear nitrile gloves; spray early morning (06:00-08:30) or late afternoon.',
                    ),
                    PrescriptionInputItem(
                      inputName: 'Soluble Ammonium Nitrate (AN 34.5% N)',
                      category: 'Fast-Release Nitrogen Topdressing',
                      dosagePerHectare: '150 kg / ha',
                      applicationMethod: 'Side-Dress Banding along plant line',
                      phiSafetyDays: 'Immediate',
                      warehouseSku: 'WH-FERT-AN-50KG',
                      safetyWarning: 'Apply when soil is moist; avoid direct contact with maize foliage.',
                    ),
                  ],
                  soilPhRecommendation: 'Soil pH 5.8 is slightly acidic. Apply 1.0 Tonne/ha Calcitic Lime after harvest.',
                  npkPrescription: 'Basal Compound D (7:14:7) 300kg/ha + Split AN Topdress (150kg/ha x 2)',
                  eudrComplianceNotice: 'Approved under EUDR Zero-Deforestation & Safe Chemical Register #EUDR-CHEM-2026-99',
                  issuingExpert: 'Dr. Nyasha Sibanda (Lead Agronomist)',
                  createdAt: '2026-08-24 13:00',
                ),
              ),
              const DiagnosticCase(
                id: 'DIAG-402',
                farmerName: 'Tendai Chikore',
                farmName: 'Goromonzi Berry & Macadamia Hub',
                crop: 'Blueberries (Eureka Variety)',
                symptomDescription: 'Interveinal yellowing of young leaves with burnt leaf tips.',
                detectedAnomaly: 'Iron & Zinc Induced Deficiency due to high Soil pH (6.9 in substrate)',
                aiConfidenceScore: 0.93,
                severity: 'Medium',
                soilPh: 6.9,
                nitrogenPpm: 35.0,
                phosphorusPpm: 24.0,
                potassiumPpm: 180.0,
                status: 'Prescription Issued',
                timestamp: 'Yesterday',
              ),
            ],
            prescriptions: [
              const DigitalPrescription(
                id: 'RX-2026-9082',
                prescriptionNumber: 'RX-ZIM-2026-9082',
                farmName: 'Chinhoyi River Basin Farm',
                farmerName: 'Farai Mutasa',
                crop: 'White Maize',
                diagnosedCondition: 'Fall Armyworm Infestation & N-Deficiency',
                items: [
                  PrescriptionInputItem(
                    inputName: 'Coragen 200 SC',
                    category: 'Selective Bio-Insecticide',
                    dosagePerHectare: '150 ml / ha',
                    applicationMethod: 'Direct Whorl Foliar Spray',
                    phiSafetyDays: '14 Days PHI',
                    warehouseSku: 'WH-INS-CORA-200',
                    safetyWarning: 'Store in cool locked chemical store.',
                  ),
                  PrescriptionInputItem(
                    inputName: 'Potassium Nitrate (KNO3) Foliar Booster',
                    category: 'Foliar Fertilizer',
                    dosagePerHectare: '4 kg / ha in 250L water',
                    applicationMethod: 'Boom Spray early morning',
                    phiSafetyDays: '3 Days PHI',
                    warehouseSku: 'WH-FERT-KNO3-25KG',
                    safetyWarning: 'Compatible with Coragen spray mix.',
                  ),
                ],
                soilPhRecommendation: 'Adjust basal zone with lime next cycle.',
                npkPrescription: 'Compound D @ 350kg/ha + AN @ 200kg/ha',
                eudrComplianceNotice: 'EUDR Chemical Code #EUDR-AGRI-ZIM-884',
                issuingExpert: 'Dr. Nyasha Sibanda (ZAPB-LIC-2014-049)',
                createdAt: '2026-08-24 13:00',
              ),
            ],
            articles: [
              const KnowledgeArticle(
                id: 'ART-101',
                title: 'Managing Fall Armyworm without Harming Beneficial Pollinators in Southern Africa',
                category: 'Pest & Disease Control',
                excerpt: 'Practical scout thresholds, biological controls, and precision chemistry timing for smallholders and commercial pivots.',
                fullContent: 'Fall Armyworm (Spodoptera frugiperda) requires early scouting at V2-V4 vegetative stage. Threshold: 5% infested plants in seed maize or 20% in commercial grain. Use bio-selective ryanoid receptor modulators (Chlorantraniliprole) instead of broad-spectrum pyrethroids to preserve predatory wasps and earwigs.',
                author: 'Dr. Nyasha Sibanda',
                readTimeMinutes: 6,
                downloadsCount: 382,
                likesCount: 94,
                publishedDate: '22 Aug 2026',
              ),
              const KnowledgeArticle(
                id: 'ART-102',
                title: 'Interpreting SADC Soil Tests: Correcting Low pH with Dolomitic vs Calcitic Lime',
                category: 'Soil Fertility & Nutrition',
                excerpt: 'Why high rainfall acidic soils in Mashonaland and Manicaland lead to phosphorus fixation, and how to balance Ca:Mg ratios.',
                fullContent: 'Soils below pH 5.5 suffer from aluminum toxicity and severely lock up applied phosphorus fertilizers. When magnesium levels are below 100 ppm, apply agricultural Dolomitic Lime. If magnesium is sufficient (>150 ppm), Calcitic Lime provides faster calcium availability.',
                author: 'Dr. Nyasha Sibanda',
                readTimeMinutes: 8,
                downloadsCount: 512,
                likesCount: 146,
                publishedDate: '15 Aug 2026',
              ),
            ],
            communityQnAs: [
              const CommunityQnA(
                id: 'QNA-501',
                farmerName: 'Simba Mhlanga (Bindura)',
                questionTitle: 'Can I mix Soluble Boron with Mancozeb spray on my tomato crop?',
                questionDetail: 'My tomatoes are at 50% flowering and showing signs of early blight, but I also need to apply boron for fruit set.',
                cropTag: 'Tomatoes',
                expertAnswer: 'Yes, Soluble Boron (e.g. Solubor @ 1.5g/L) is chemically compatible with standard Mancozeb 80WP in tank mixes. Maintain spray water pH between 5.5 and 6.5, and spray during early morning before 08:30 AM to avoid heat scorch.',
                expertName: 'Dr. Nyasha Sibanda',
                upvotes: 48,
                isVerifiedAnswer: true,
                date: '23 Aug 2026',
              ),
              const CommunityQnA(
                id: 'QNA-502',
                farmerName: 'Memory Chisvo (Marondera)',
                questionTitle: 'What is the safe Pre-Harvest Interval (PHI) for Abamectin on export paprika?',
                questionDetail: 'Red spider mites appeared 10 days before expected harvest. Is it safe to spray Abamectin for EU export?',
                cropTag: 'Paprika / EUDR',
                expertAnswer: 'Strict caution: Abamectin has a mandatory 14-day Pre-Harvest Interval (PHI) on capsicum crops intended for the European Union market. If you are 10 days out, use an organic potassium salt of fatty acids or predatory phytoseiid mites instead to prevent MRL rejection at EU port.',
                expertName: 'Dr. Nyasha Sibanda',
                upvotes: 62,
                isVerifiedAnswer: true,
                date: '20 Aug 2026',
              ),
            ],
            consultantClients: [
              const ConsultantClient(
                id: 'CLI-001',
                clientName: 'Mazowe Valley Commercial Estate',
                estateName: 'Section 4 Citrus & Soybean Pivots',
                hectarage: 280.0,
                primaryCrops: 'Valencia Oranges, Seed Maize, Soybeans',
                pricingTier: 'VIP Precision Agronomy Package',
                monthlyBillingUsd: 650.00,
                slaStatus: '24/7 Priority Emergency SLA',
                lastVisitDate: '18 Aug 2026',
              ),
              const ConsultantClient(
                id: 'CLI-002',
                clientName: 'Chinhoyi River Basin Outgrower Syndicate',
                estateName: 'Block 2 Smallholder Cluster',
                hectarage: 140.0,
                primaryCrops: 'White Maize (SC719), Groundnuts',
                pricingTier: 'Standard Monthly Retainer',
                monthlyBillingUsd: 350.00,
                slaStatus: '48h Routine Inspection SLA',
                lastVisitDate: '12 Aug 2026',
              ),
            ],
            extensionAlerts: [
              const ExtensionBroadcastAlert(
                id: 'ALR-801',
                title: 'EMERGENCY: Fall Armyworm Cluster Detected in Ward 4 & 5',
                targetWardDistrict: 'Mazowe District (Wards 4, 5, 7)',
                recipientFarmersCount: 1420,
                alertType: 'Pest Outbreak Alert',
                channel: 'SMS Broadcast & Shona Voice-Note',
                sentAt: '24 Aug 2026, 08:00 AM',
              ),
              const ExtensionBroadcastAlert(
                id: 'ALR-802',
                title: 'Presidential Input Scheme: Basal Compound D Collection Notice',
                targetWardDistrict: 'Goromonzi District North',
                recipientFarmersCount: 2150,
                alertType: 'Input Subsidy Distribution',
                channel: 'SMS Broadcast',
                sentAt: '21 Aug 2026, 10:30 AM',
              ),
            ],
            corporateTasks: [
              const CorporateTaskDispatch(
                id: 'CORP-301',
                outgrowerBlock: 'Delta Malting Barley Contract Block #12',
                farmerName: 'Munyaradzi Gumbo',
                targetCrop: 'Malting Barley (Puma Variety) - 45 Ha',
                issueReported: 'Stem rust symptoms appearing after heavy morning dews; target protein level control.',
                urgency: 'Critical (2h Response SLA)',
                inStockWarehouseSku: 'WH-FUNG-AZOXY-250 (Azoxystrobin In Stock: 840L)',
                status: 'Dispatched',
              ),
              const CorporateTaskDispatch(
                id: 'CORP-302',
                outgrowerBlock: 'SeedCo Foundation Seed Block #4',
                farmerName: 'Kundai Matarise',
                targetCrop: 'Foundation Seed Maize (Female Rows)',
                issueReported: 'Tassel emergence inspection & male row rouging verification before pollen shed.',
                urgency: 'High',
                inStockWarehouseSku: 'WH-TAG-ROUGE-EUDR',
                status: 'Inspected',
              ),
            ],
            offlineRecords: [
              const OfflineFieldRecord(
                id: 'REC-OFF-01',
                farmerNationalId: '63-891024-B-42',
                farmerName: 'Sekuru Phineas Chitate',
                wardNumber: 'Mazowe Ward 4 (Remote Scheme)',
                cropType: 'Sorghum (Macia Variety)',
                soilMoistureBand: 'Dry (12% VWC) - Needs Emergency Irrigation',
                observedPest: 'Early Aphid Honeydew spotting on lower leaves',
                notes: 'Advised farmer to apply neem extract foliar spray and irrigate 15mm overnight.',
                isSyncedToCloud: true,
                recordedAt: '23 Aug 2026 14:10',
              ),
              const OfflineFieldRecord(
                id: 'REC-OFF-02',
                farmerNationalId: '63-441209-A-18',
                farmerName: 'Amai Ruth Marufu',
                wardNumber: 'Mazowe Ward 7 (Dryland Section)',
                cropType: 'Groundnuts (Nyanda Variety)',
                soilMoistureBand: 'Moderate (22% VWC)',
                observedPest: 'Cercospora Leaf Spot (Low severity < 3%)',
                notes: 'Recorded in offline storage buffer. Will auto-sync when 4G connectivity restores.',
                isSyncedToCloud: false,
                recordedAt: 'Today 11:20 AM',
              ),
            ],
          ),
        );

  void switchPersona(ExpertPersona persona) {
    state = state.copyWith(
      activePersona: persona,
      profile: state.profile.copyWith(activePersona: persona),
    );
  }

  void addConsultation(ConsultationSession session) {
    state = state.copyWith(consultations: [session, ...state.consultations]);
  }

  void completeConsultation(String sessionId) {
    final updated = state.consultations.map((c) {
      if (c.id == sessionId) {
        return ConsultationSession(
          id: c.id,
          farmerName: c.farmerName,
          farmName: c.farmName,
          districtLocation: c.districtLocation,
          cropOrLivestock: c.cropOrLivestock,
          type: c.type,
          scheduledDate: c.scheduledDate,
          scheduledTimeSlot: c.scheduledTimeSlot,
          feeUsd: c.feeUsd,
          status: ConsultationStatus.completed,
          summaryNotes: 'Session successfully conducted and agronomic advice verified.',
          prescriptionId: c.prescriptionId,
          farmGpsLat: c.farmGpsLat,
          farmGpsLng: c.farmGpsLng,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      consultations: updated,
      profile: state.profile.copyWith(
        completedConsultations: state.profile.completedConsultations + 1,
        walletBalanceUsd: state.profile.walletBalanceUsd + 45.0,
      ),
    );
  }

  void issuePrescription(DigitalPrescription prescription) {
    state = state.copyWith(
      prescriptions: [prescription, ...state.prescriptions],
    );
  }

  void publishArticle(KnowledgeArticle article) {
    state = state.copyWith(articles: [article, ...state.articles]);
  }

  void answerCommunityQnA(String qnaId, String answer) {
    final updated = state.communityQnAs.map((q) {
      if (q.id == qnaId) {
        return CommunityQnA(
          id: q.id,
          farmerName: q.farmerName,
          questionTitle: q.questionTitle,
          questionDetail: q.questionDetail,
          cropTag: q.cropTag,
          expertAnswer: answer,
          expertName: state.profile.fullName,
          upvotes: q.upvotes + 1,
          isVerifiedAnswer: true,
          date: 'Just now',
        );
      }
      return q;
    }).toList();
    state = state.copyWith(communityQnAs: updated);
  }

  void saveOfflineRecord(OfflineFieldRecord record) {
    state = state.copyWith(
      offlineRecords: [record, ...state.offlineRecords],
    );
  }

  void syncAllOfflineRecords() {
    state = state.copyWith(isOfflineSyncing: true);
    Future.delayed(const Duration(seconds: 2), () {
      final synced = state.offlineRecords.map((r) {
        return OfflineFieldRecord(
          id: r.id,
          farmerNationalId: r.farmerNationalId,
          farmerName: r.farmerName,
          wardNumber: r.wardNumber,
          cropType: r.cropType,
          soilMoistureBand: r.soilMoistureBand,
          observedPest: r.observedPest,
          notes: r.notes,
          isSyncedToCloud: true,
          recordedAt: r.recordedAt,
        );
      }).toList();
      state = state.copyWith(
        offlineRecords: synced,
        isOfflineSyncing: false,
      );
    });
  }

  void broadcastGovernmentAlert(ExtensionBroadcastAlert alert) {
    state = state.copyWith(
      extensionAlerts: [alert, ...state.extensionAlerts],
    );
  }

  void updateCorporateTaskStatus(String taskId, String status) {
    final updated = state.corporateTasks.map((t) {
      if (t.id == taskId) {
        return CorporateTaskDispatch(
          id: t.id,
          outgrowerBlock: t.outgrowerBlock,
          farmerName: t.farmerName,
          targetCrop: t.targetCrop,
          issueReported: t.issueReported,
          urgency: t.urgency,
          inStockWarehouseSku: t.inStockWarehouseSku,
          status: status,
        );
      }
      return t;
    }).toList();
    state = state.copyWith(corporateTasks: updated);
  }

  void addConsultantClient(ConsultantClient client) {
    state = state.copyWith(
      consultantClients: [client, ...state.consultantClients],
    );
  }

  void updateRates({
    required double hourlyRate,
    required double farmVisitRate,
    required double monthlyRetainer,
  }) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        hourlyRateUsd: hourlyRate,
        farmVisitRateUsd: farmVisitRate,
        monthlyRetainerRateUsd: monthlyRetainer,
      ),
    );
  }
}

final agriExpertProvider = StateNotifierProvider<AgriExpertNotifier, AgriExpertState>((ref) {
  return AgriExpertNotifier();
});
