import 'package:flutter/material.dart';

class DeliveryItem {
  final String id;
  final String customer;
  final String product;
  final String quantity;
  final String from;
  final String to;
  final String status;
  final String driver;
  final String vehicle;
  final String eta;
  final double progress;
  final String hub;
  final String priority;
  final String riskLevel;
  final String exceptionType;
  final String proofStatus;
  final String temperature;
  final String distanceRemaining;
  final List<String> timeline;

  const DeliveryItem({
    required this.id,
    required this.customer,
    required this.product,
    required this.quantity,
    required this.from,
    required this.to,
    required this.status,
    required this.driver,
    required this.vehicle,
    required this.eta,
    required this.progress,
    required this.hub,
    required this.priority,
    required this.riskLevel,
    required this.exceptionType,
    required this.proofStatus,
    required this.temperature,
    required this.distanceRemaining,
    required this.timeline,
  });
}

class LogisticsStat {
  final String label;
  final String value;
  final IconData icon;

  const LogisticsStat({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class LogisticsMockData {
  static const deliveries = [
    DeliveryItem(
      id: '#DLV-101',
      customer: 'Tendai M.',
      product: 'Tomatoes',
      quantity: '120 kg',
      from: 'Chiredzi Farm',
      to: 'Harare Market',
      status: 'On the way',
      driver: 'Tafadzwa',
      vehicle: 'Truck ZW-21',
      eta: '1h 20m',
      progress: 0.72,
      hub: 'Beitbridge Hub',
      priority: 'High',
      riskLevel: 'Medium',
      exceptionType: 'Weather hold',
      proofStatus: 'Pending photo',
      temperature: '8°C',
      distanceRemaining: '18.6 km',
      timeline: [
        '09:20 Loaded at Chiredzi Farm',
        '10:05 Cleared customs checkpoint',
        '11:40 Weather delay reported',
        '12:15 En route to Harare Market',
      ],
    ),
    DeliveryItem(
      id: '#DLV-102',
      customer: 'Nyasha K.',
      product: 'Maize',
      quantity: '430 kg',
      from: 'Mambo Farm',
      to: 'Masvingo Depot',
      status: 'Picked up',
      driver: 'Blessing',
      vehicle: 'Truck ZW-09',
      eta: '2h 10m',
      progress: 0.45,
      hub: 'Masvingo Hub',
      priority: 'Medium',
      riskLevel: 'Low',
      exceptionType: 'None',
      proofStatus: 'Signed',
      temperature: '21°C',
      distanceRemaining: '72 km',
      timeline: [
        '08:30 Picked up from Mambo Farm',
        '09:10 Fuel stop completed',
        '10:20 Rear axle inspection cleared',
      ],
    ),
    DeliveryItem(
      id: '#DLV-103',
      customer: 'J. Sibanda',
      product: 'Eggs',
      quantity: '52 trays',
      from: 'Sunrise Poultry',
      to: 'Bulawayo Center',
      status: 'Pending',
      driver: 'Moses',
      vehicle: 'Van ZW-14',
      eta: 'Today 4:30 PM',
      progress: 0.12,
      hub: 'Bulawayo Hub',
      priority: 'High',
      riskLevel: 'High',
      exceptionType: 'Cold-chain check',
      proofStatus: 'Awaiting scan',
      temperature: '4°C',
      distanceRemaining: '96 km',
      timeline: [
        '07:50 Pickup request received',
        '08:10 Driver assigned',
        '08:25 Awaiting cold-chain confirmation',
      ],
    ),
    DeliveryItem(
      id: '#DLV-104',
      customer: 'Rudo P.',
      product: 'Brahman',
      quantity: '2 heads',
      from: 'Mufasa Ranch',
      to: 'Gwanda Yard',
      status: 'On the way',
      driver: 'Tafadzwa',
      vehicle: 'Truck ZW-18',
      eta: '3h 05m',
      progress: 0.64,
      hub: 'Gwanda Hub',
      priority: 'Medium',
      riskLevel: 'Medium',
      exceptionType: 'Road closure',
      proofStatus: 'Photo attached',
      temperature: '24°C',
      distanceRemaining: '42 km',
      timeline: [
        '06:40 Departed Mufasa Ranch',
        '08:20 Alternate route activated',
        '09:05 Estimated arrival update',
      ],
    ),
  ];

  static const stats = [
    LogisticsStat(
      label: 'Active',
      value: '4',
      icon: Icons.local_shipping_outlined,
    ),
    LogisticsStat(
      label: 'Picked up',
      value: '1',
      icon: Icons.inventory_2_outlined,
    ),
    LogisticsStat(
      label: 'On route',
      value: '2',
      icon: Icons.alt_route_outlined,
    ),
    LogisticsStat(
      label: 'Delayed',
      value: '1',
      icon: Icons.schedule_outlined,
    ),
  ];
}