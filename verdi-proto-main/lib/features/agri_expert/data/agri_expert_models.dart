import 'package:flutter/material.dart';

/// The 3 distinct operating personas for Agri-Experts
enum ExpertPersona {
  independentConsultant, // 👤 The Business Model: Private agronomy consultants, soil labs, private billing
  governmentExtension,   // 🏛️ The Public Model: Agritex, district territorial extension, public M&E
  companyAgronomist;     // 🏢 The Corporate Model: SeedCo/Delta outgrower managers, warehouse input sync

  String get label {
    switch (this) {
      case ExpertPersona.independentConsultant:
        return 'Independent Consultant';
      case ExpertPersona.governmentExtension:
        return 'Government Extension Worker';
      case ExpertPersona.companyAgronomist:
        return 'Corporate Agronomist';
    }
  }

  String get badgeTitle {
    switch (this) {
      case ExpertPersona.independentConsultant:
        return 'PRIVATE ADVISORY';
      case ExpertPersona.governmentExtension:
        return 'AGRITEX (MINISTRY OF AGRI)';
      case ExpertPersona.companyAgronomist:
        return 'CORPORATE AGRI-ENTERPRISE';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpertPersona.independentConsultant:
        return Icons.business_center_outlined;
      case ExpertPersona.governmentExtension:
        return Icons.account_balance_outlined;
      case ExpertPersona.companyAgronomist:
        return Icons.domain_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ExpertPersona.independentConsultant:
        return const Color(0xFF10B981); // Emerald
      case ExpertPersona.governmentExtension:
        return const Color(0xFF3B82F6); // Blue
      case ExpertPersona.companyAgronomist:
        return const Color(0xFF8B5CF6); // Purple
    }
  }
}

/// Verification credentials and certifications
class ExpertCredential {
  final String title;
  final String institution;
  final String yearAwarded;
  final String credentialId;
  final bool isVerified;

  const ExpertCredential({
    required this.title,
    required this.institution,
    required this.yearAwarded,
    required this.credentialId,
    this.isVerified = true,
  });
}

/// Comprehensive Agri-Expert Profile
class AgriExpertProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String bio;
  final List<String> specializations;
  final List<ExpertCredential> credentials;
  final int yearsOfExperience;
  final double rating;
  final int reviewsCount;
  final double hourlyRateUsd;
  final double farmVisitRateUsd;
  final double monthlyRetainerRateUsd;
  final List<String> availabilityDays;
  final String operatingDistrict;
  final String companyAffiliation;
  final bool isVerifiedBadge;
  final bool isVerifiedByState; // 🏛️ Official Government accreditation seal
  final String agritexOfficerId;
  final ExpertPersona activePersona;
  final double walletBalanceUsd;
  final int completedConsultations;
  final double clientSatisfactionScore; // e.g. 98.4%

  const AgriExpertProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl = '',
    required this.bio,
    required this.specializations,
    required this.credentials,
    required this.yearsOfExperience,
    this.rating = 4.96,
    this.reviewsCount = 88,
    this.hourlyRateUsd = 45.00,
    this.farmVisitRateUsd = 120.00,
    this.monthlyRetainerRateUsd = 350.00,
    this.availabilityDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.operatingDistrict = 'Mashonaland West (Mazowe & Chinhoyi)',
    this.companyAffiliation = 'Sovereign Agronomy Group & SeedCo Alliance',
    this.isVerifiedBadge = true,
    this.isVerifiedByState = true,
    this.agritexOfficerId = 'AGX-ZW-9942',
    this.activePersona = ExpertPersona.independentConsultant,
    this.walletBalanceUsd = 2840.00,
    this.completedConsultations = 142,
    this.clientSatisfactionScore = 99.1,
  });

  AgriExpertProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    List<String>? specializations,
    List<ExpertCredential>? credentials,
    int? yearsOfExperience,
    double? rating,
    int? reviewsCount,
    double? hourlyRateUsd,
    double? farmVisitRateUsd,
    double? monthlyRetainerRateUsd,
    List<String>? availabilityDays,
    String? operatingDistrict,
    String? companyAffiliation,
    bool? isVerifiedBadge,
    bool? isVerifiedByState,
    String? agritexOfficerId,
    ExpertPersona? activePersona,
    double? walletBalanceUsd,
    int? completedConsultations,
    double? clientSatisfactionScore,
  }) {
    return AgriExpertProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      specializations: specializations ?? this.specializations,
      credentials: credentials ?? this.credentials,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      hourlyRateUsd: hourlyRateUsd ?? this.hourlyRateUsd,
      farmVisitRateUsd: farmVisitRateUsd ?? this.farmVisitRateUsd,
      monthlyRetainerRateUsd: monthlyRetainerRateUsd ?? this.monthlyRetainerRateUsd,
      availabilityDays: availabilityDays ?? this.availabilityDays,
      operatingDistrict: operatingDistrict ?? this.operatingDistrict,
      companyAffiliation: companyAffiliation ?? this.companyAffiliation,
      isVerifiedBadge: isVerifiedBadge ?? this.isVerifiedBadge,
      isVerifiedByState: isVerifiedByState ?? this.isVerifiedByState,
      agritexOfficerId: agritexOfficerId ?? this.agritexOfficerId,
      activePersona: activePersona ?? this.activePersona,
      walletBalanceUsd: walletBalanceUsd ?? this.walletBalanceUsd,
      completedConsultations: completedConsultations ?? this.completedConsultations,
      clientSatisfactionScore: clientSatisfactionScore ?? this.clientSatisfactionScore,
    );
  }
}

/// Advertised Advisory Service Listing (Marketed to farmers on Home & Directory)
class AdvisoryServiceListing {
  final String id;
  final String expertId;
  final String expertName;
  final ExpertPersona expertPersona;
  final String title;
  final String description;
  final String category; // Soil Science, Pest Control, Crop Nutrition, EUDR Inspection, Irrigation
  final double priceUsd;
  final String pricingUnit; // e.g. '/ sample', '/ hectare', '/ visit', '/ hour'
  final String deliveryMode; // Remote Tele-Agronomy, On-Site Field Visit
  final String locationDistrict;
  final double rating;
  final int reviewsCount;
  final bool isVerifiedByState;
  final String createdAt;

  const AdvisoryServiceListing({
    required this.id,
    required this.expertId,
    required this.expertName,
    required this.expertPersona,
    required this.title,
    required this.description,
    required this.category,
    required this.priceUsd,
    required this.pricingUnit,
    required this.deliveryMode,
    required this.locationDistrict,
    this.rating = 4.96,
    this.reviewsCount = 42,
    this.isVerifiedByState = true,
    required this.createdAt,
  });
}

/// Community Forum Post & Update
class CommunityComment {
  final String id;
  final String authorName;
  final String authorRoleTag;
  final bool isVerifiedExpert;
  final String content;
  final String timestamp;

  const CommunityComment({
    required this.id,
    required this.authorName,
    required this.authorRoleTag,
    this.isVerifiedExpert = false,
    required this.content,
    required this.timestamp,
  });
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorRoleTitle;
  final bool isExpert;
  final bool isVerifiedByState;
  final String cropCategory;
  final String districtLocation;
  final String title;
  final String content;
  final String? photoUrl;
  final int upvotes;
  final String timestamp;
  final List<CommunityComment> comments;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorRoleTitle,
    this.isExpert = true,
    this.isVerifiedByState = true,
    required this.cropCategory,
    required this.districtLocation,
    required this.title,
    required this.content,
    this.photoUrl,
    this.upvotes = 38,
    required this.timestamp,
    this.comments = const [],
  });
}

/// Formal Persona/Role Change Inquiry
class PersonaChangeInquiry {
  final String id;
  final String expertId;
  final String expertName;
  final ExpertPersona currentPersona;
  final ExpertPersona requestedPersona;
  final String justification;
  final String accreditationRef;
  final String status; // Pending Verification, Approved, Under Review
  final String submittedAt;

  const PersonaChangeInquiry({
    required this.id,
    required this.expertId,
    required this.expertName,
    required this.currentPersona,
    required this.requestedPersona,
    required this.justification,
    required this.accreditationRef,
    this.status = 'Pending Verification',
    required this.submittedAt,
  });
}

/// Consultation Booking and Field Visit
enum ConsultationType {
  inAppChat,
  videoCall,
  voiceCall,
  physicalFarmVisit;

  String get label {
    switch (this) {
      case ConsultationType.inAppChat:
        return 'Live In-App Chat';
      case ConsultationType.videoCall:
        return 'Remote Video Tele-Agronomy';
      case ConsultationType.voiceCall:
        return 'Voice Phone Consult';
      case ConsultationType.physicalFarmVisit:
        return 'GPS Physical Farm Visit';
    }
  }

  IconData get icon {
    switch (this) {
      case ConsultationType.inAppChat:
        return Icons.chat_bubble_outline;
      case ConsultationType.videoCall:
        return Icons.videocam_outlined;
      case ConsultationType.voiceCall:
        return Icons.phone_in_talk_outlined;
      case ConsultationType.physicalFarmVisit:
        return Icons.location_on_outlined;
    }
  }
}

enum ConsultationStatus {
  scheduled,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case ConsultationStatus.scheduled:
        return 'Scheduled';
      case ConsultationStatus.inProgress:
        return 'In Session';
      case ConsultationStatus.completed:
        return 'Completed & Signed';
      case ConsultationStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case ConsultationStatus.scheduled:
        return const Color(0xFFF59E0B);
      case ConsultationStatus.inProgress:
        return const Color(0xFF3B82F6);
      case ConsultationStatus.completed:
        return const Color(0xFF10B981);
      case ConsultationStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }
}

class ConsultationSession {
  final String id;
  final String farmerName;
  final String farmName;
  final String districtLocation;
  final String cropOrLivestock;
  final ConsultationType type;
  final String scheduledDate;
  final String scheduledTimeSlot;
  final double feeUsd;
  final ConsultationStatus status;
  final String summaryNotes;
  final String? prescriptionId;
  final double farmGpsLat;
  final double farmGpsLng;

  const ConsultationSession({
    required this.id,
    required this.farmerName,
    required this.farmName,
    required this.districtLocation,
    required this.cropOrLivestock,
    required this.type,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.feeUsd,
    this.status = ConsultationStatus.scheduled,
    this.summaryNotes = '',
    this.prescriptionId,
    this.farmGpsLat = -17.5120,
    this.farmGpsLng = 31.0210,
  });
}

/// Digital Prescription Input Item
class PrescriptionInputItem {
  final String inputName;
  final String category;
  final String dosagePerHectare;
  final String applicationMethod;
  final String phiSafetyDays;
  final String? warehouseSku;
  final String safetyWarning;

  const PrescriptionInputItem({
    required this.inputName,
    required this.category,
    required this.dosagePerHectare,
    required this.applicationMethod,
    required this.phiSafetyDays,
    this.warehouseSku,
    required this.safetyWarning,
  });
}

/// Digital Agronomy Prescription
class DigitalPrescription {
  final String id;
  final String prescriptionNumber;
  final String farmName;
  final String farmerName;
  final String crop;
  final String diagnosedCondition;
  final List<PrescriptionInputItem> items;
  final String soilPhRecommendation;
  final String npkPrescription;
  final String eudrComplianceNotice;
  final String issuingExpert;
  final String createdAt;
  final bool isExportWhitelabelReady;
  final double? gpsLat;
  final double? gpsLng;

  const DigitalPrescription({
    required this.id,
    required this.prescriptionNumber,
    required this.farmName,
    required this.farmerName,
    required this.crop,
    required this.diagnosedCondition,
    required this.items,
    this.soilPhRecommendation = 'Target pH: 6.2 (Apply 1.5T Dolomitic Lime/ha)',
    this.npkPrescription = 'Compound D (7:14:7) @ 350kg/ha + Ammonium Nitrate Topdress @ 200kg/ha',
    this.eudrComplianceNotice = 'EUDR Verified Zero-Deforestation Input Compliance #EUDR-AGRI-2026',
    required this.issuingExpert,
    required this.createdAt,
    this.isExportWhitelabelReady = true,
    this.gpsLat,
    this.gpsLng,
  });
}

/// Diagnostic Anomaly Case linked to Geospatial
class DiagnosticCase {
  final String id;
  final String farmerName;
  final String farmName;
  final String crop;
  final String symptomDescription;
  final String detectedAnomaly;
  final double aiConfidenceScore; // e.g. 0.94 (94%)
  final String severity; // High, Medium, Low
  final double soilPh;
  final double nitrogenPpm;
  final double phosphorusPpm;
  final double potassiumPpm;
  final String status; // Pending Review, Diagnosed, Prescription Issued
  final String timestamp;
  final DigitalPrescription? linkedPrescription;
  final double gpsLat;
  final double gpsLng;
  final String district;

  const DiagnosticCase({
    required this.id,
    required this.farmerName,
    required this.farmName,
    required this.crop,
    required this.symptomDescription,
    required this.detectedAnomaly,
    required this.aiConfidenceScore,
    this.severity = 'High',
    this.soilPh = 5.6,
    this.nitrogenPpm = 22.0,
    this.phosphorusPpm = 14.0,
    this.potassiumPpm = 110.0,
    this.status = 'Diagnosed',
    required this.timestamp,
    this.linkedPrescription,
    this.gpsLat = -17.5120,
    this.gpsLng = 31.0210,
    this.district = 'Mazowe Ward 4',
  });
}

/// Knowledge Base Article & Guide
class KnowledgeArticle {
  final String id;
  final String title;
  final String category;
  final String excerpt;
  final String fullContent;
  final String author;
  final int readTimeMinutes;
  final int downloadsCount;
  final int likesCount;
  final String publishedDate;

  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.excerpt,
    required this.fullContent,
    required this.author,
    this.readTimeMinutes = 5,
    this.downloadsCount = 140,
    this.likesCount = 52,
    required this.publishedDate,
  });
}

/// Community Q&A Item
class CommunityQnA {
  final String id;
  final String farmerName;
  final String questionTitle;
  final String questionDetail;
  final String cropTag;
  final String expertAnswer;
  final String expertName;
  final int upvotes;
  final bool isVerifiedAnswer;
  final String date;

  const CommunityQnA({
    required this.id,
    required this.farmerName,
    required this.questionTitle,
    required this.questionDetail,
    required this.cropTag,
    required this.expertAnswer,
    required this.expertName,
    this.upvotes = 34,
    this.isVerifiedAnswer = true,
    required this.date,
  });
}

/// 👤 Independent Consultant CRM Client
class ConsultantClient {
  final String id;
  final String clientName;
  final String estateName;
  final double hectarage;
  final String primaryCrops;
  final String pricingTier; // Standard Retainer, VIP Precision Package, Per-Visit
  final double monthlyBillingUsd;
  final String slaStatus; // Active 24/7 SLA, Standard 48h Response
  final String lastVisitDate;

  const ConsultantClient({
    required this.id,
    required this.clientName,
    required this.estateName,
    required this.hectarage,
    required this.primaryCrops,
    required this.pricingTier,
    required this.monthlyBillingUsd,
    required this.slaStatus,
    required this.lastVisitDate,
  });
}

/// 🏛️ Government Extension Territory & M&E Alert
class ExtensionBroadcastAlert {
  final String id;
  final String title;
  final String targetWardDistrict;
  final int recipientFarmersCount;
  final String alertType; // Pest Outbreak, Frost Warning, Subsidy Fertilizer Distribution
  final String channel; // SMS Broadcast & Voice-Note
  final String sentAt;

  const ExtensionBroadcastAlert({
    required this.id,
    required this.title,
    required this.targetWardDistrict,
    required this.recipientFarmersCount,
    required this.alertType,
    required this.channel,
    required this.sentAt,
  });
}

/// 🏢 Corporate Agronomist Task & Outgrower Dispatch
class CorporateTaskDispatch {
  final String id;
  final String outgrowerBlock;
  final String farmerName;
  final String targetCrop;
  final String issueReported;
  final String urgency; // Critical (2h SLA), High, Routine
  final String inStockWarehouseSku;
  final String status; // Dispatched, Inspected, Input Delivered

  const CorporateTaskDispatch({
    required this.id,
    required this.outgrowerBlock,
    required this.farmerName,
    required this.targetCrop,
    required this.issueReported,
    this.urgency = 'High',
    required this.inStockWarehouseSku,
    this.status = 'Dispatched',
  });
}

/// 📱 Offline Rural Field Inspection Record
class OfflineFieldRecord {
  final String id;
  final String farmerNationalId;
  final String farmerName;
  final String wardNumber;
  final String cropType;
  final String soilMoistureBand;
  final String observedPest;
  final String notes;
  final bool isSyncedToCloud;
  final String recordedAt;

  const OfflineFieldRecord({
    required this.id,
    required this.farmerNationalId,
    required this.farmerName,
    required this.wardNumber,
    required this.cropType,
    required this.soilMoistureBand,
    required this.observedPest,
    required this.notes,
    this.isSyncedToCloud = false,
    required this.recordedAt,
  });
}
