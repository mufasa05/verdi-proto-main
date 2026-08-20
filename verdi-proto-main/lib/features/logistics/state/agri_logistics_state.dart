import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/escrow_payment_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';
import '../data/agri_logistics_models.dart';

class AgriLogisticsState {
  final CarrierProfile carrierProfile;
  final List<MasterWaybill> activeWaybills;
  final List<ProduceBatch> availableFarmBatches;
  final List<TransportOrder> openMarketplaceOrders;
  final LogisticsTier activeViewTier;
  final bool isSimulatingTelemetry;
  final double liveSpeedKmh;
  final double liveReeferTemp;
  final String lastTelemetrySyncTime;

  const AgriLogisticsState({
    required this.carrierProfile,
    required this.activeWaybills,
    required this.availableFarmBatches,
    required this.openMarketplaceOrders,
    this.activeViewTier = LogisticsTier.longDistance,
    this.isSimulatingTelemetry = true,
    this.liveSpeedKmh = 72.4,
    this.liveReeferTemp = 3.4,
    required this.lastTelemetrySyncTime,
  });

  AgriLogisticsState copyWith({
    CarrierProfile? carrierProfile,
    List<MasterWaybill>? activeWaybills,
    List<ProduceBatch>? availableFarmBatches,
    List<TransportOrder>? openMarketplaceOrders,
    LogisticsTier? activeViewTier,
    bool? isSimulatingTelemetry,
    double? liveSpeedKmh,
    double? liveReeferTemp,
    String? lastTelemetrySyncTime,
  }) {
    return AgriLogisticsState(
      carrierProfile: carrierProfile ?? this.carrierProfile,
      activeWaybills: activeWaybills ?? this.activeWaybills,
      availableFarmBatches: availableFarmBatches ?? this.availableFarmBatches,
      openMarketplaceOrders: openMarketplaceOrders ?? this.openMarketplaceOrders,
      activeViewTier: activeViewTier ?? this.activeViewTier,
      isSimulatingTelemetry: isSimulatingTelemetry ?? this.isSimulatingTelemetry,
      liveSpeedKmh: liveSpeedKmh ?? this.liveSpeedKmh,
      liveReeferTemp: liveReeferTemp ?? this.liveReeferTemp,
      lastTelemetrySyncTime: lastTelemetrySyncTime ?? this.lastTelemetrySyncTime,
    );
  }
}

class AgriLogisticsNotifier extends StateNotifier<AgriLogisticsState> {
  Timer? _telemetryTimer;

  AgriLogisticsNotifier()
      : super(
          AgriLogisticsState(
            carrierProfile: CarrierProfile(
              id: 'CAR-ZIM-0881',
              carrierName: 'Chinhoyi Express Heavy Haul & Reefer',
              phone: '+263 77 902 1140',
              email: 'dispatch@chinhoyitrucks.co.zw',
              operatingTier: LogisticsTier.longDistance,
              vehicle: const AgriVehicle(
                id: 'VEH-9921',
                ownerId: 'CAR-ZIM-0881',
                registrationNumber: 'AEB-2910',
                type: VehicleType.reeferContainer,
                tierCapability: LogisticsTier.longDistance,
                maxWeightCapacityKg: 30000.0,
                hasColdChain: true,
                model: 'Volvo FH16 Reefer 30T',
                color: 'Midnight Blue',
              ),
              isVerifiedBadge: true,
              completedTripsCount: 28,
              rating: 4.98,
              dutyStatus: CarrierDutyStatus.available,
              walletBalance: 4250.00,
              eudrPermitCode: 'EUDR-LOG-ZIM-2026-88',
            ),
            activeWaybills: _initialWaybills,
            availableFarmBatches: _initialFarmBatches,
            openMarketplaceOrders: _initialMarketplaceOrders,
            lastTelemetrySyncTime: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} CAT',
          ),
        ) {
    _startTelemetryLoop();
  }

  void _startTelemetryLoop() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (state.isSimulatingTelemetry) {
        final now = DateTime.now();
        final jitterSpeed = 70.0 + (now.second % 9) * 0.8;
        final jitterTemp = 3.2 + (now.second % 6) * 0.1;
        state = state.copyWith(
          liveSpeedKmh: jitterSpeed,
          liveReeferTemp: jitterTemp,
          lastTelemetrySyncTime: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} CAT',
        );
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  void setDutyStatus(CarrierDutyStatus newStatus) {
    final updatedProfile = state.carrierProfile..dutyStatus = newStatus;
    state = state.copyWith(carrierProfile: updatedProfile);

    // Broadcast presence update
    SupabaseService.instance.broadcastUserPresence(
      userId: state.carrierProfile.id,
      fullName: state.carrierProfile.carrierName,
      role: UserRole.transporter,
      isOnline: newStatus != CarrierDutyStatus.offDuty,
    );
  }

  void setViewTier(LogisticsTier tier) {
    state = state.copyWith(activeViewTier: tier);
  }

  void toggleTelemetrySimulation(bool enabled) {
    state = state.copyWith(isSimulatingTelemetry: enabled);
  }

  void updateCarrierProfile(CarrierProfile profile) {
    state = state.copyWith(carrierProfile: profile);
  }

  void awardVerifiedBadge(bool isAwarded) {
    final updated = state.carrierProfile..isVerifiedBadge = isAwarded;
    state = state.copyWith(carrierProfile: updated);
  }

  // Accept a Marketplace Transport Order and generate a Master Waybill
  void acceptTransportOrder(TransportOrder order) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} CAT';
    final wbNumber = 'WB-AG-${now.year}-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

    final newWaybill = MasterWaybill(
      id: 'WB_${now.millisecondsSinceEpoch}',
      waybillNumber: wbNumber,
      transportOrderId: order.id,
      vehicleId: state.carrierProfile.vehicle.id,
      vehiclePlate: state.carrierProfile.vehicle.registrationNumber,
      driverId: state.carrierProfile.id,
      driverName: state.carrierProfile.carrierName,
      status: ShipmentStatus.inTransit,
      requiredTempMin: order.tier == LogisticsTier.longDistance ? 2.0 : null,
      requiredTempMax: order.tier == LogisticsTier.longDistance ? 6.0 : null,
      currentTemp: order.tier == LogisticsTier.longDistance ? 3.4 : null,
      estimatedDeliveryTime: 'Today at 18:30 CAT',
      origin: order.originAddress,
      destination: order.destinationAddress,
      totalFreightFee: order.quotedPrice,
      items: [
        WaybillItem(
          id: 'WBI_${now.millisecondsSinceEpoch}',
          waybillId: 'WB_${now.millisecondsSinceEpoch}',
          produceBatchId: 'BATCH-LIVE-01',
          farmerName: 'Kudakwashe Moyo (Mufasa Estate)',
          cropVariety: order.commodity,
          loadedWeightKg: order.totalWeightKg,
          qualityGradeAtLoading: 'Grade A Export',
          moistureAtLoading: 12.8,
          qrCode: 'QR-BATCH-2026-${order.id}',
        ),
      ],
      isVerifiedCarrier: state.carrierProfile.qualifiesForVerifiedBadge,
    );

    final updatedWaybills = [newWaybill, ...state.activeWaybills];
    final updatedOrders = state.openMarketplaceOrders.where((o) => o.id != order.id).toList();

    state = state.copyWith(
      activeWaybills: updatedWaybills,
      openMarketplaceOrders: updatedOrders,
    );

    // Broadcast live event
    SupabaseService.instance.broadcastActivityEvent(
      PlatformActivityEvent(
        id: 'ACT_LOG_${now.millisecondsSinceEpoch}',
        userName: state.carrierProfile.carrierName,
        userId: state.carrierProfile.id,
        userRole: UserRole.transporter,
        userAvatar: 'CE',
        actionTitle: '🚛 Freight Haul Accepted & Waybill Generated',
        actionDescription: 'Accepted ${order.commodity} haul ($wbNumber) from ${order.originAddress} to ${order.destinationAddress}.',
        module: 'Logistics',
        targetResource: wbNumber,
        timestamp: timeStr,
        exactTime: '${now.day} Aug ${now.year} $timeStr',
        ipAddress: 'In-Cab IoT Gateway (AEB-2910)',
        device: 'Verdi Carrier Terminal',
        status: 'Success',
        metadata: {
          'waybill': wbNumber,
          'freightFee': 'US\$ ${order.quotedPrice.toStringAsFixed(2)}',
          'tier': order.tier.label,
        },
      ),
    );
  }

  // Aggregate farmer produce batches onto a waybill
  void aggregateBatchToWaybill(String waybillId, ProduceBatch batch, double weightKg) {
    final now = DateTime.now();
    final updatedWaybills = state.activeWaybills.map((wb) {
      if (wb.id == waybillId) {
        final newItem = WaybillItem(
          id: 'WBI_${now.millisecondsSinceEpoch}',
          waybillId: waybillId,
          produceBatchId: batch.id,
          farmerName: batch.farmerName,
          cropVariety: batch.cropVariety,
          loadedWeightKg: weightKg,
          qualityGradeAtLoading: 'Grade A Verified',
          moistureAtLoading: batch.initialMoisturePercentage,
          qrCode: batch.qrCodeUid,
        );
        wb.items.add(newItem);
      }
      return wb;
    }).toList();

    state = state.copyWith(activeWaybills: updatedWaybills);
  }

  // Discharge Dock Inspection & e-POD Electronic Signature ➔ Automatic Escrow Release
  Future<void> submitDischargeInspectionAndSettle({
    required MasterWaybill waybill,
    required double receivedWeightKg,
    required String receivedGrade,
    required double receivedMoisturePercentage,
    required double spoilageLossKg,
    required String inspectorName,
    required String signatureData,
  }) async {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} CAT';

    final dischargeLog = DischargeQualityLog(
      id: 'DIS_${now.millisecondsSinceEpoch}',
      waybillItemId: waybill.items.isNotEmpty ? waybill.items.first.id : 'WBI_01',
      receivedWeightKg: receivedWeightKg,
      receivedGrade: receivedGrade,
      receivedMoisturePercentage: receivedMoisturePercentage,
      spoilageLossKg: spoilageLossKg,
      inspectorName: inspectorName,
      inspectorSignatureUrl: 'verified://e-signature/$signatureData',
      loggedAt: '${now.day} Aug ${now.year} $timeStr',
      notes: 'Discharge quality verified. Spoilage loss: $spoilageLossKg kg.',
    );

    final updatedWaybills = state.activeWaybills.map((wb) {
      if (wb.id == waybill.id) {
        wb.status = ShipmentStatus.delivered;
        wb.actualDeliveryTime = timeStr;
        wb.dischargeLog = dischargeLog;
      }
      return wb;
    }).toList();

    // Increment carrier trips and wallet balance
    final updatedProfile = state.carrierProfile
      ..completedTripsCount += 1
      ..walletBalance += waybill.totalFreightFee;

    state = state.copyWith(
      activeWaybills: updatedWaybills,
      carrierProfile: updatedProfile,
    );

    // FinTech Switch: Trigger automated escrow payout to transporter and farmer wallets
    await EscrowPaymentService.instance.payoutEscrow(
      orderId: waybill.transportOrderId,
      recipientWallet: state.carrierProfile.carrierName,
      amount: waybill.totalFreightFee,
    );

    // Broadcast e-POD Settlement event
    SupabaseService.instance.broadcastActivityEvent(
      PlatformActivityEvent(
        id: 'ACT_EPOD_${now.millisecondsSinceEpoch}',
        userName: state.carrierProfile.carrierName,
        userId: state.carrierProfile.id,
        userRole: UserRole.transporter,
        userAvatar: 'CE',
        actionTitle: '📝 Electronic Proof of Delivery (e-POD) & Escrow Settled',
        actionDescription: 'Cargo discharged at ${waybill.destination}. Escrow payout of US\$ ${waybill.totalFreightFee.toStringAsFixed(2)} released.',
        module: 'Escrow & Payments',
        targetResource: waybill.waybillNumber,
        timestamp: timeStr,
        exactTime: '${now.day} Aug ${now.year} $timeStr',
        ipAddress: 'Dock Scanner (Harare Processing Hub)',
        device: 'Verdi e-POD Signer',
        status: 'Success',
        metadata: {
          'waybill': waybill.waybillNumber,
          'payout': 'US\$ ${waybill.totalFreightFee.toStringAsFixed(2)}',
          'inspector': inspectorName,
        },
      ),
    );
  }
}

final agriLogisticsProvider = StateNotifierProvider<AgriLogisticsNotifier, AgriLogisticsState>((ref) {
  return AgriLogisticsNotifier();
});

// Initial demo datasets
final List<MasterWaybill> _initialWaybills = [
  MasterWaybill(
    id: 'WB_1001',
    waybillNumber: 'WB-AG-2026-9081',
    transportOrderId: 'ORD-8821',
    vehicleId: 'VEH-9921',
    vehiclePlate: 'AEB-2910 (30T Reefer)',
    driverId: 'CAR-ZIM-0881',
    driverName: 'Chinhoyi Express (Tafadzwa M.)',
    status: ShipmentStatus.inTransit,
    requiredTempMin: 2.0,
    requiredTempMax: 6.0,
    currentTemp: 3.4,
    estimatedDeliveryTime: 'Today at 16:45 CAT',
    origin: 'Mufasa Estate, Chiredzi',
    destination: 'Mbare Wholesale Central Hub, Harare',
    totalFreightFee: 480.00,
    items: [
      const WaybillItem(
        id: 'WBI-01',
        waybillId: 'WB_1001',
        produceBatchId: 'BATCH-SB-01',
        farmerName: 'Kudakwashe Moyo',
        cropVariety: 'Grade-A Sugar Beans',
        loadedWeightKg: 8500.0,
        qualityGradeAtLoading: 'Grade A',
        moistureAtLoading: 12.5,
        qrCode: 'QR-VER-SB-2026',
      ),
      const WaybillItem(
        id: 'WBI-02',
        waybillId: 'WB_1001',
        produceBatchId: 'BATCH-POT-02',
        farmerName: 'Tendai Mutasa',
        cropVariety: 'Export Potatoes (BP1)',
        loadedWeightKg: 12000.0,
        qualityGradeAtLoading: 'Grade A Export',
        moistureAtLoading: 14.1,
        qrCode: 'QR-VER-POT-884',
      ),
    ],
    isVerifiedCarrier: true,
  ),
  MasterWaybill(
    id: 'WB_1002',
    waybillNumber: 'WB-AG-2026-8840',
    transportOrderId: 'ORD-7712',
    vehicleId: 'VEH-4410',
    vehiclePlate: 'AFG-8812 (Tricycle)',
    driverId: 'CAR-LOC-002',
    driverName: 'Harare Aggregation Pool (Moses K.)',
    status: ShipmentStatus.pendingPickup,
    estimatedDeliveryTime: 'Today at 12:15 CAT',
    origin: 'Goromonzi Farmgate Cluster',
    destination: 'Marondera Aggregation Depot',
    totalFreightFee: 45.00,
    items: [
      const WaybillItem(
        id: 'WBI-03',
        waybillId: 'WB_1002',
        produceBatchId: 'BATCH-TOM-03',
        farmerName: 'Chipo Sibanda',
        cropVariety: 'Fresh Red Tomatoes',
        loadedWeightKg: 650.0,
        qualityGradeAtLoading: 'Grade A',
        moistureAtLoading: 91.0,
        qrCode: 'QR-VER-TOM-102',
      ),
    ],
    isVerifiedCarrier: true,
  ),
];

final List<ProduceBatch> _initialFarmBatches = [
  const ProduceBatch(
    id: 'BATCH-SB-01',
    farmerId: 'USR-FRM-001',
    farmerName: 'Kudakwashe Moyo',
    cropVariety: 'Grade-A Sugar Beans',
    harvestDate: '18 Aug 2026',
    initialQuantityKg: 2500.0,
    initialMoisturePercentage: 12.5,
    organicCertificationCode: 'ECO-ZIM-2026-88',
    qrCodeUid: 'QR-VER-SB-2026',
    location: 'Chiredzi Block 4',
  ),
  const ProduceBatch(
    id: 'BATCH-MZ-02',
    farmerId: 'USR-FRM-002',
    farmerName: 'Simba Dube',
    cropVariety: 'SC 719 White Seed Maize',
    harvestDate: '16 Aug 2026',
    initialQuantityKg: 15000.0,
    initialMoisturePercentage: 11.8,
    organicCertificationCode: 'NON-GMO-2026-09',
    qrCodeUid: 'QR-VER-MZ-7712',
    location: 'Bindura South',
  ),
  const ProduceBatch(
    id: 'BATCH-CIT-03',
    farmerId: 'USR-FRM-003',
    farmerName: 'Mazowe Citrus Growers',
    cropVariety: 'Valencia Oranges',
    harvestDate: '19 Aug 2026',
    initialQuantityKg: 8000.0,
    initialMoisturePercentage: 84.0,
    organicCertificationCode: 'GLOBAL-GAP-2026',
    qrCodeUid: 'QR-VER-CIT-441',
    location: 'Mazowe Valley',
  ),
];

final List<TransportOrder> _initialMarketplaceOrders = [
  const TransportOrder(
    id: 'ORD-9021',
    buyerId: 'USR-BUY-001',
    buyerName: 'National Foods Processing Plant',
    tier: LogisticsTier.longDistance,
    originAddress: 'Marondera Grain Silos',
    originLatitude: -18.1856,
    originLongitude: 31.5519,
    destinationAddress: 'Aspindale Mill, Harare',
    destinationLatitude: -17.8639,
    destinationLongitude: 30.9856,
    agreedPaymentBasis: PaymentBasis.perTonneKm,
    quotedPrice: 620.00,
    commodity: 'Wheat Grain (Bulk)',
    totalWeightKg: 24000.0,
    createdAt: '15m ago',
  ),
  const TransportOrder(
    id: 'ORD-9022',
    buyerId: 'USR-BUY-002',
    buyerName: 'Mbare Musika Fresh Traders',
    tier: LogisticsTier.shortTrip,
    originAddress: 'Domboshava Farmgate Lot #3',
    originLatitude: -17.6167,
    originLongitude: 31.1500,
    destinationAddress: 'Mbare Musika Wholesale Shed',
    destinationLatitude: -17.8596,
    destinationLongitude: 31.0422,
    agreedPaymentBasis: PaymentBasis.fixedRate,
    quotedPrice: 55.00,
    commodity: 'Leafy Vegetables (Rape/Covo)',
    totalWeightKg: 800.0,
    createdAt: '5m ago',
  ),
];
