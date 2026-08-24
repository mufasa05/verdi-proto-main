import 'package:flutter/material.dart';

enum VehicleType {
  motorcycle,
  tricycle,
  lightTruck,
  heavyHauler,
  reeferContainer;

  String get label {
    switch (this) {
      case VehicleType.motorcycle:
        return 'Motorcycle (Cargo Box)';
      case VehicleType.tricycle:
        return 'Tricycle / TukTuk (500kg)';
      case VehicleType.lightTruck:
        return 'Light Utility Truck (3.5T)';
      case VehicleType.heavyHauler:
        return 'Heavy Hauler (15T - 30T)';
      case VehicleType.reeferContainer:
        return 'Reefer Cold-Chain Hauler';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.motorcycle:
        return Icons.two_wheeler_outlined;
      case VehicleType.tricycle:
        return Icons.electric_rickshaw_outlined;
      case VehicleType.lightTruck:
        return Icons.local_shipping_outlined;
      case VehicleType.heavyHauler:
      case VehicleType.reeferContainer:
        return Icons.fire_truck_outlined;
    }
  }
}

enum LogisticsTier {
  shortTrip,
  longDistance;

  String get label {
    switch (this) {
      case LogisticsTier.shortTrip:
        return 'Hyper-Local Short Trip';
      case LogisticsTier.longDistance:
        return 'Long-Distance Bulk Haulage';
    }
  }
}

enum ShipmentStatus {
  pendingPickup,
  inTransit,
  delayed,
  arrivedAtHub,
  delivered,
  rejected;

  String get label {
    switch (this) {
      case ShipmentStatus.pendingPickup:
        return 'Pending Pickup';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.delayed:
        return 'Delayed / Alert';
      case ShipmentStatus.arrivedAtHub:
        return 'Arrived at Dock';
      case ShipmentStatus.delivered:
        return 'Delivered & Settled';
      case ShipmentStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ShipmentStatus.pendingPickup:
        return const Color(0xFFF59E0B);
      case ShipmentStatus.inTransit:
        return const Color(0xFF3B82F6);
      case ShipmentStatus.delayed:
        return const Color(0xFFEF4444);
      case ShipmentStatus.arrivedAtHub:
        return const Color(0xFF8B5CF6);
      case ShipmentStatus.delivered:
        return const Color(0xFF10B981);
      case ShipmentStatus.rejected:
        return const Color(0xFF6B7280);
    }
  }
}

enum PaymentBasis {
  fixedRate,
  perKm,
  perTonneKm,
  marketplaceBid;

  String get label {
    switch (this) {
      case PaymentBasis.fixedRate:
        return 'Fixed Rate (Flat)';
      case PaymentBasis.perKm:
        return 'Per Kilometer';
      case PaymentBasis.perTonneKm:
        return 'Per Tonne-Km (Bulk)';
      case PaymentBasis.marketplaceBid:
        return 'Marketplace Spot Bid';
    }
  }
}

enum CarrierDutyStatus {
  available,
  onActiveTrip,
  offDuty;

  String get label {
    switch (this) {
      case CarrierDutyStatus.available:
        return 'Available for Dispatch';
      case CarrierDutyStatus.onActiveTrip:
        return 'On Active Haul';
      case CarrierDutyStatus.offDuty:
        return 'Off Duty / Maintenance';
    }
  }

  Color get color {
    switch (this) {
      case CarrierDutyStatus.available:
        return const Color(0xFF10B981);
      case CarrierDutyStatus.onActiveTrip:
        return const Color(0xFFF59E0B);
      case CarrierDutyStatus.offDuty:
        return const Color(0xFFEF4444);
    }
  }
}

class AgriVehicle {
  final String id;
  final String ownerId;
  final String registrationNumber;
  final VehicleType type;
  final LogisticsTier tierCapability;
  final double maxWeightCapacityKg;
  final bool hasColdChain;
  final bool isActive;
  final String model;
  final String color;

  const AgriVehicle({
    required this.id,
    required this.ownerId,
    required this.registrationNumber,
    required this.type,
    required this.tierCapability,
    required this.maxWeightCapacityKg,
    this.hasColdChain = false,
    this.isActive = true,
    this.model = 'Isuzu NPR',
    this.color = 'White',
  });
}

class ProduceBatch {
  final String id;
  final String farmerId;
  final String farmerName;
  final String cropVariety;
  final String harvestDate;
  final double initialQuantityKg;
  final double initialMoisturePercentage;
  final String organicCertificationCode;
  final String qrCodeUid;
  final String location;

  const ProduceBatch({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.cropVariety,
    required this.harvestDate,
    required this.initialQuantityKg,
    required this.initialMoisturePercentage,
    required this.organicCertificationCode,
    required this.qrCodeUid,
    required this.location,
  });
}

class TransportOrder {
  final String id;
  final String buyerId;
  final String buyerName;
  final LogisticsTier tier;
  final String originAddress;
  final double originLatitude;
  final double originLongitude;
  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;
  final PaymentBasis agreedPaymentBasis;
  final double quotedPrice;
  final String escrowStatus;
  final String commodity;
  final double totalWeightKg;
  final String createdAt;

  const TransportOrder({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.tier,
    required this.originAddress,
    required this.originLatitude,
    required this.originLongitude,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.agreedPaymentBasis,
    required this.quotedPrice,
    this.escrowStatus = 'HELD_IN_OS',
    required this.commodity,
    required this.totalWeightKg,
    required this.createdAt,
  });
}

class WaybillItem {
  final String id;
  final String waybillId;
  final String produceBatchId;
  final String farmerName;
  final String cropVariety;
  final double loadedWeightKg;
  final String qualityGradeAtLoading;
  final double moistureAtLoading;
  final String qrCode;

  const WaybillItem({
    required this.id,
    required this.waybillId,
    required this.produceBatchId,
    required this.farmerName,
    required this.cropVariety,
    required this.loadedWeightKg,
    required this.qualityGradeAtLoading,
    required this.moistureAtLoading,
    required this.qrCode,
  });
}

class DischargeQualityLog {
  final String id;
  final String waybillItemId;
  final double receivedWeightKg;
  final String receivedGrade;
  final double receivedMoisturePercentage;
  final double spoilageLossKg;
  final String inspectorName;
  final String inspectorSignatureUrl;
  final String loggedAt;
  final String notes;

  const DischargeQualityLog({
    required this.id,
    required this.waybillItemId,
    required this.receivedWeightKg,
    required this.receivedGrade,
    required this.receivedMoisturePercentage,
    this.spoilageLossKg = 0.0,
    required this.inspectorName,
    required this.inspectorSignatureUrl,
    required this.loggedAt,
    this.notes = 'Passed receiving dock standard checks.',
  });
}

class MasterWaybill {
  final String id;
  final String waybillNumber;
  final String transportOrderId;
  final String vehicleId;
  final String vehiclePlate;
  final String driverId;
  final String driverName;
  ShipmentStatus status;
  final double? requiredTempMin;
  final double? requiredTempMax;
  double? currentTemp;
  final String estimatedDeliveryTime;
  String? actualDeliveryTime;
  final String origin;
  final String destination;
  final double totalFreightFee;
  final List<WaybillItem> items;
  DischargeQualityLog? dischargeLog;
  final bool isVerifiedCarrier;
  final Map<String, dynamic> carrierMetadata;

  MasterWaybill({
    required this.id,
    required this.waybillNumber,
    required this.transportOrderId,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.driverId,
    required this.driverName,
    this.status = ShipmentStatus.pendingPickup,
    this.requiredTempMin,
    this.requiredTempMax,
    this.currentTemp,
    required this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    required this.origin,
    required this.destination,
    required this.totalFreightFee,
    required this.items,
    this.dischargeLog,
    this.isVerifiedCarrier = true,
    this.carrierMetadata = const {},
  });

  double get totalQuantityKg => items.fold(0.0, (sum, item) => sum + item.loadedWeightKg);
}

class CarrierProfile {
  final String id;
  final String carrierName;
  final String phone;
  final String email;
  final LogisticsTier operatingTier;
  final AgriVehicle vehicle;
  bool isVerifiedBadge;
  int completedTripsCount;
  double rating;
  CarrierDutyStatus dutyStatus;
  double walletBalance;
  final String eudrPermitCode;

  CarrierProfile({
    required this.id,
    required this.carrierName,
    required this.phone,
    required this.email,
    required this.operatingTier,
    required this.vehicle,
    this.isVerifiedBadge = true,
    this.completedTripsCount = 24,
    this.rating = 4.96,
    this.dutyStatus = CarrierDutyStatus.available,
    this.walletBalance = 3480.00,
    this.eudrPermitCode = 'EUDR-LOG-ZIM-2026-88',
  });

  bool get qualifiesForVerifiedBadge => completedTripsCount >= 20 || isVerifiedBadge;

  CarrierProfile copyWith({
    String? id,
    String? carrierName,
    String? phone,
    String? email,
    LogisticsTier? operatingTier,
    AgriVehicle? vehicle,
    bool? isVerifiedBadge,
    int? completedTripsCount,
    double? rating,
    CarrierDutyStatus? dutyStatus,
    double? walletBalance,
    String? eudrPermitCode,
  }) {
    return CarrierProfile(
      id: id ?? this.id,
      carrierName: carrierName ?? this.carrierName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      operatingTier: operatingTier ?? this.operatingTier,
      vehicle: vehicle ?? this.vehicle,
      isVerifiedBadge: isVerifiedBadge ?? this.isVerifiedBadge,
      completedTripsCount: completedTripsCount ?? this.completedTripsCount,
      rating: rating ?? this.rating,
      dutyStatus: dutyStatus ?? this.dutyStatus,
      walletBalance: walletBalance ?? this.walletBalance,
      eudrPermitCode: eudrPermitCode ?? this.eudrPermitCode,
    );
  }
}
