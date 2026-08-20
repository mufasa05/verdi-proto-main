class B2bBulkListingItem {
  final String id;
  final String cropName;
  final String grade; // e.g. Grade A, Export Prime
  final double availableTons;
  final double minOrderTons;
  final double pricePerTonUsd;
  final String location;
  final String cooperative;
  final String packaging; // e.g. 50kg Bags, Bulk Tipper, Cold Bin
  final double moisturePercent;
  final bool eudrCompliant;
  final bool phytoCertified;
  final String harvestDate;

  B2bBulkListingItem({
    required this.id,
    required this.cropName,
    required this.grade,
    required this.availableTons,
    required this.minOrderTons,
    required this.pricePerTonUsd,
    required this.location,
    required this.cooperative,
    required this.packaging,
    required this.moisturePercent,
    required this.eudrCompliant,
    required this.phytoCertified,
    required this.harvestDate,
  });
}

class B2bTenderBid {
  final String bidderId;
  final String supplierName;
  final double offeredTons;
  final double bidPricePerTonUsd;
  final String deliveryDate;
  final double moistureGrade;
  final String status; // Pending, Accepted, Rejected

  B2bTenderBid({
    required this.bidderId,
    required this.supplierName,
    required this.offeredTons,
    required this.bidPricePerTonUsd,
    required this.deliveryDate,
    required this.moistureGrade,
    this.status = 'Pending',
  });
}

class B2bRfqTenderItem {
  final String id;
  final String title;
  final String cropType;
  final double requiredTons;
  final double targetPricePerTonUsd;
  final String deliveryLocation;
  final String deadlineDate;
  final String status; // Active Bidding, Awarded, Contracted
  final List<B2bTenderBid> bids;

  B2bRfqTenderItem({
    required this.id,
    required this.title,
    required this.cropType,
    required this.requiredTons,
    required this.targetPricePerTonUsd,
    required this.deliveryLocation,
    required this.deadlineDate,
    required this.status,
    required this.bids,
  });
}

class B2bForwardContractItem {
  final String id;
  final String contractNumber;
  final String supplierName;
  final String cropType;
  final double totalTons;
  final double agreedPricePerTonUsd;
  final double totalValueUsd;
  final String startDate;
  final String expectedHarvestDate;
  final String deliveryWindow;
  final String status; // Active, In Transit, Quality Inspection, Completed
  final bool tranche1Paid; // 20% Deposit
  final bool tranche2Paid; // 40% Loading & EUDR
  final bool tranche3Paid; // 40% Weighbridge & Lab

  B2bForwardContractItem({
    required this.id,
    required this.contractNumber,
    required this.supplierName,
    required this.cropType,
    required this.totalTons,
    required this.agreedPricePerTonUsd,
    required this.totalValueUsd,
    required this.startDate,
    required this.expectedHarvestDate,
    required this.deliveryWindow,
    required this.status,
    required this.tranche1Paid,
    required this.tranche2Paid,
    required this.tranche3Paid,
  });
}

class B2bReeferFreightItem {
  final String id;
  final String tripRef;
  final String carrierName;
  final String truckType; // e.g. 34T Side-Tipper, 30T Reefer (+2°C to +4°C)
  final String regNumber;
  final String origin;
  final String destination;
  final double currentTempC;
  final String targetTempRange;
  final bool slaCompliance;
  final String eBolNumber;
  final String eta;

  B2bReeferFreightItem({
    required this.id,
    required this.tripRef,
    required this.carrierName,
    required this.truckType,
    required this.regNumber,
    required this.origin,
    required this.destination,
    required this.currentTempC,
    required this.targetTempRange,
    required this.slaCompliance,
    required this.eBolNumber,
    required this.eta,
  });
}
