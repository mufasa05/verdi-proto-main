import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/agri_expert_models.dart';
import '../../../state/app_state.dart';

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
  final List<AdvisoryServiceListing> serviceListings;
  final List<CommunityPost> communityPosts;
  final List<PersonaChangeInquiry> changeInquiries;
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
    required this.serviceListings,
    required this.communityPosts,
    required this.changeInquiries,
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
    List<AdvisoryServiceListing>? serviceListings,
    List<CommunityPost>? communityPosts,
    List<PersonaChangeInquiry>? changeInquiries,
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
      serviceListings: serviceListings ?? this.serviceListings,
      communityPosts: communityPosts ?? this.communityPosts,
      changeInquiries: changeInquiries ?? this.changeInquiries,
      isOfflineSyncing: isOfflineSyncing ?? this.isOfflineSyncing,
    );
  }
}

class AgriExpertNotifier extends StateNotifier<AgriExpertState> {
  final Ref ref;

  AgriExpertNotifier(this.ref) : super(_createInitialState(ref.read(isDemoModeProvider), ref.read(appStateProvider).expertPersona));

  static AgriExpertState _createInitialState(bool isDemo, ExpertPersona persona) {
    if (!isDemo) {
      // 🌟 Clean Live Zero-State Buffer
      return AgriExpertState(
        profile: AgriExpertProfile(
          id: 'EXP-LIVE-${DateTime.now().millisecondsSinceEpoch % 1000}',
          fullName: 'Dr. Nyasha Sibanda (Agronomist)',
          email: 'agronomist@verdi.co',
          phone: '+263 77 412 9081',
          bio: 'Registered agricultural specialist. Provide advisory, diagnostics, and field inspections on the VERDI platform.',
          specializations: [
            'Soil Fertility & Crop Nutrition',
            'Integrated Pest Management',
            'EUDR Compliance Verification',
          ],
          credentials: const [
            ExpertCredential(
              title: 'ZAPB Certified Agronomist License',
              institution: 'Zimbabwe Agricultural Professional Board',
              yearAwarded: '2022',
              credentialId: 'ZAPB-LIC-2022-88',
            ),
          ],
          yearsOfExperience: 8,
          rating: 5.0,
          reviewsCount: 0,
          hourlyRateUsd: 45.0,
          farmVisitRateUsd: 120.0,
          monthlyRetainerRateUsd: 350.0,
          operatingDistrict: 'Harare & Mashonaland Province',
          activePersona: persona,
          isVerifiedByState: persona == ExpertPersona.governmentExtension,
          walletBalanceUsd: 0.0,
          completedConsultations: 0,
          clientSatisfactionScore: 100.0,
        ),
        activePersona: persona,
        consultations: [],
        diagnosticCases: [],
        prescriptions: [],
        articles: [],
        communityQnAs: [],
        consultantClients: [],
        extensionAlerts: [],
        corporateTasks: [],
        offlineRecords: [],
        serviceListings: [
          AdvisoryServiceListing(
            id: 'SRV-01',
            expertId: 'EXP-LIVE-01',
            expertName: 'Dr. Nyasha Sibanda',
            expertPersona: persona,
            title: 'Complete Soil Lab Assay & Fertilizer Prescription',
            description: 'Comprehensive N-P-K, pH, and Micronutrient testing with customized lime and basal blend formula.',
            category: 'Soil Science & Nutrition',
            priceUsd: 35.0,
            pricingUnit: '/ sample',
            deliveryMode: 'On-Site Field Visit',
            locationDistrict: 'Mashonaland & Harare',
            isVerifiedByState: persona == ExpertPersona.governmentExtension,
            createdAt: 'Today',
          ),
        ],
        communityPosts: [
          const CommunityPost(
            id: 'POST-01',
            authorName: 'Dr. Nyasha Sibanda',
            authorRoleTitle: 'Agronomy Specialist',
            cropCategory: 'Maize & Cereals',
            districtLocation: 'Mashonaland West',
            title: 'Early Season Scouting Advisory for Fall Armyworm',
            content: 'Please inspect the central whorl of young maize plants at the V2 to V4 leaf stage. Look for translucent leaf windowing and green frass.',
            timestamp: '2 hours ago',
          ),
        ],
        changeInquiries: [],
      );
    }

    // 🧪 Rich Demo Simulator State
    return AgriExpertState(
      profile: AgriExpertProfile(
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
        credentials: const [
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
        activePersona: persona,
        isVerifiedByState: true,
        agritexOfficerId: 'AGX-ZW-9942',
        walletBalanceUsd: 3450.00,
        completedConsultations: 158,
        clientSatisfactionScore: 99.2,
      ),
      activePersona: persona,
      consultations: const [
        ConsultationSession(
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
        ConsultationSession(
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
      ],
      diagnosticCases: const [
        DiagnosticCase(
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
          district: 'Chinhoyi Ward 2',
          gpsLat: -17.3621,
          gpsLng: 30.1984,
          linkedPrescription: DigitalPrescription(
            id: 'RX-2026-9082',
            prescriptionNumber: 'RX-ZIM-2026-9082',
            farmName: 'Chinhoyi River Basin Farm',
            farmerName: 'Farai Mutasa',
            crop: 'White Maize',
            diagnosedCondition: 'Fall Armyworm Infestation',
            items: [
              PrescriptionInputItem(
                inputName: 'Coragen 200 SC',
                category: 'Bio-Selective Insecticide',
                dosagePerHectare: '150 ml / ha in 200L water',
                applicationMethod: 'Targeted Whorl Knapsack Direct Spray',
                phiSafetyDays: '14 Days Pre-Harvest',
                warehouseSku: 'WH-INS-CORA-200',
                safetyWarning: 'Wear nitrile gloves; spray early morning.',
              ),
            ],
            issuingExpert: 'Dr. Nyasha Sibanda',
            createdAt: '2026-08-24',
          ),
        ),
      ],
      prescriptions: const [
        DigitalPrescription(
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
          ],
          issuingExpert: 'Dr. Nyasha Sibanda (ZAPB-LIC-2014-049)',
          createdAt: '2026-08-24',
        ),
      ],
      articles: const [
        KnowledgeArticle(
          id: 'ART-101',
          title: 'Managing Fall Armyworm without Harming Beneficial Pollinators in Southern Africa',
          category: 'Pest & Disease Control',
          excerpt: 'Practical scout thresholds, biological controls, and precision chemistry timing for smallholders and commercial pivots.',
          fullContent: 'Fall Armyworm (Spodoptera frugiperda) requires early scouting at V2-V4 vegetative stage. Threshold: 5% infested plants in seed maize or 20% in commercial grain.',
          author: 'Dr. Nyasha Sibanda',
          readTimeMinutes: 6,
          downloadsCount: 382,
          likesCount: 94,
          publishedDate: '22 Aug 2026',
        ),
      ],
      communityQnAs: const [
        CommunityQnA(
          id: 'QNA-501',
          farmerName: 'Simba Mhlanga (Bindura)',
          questionTitle: 'Can I mix Soluble Boron with Mancozeb spray on my tomato crop?',
          questionDetail: 'My tomatoes are at 50% flowering and showing signs of early blight, but I also need to apply boron for fruit set.',
          cropTag: 'Tomatoes',
          expertAnswer: 'Yes, Soluble Boron (e.g. Solubor @ 1.5g/L) is chemically compatible with standard Mancozeb 80WP in tank mixes. Maintain spray water pH between 5.5 and 6.5.',
          expertName: 'Dr. Nyasha Sibanda',
          upvotes: 48,
          isVerifiedAnswer: true,
          date: '23 Aug 2026',
        ),
      ],
      consultantClients: const [
        ConsultantClient(
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
      ],
      extensionAlerts: const [
        ExtensionBroadcastAlert(
          id: 'ALR-801',
          title: 'EMERGENCY: Fall Armyworm Cluster Detected in Ward 4 & 5',
          targetWardDistrict: 'Mazowe District (Wards 4, 5, 7)',
          recipientFarmersCount: 1420,
          alertType: 'Pest Outbreak Alert',
          channel: 'SMS Broadcast & Shona Voice-Note',
          sentAt: '24 Aug 2026, 08:00 AM',
        ),
      ],
      corporateTasks: const [
        CorporateTaskDispatch(
          id: 'CORP-301',
          outgrowerBlock: 'Delta Malting Barley Contract Block #12',
          farmerName: 'Munyaradzi Gumbo',
          targetCrop: 'Malting Barley (Puma Variety) - 45 Ha',
          issueReported: 'Stem rust symptoms appearing after heavy morning dews; target protein level control.',
          urgency: 'Critical (2h Response SLA)',
          inStockWarehouseSku: 'WH-FUNG-AZOXY-250 (Azoxystrobin In Stock: 840L)',
          status: 'Dispatched',
        ),
      ],
      offlineRecords: const [
        OfflineFieldRecord(
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
      ],
      serviceListings: const [
        AdvisoryServiceListing(
          id: 'SRV-DEMO-01',
          expertId: 'EXP-ZIM-0994',
          expertName: 'Dr. Nyasha Sibanda',
          expertPersona: ExpertPersona.independentConsultant,
          title: 'Precision Soil Lab Assay & Custom Fertilizer Formula',
          description: 'Full soil chemistry profile (pH, N, P, K, Ca, Mg, CEC) with custom blending and dolomitic lime prescription.',
          category: 'Soil Science & Fertility',
          priceUsd: 35.0,
          pricingUnit: '/ sample',
          deliveryMode: 'On-Site Field Visit',
          locationDistrict: 'Mazowe & Harare',
          isVerifiedByState: true,
          rating: 4.98,
          reviewsCount: 64,
          createdAt: '22 Aug 2026',
        ),
        AdvisoryServiceListing(
          id: 'SRV-DEMO-02',
          expertId: 'EXP-ZIM-0994',
          expertName: 'Dr. Nyasha Sibanda',
          expertPersona: ExpertPersona.governmentExtension,
          title: 'Agritex Ward 4 Smallholder Pest Diagnostic Clinic',
          description: 'Free public extension inspection clinic for fall armyworm, stalk borer, and maize streak virus containment.',
          category: 'Pest & Disease Control',
          priceUsd: 0.0,
          pricingUnit: 'Free Extension Service',
          deliveryMode: 'On-Site Field Visit',
          locationDistrict: 'Mazowe Ward 4',
          isVerifiedByState: true,
          rating: 5.0,
          reviewsCount: 128,
          createdAt: '20 Aug 2026',
        ),
        AdvisoryServiceListing(
          id: 'SRV-DEMO-03',
          expertId: 'EXP-ZIM-0994',
          expertName: 'Dr. Nyasha Sibanda',
          expertPersona: ExpertPersona.independentConsultant,
          title: 'EUDR Export Zero-Deforestation Geolocation Audit',
          description: 'Comprehensive farm polygon mapping and satellite deforestation audit to certify crops for EU port customs.',
          category: 'EUDR & Export Compliance',
          priceUsd: 150.0,
          pricingUnit: '/ farm polygon',
          deliveryMode: 'GPS Physical Audit',
          locationDistrict: 'All Zimbabwe & SADC',
          isVerifiedByState: true,
          rating: 4.96,
          reviewsCount: 22,
          createdAt: '18 Aug 2026',
        ),
      ],
      communityPosts: const [
        CommunityPost(
          id: 'POST-01',
          authorName: 'Dr. Nyasha Sibanda',
          authorRoleTitle: 'Chief Agronomist (ZAPB-LIC-2014)',
          isExpert: true,
          isVerifiedByState: true,
          cropCategory: 'Maize & Cereals',
          districtLocation: 'Mazowe & Chinhoyi',
          title: '🚨 Urgent: Scout Maize Whorls for Fall Armyworm Stage 2 Larvae',
          content: 'We are observing significant egg clusters following the recent warm spell. If you find windowing on >5% of plants in seed maize or >15% in grain, apply Coragen 200SC or bio-insecticide Bacillus thuringiensis immediately before larvae burrow into stems.',
          upvotes: 72,
          timestamp: '3 hours ago',
          comments: [
            CommunityComment(
              id: 'COM-01',
              authorName: 'Tariro Hove (Nyabira Farmer)',
              authorRoleTag: 'Commercial Farmer',
              isVerifiedExpert: false,
              content: 'Thank you Doctor! We noticed this in Field 3 yesterday and applied targeted whorl drench today.',
              timestamp: '1 hour ago',
            ),
          ],
        ),
      ],
      changeInquiries: const [],
    );
  }

  void addServiceListing(AdvisoryServiceListing listing) {
    state = state.copyWith(serviceListings: [listing, ...state.serviceListings]);
  }

  void addCommunityPost(CommunityPost post) {
    state = state.copyWith(communityPosts: [post, ...state.communityPosts]);
  }

  void upvoteCommunityPost(String postId) {
    final updated = state.communityPosts.map((p) {
      if (p.id == postId) {
        return CommunityPost(
          id: p.id,
          authorName: p.authorName,
          authorRoleTitle: p.authorRoleTitle,
          isExpert: p.isExpert,
          isVerifiedByState: p.isVerifiedByState,
          cropCategory: p.cropCategory,
          districtLocation: p.districtLocation,
          title: p.title,
          content: p.content,
          photoUrl: p.photoUrl,
          upvotes: p.upvotes + 1,
          timestamp: p.timestamp,
          comments: p.comments,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(communityPosts: updated);
  }

  void addCommunityComment(String postId, CommunityComment comment) {
    final updated = state.communityPosts.map((p) {
      if (p.id == postId) {
        return CommunityPost(
          id: p.id,
          authorName: p.authorName,
          authorRoleTitle: p.authorRoleTitle,
          isExpert: p.isExpert,
          isVerifiedByState: p.isVerifiedByState,
          cropCategory: p.cropCategory,
          districtLocation: p.districtLocation,
          title: p.title,
          content: p.content,
          photoUrl: p.photoUrl,
          upvotes: p.upvotes,
          timestamp: p.timestamp,
          comments: [...p.comments, comment],
        );
      }
      return p;
    }).toList();
    state = state.copyWith(communityPosts: updated);
  }

  void submitPersonaChangeInquiry(PersonaChangeInquiry inquiry) {
    state = state.copyWith(changeInquiries: [inquiry, ...state.changeInquiries]);
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

  void updateProfile(AgriExpertProfile profile) {
    state = state.copyWith(profile: profile);
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
  return AgriExpertNotifier(ref);
});
