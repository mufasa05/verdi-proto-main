import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdi/features/logistics/data/logistics_data.dart';
import 'package:verdi/state/app_state.dart';

class OrderItem {
  final String id;
  final String buyer;
  final String product;
  final String quantity;
  final String destination;
  final String status;
  final String payment;
  final String total;
  final String date;
  final String eta;
  final String priority;
  final String supplier;

  const OrderItem({
    required this.id,
    required this.buyer,
    required this.product,
    required this.quantity,
    required this.destination,
    required this.status,
    required this.payment,
    required this.total,
    required this.date,
    required this.eta,
    required this.priority,
    required this.supplier,
  });
}

class TruckItem {
  final String id;
  final String driver;
  final String vehicle;
  final String plateNumber;
  final String regNumber;
  final String color;
  final String model;
  final String from;
  final String eta;
  final double costPerKm;
  final double rating;
  final String status;
  final String? imageUrl;

  const TruckItem({
    required this.id,
    required this.driver,
    required this.vehicle,
    required this.plateNumber,
    required this.regNumber,
    required this.color,
    required this.model,
    required this.from,
    required this.eta,
    required this.costPerKm,
    required this.rating,
    required this.status,
    this.imageUrl,
  });
}

class TrucksNotifier extends StateNotifier<List<TruckItem>> {
  final bool isDemo;
  static final List<TruckItem> _userTrucks = [];
  static const List<TruckItem> _mockTrucks = [
    TruckItem(
      id: 'truck-1',
      driver: 'Tafadzwa M.',
      vehicle: 'Heavy Cargo Truck (12 Tonnes)',
      plateNumber: 'AEB-2910',
      regNumber: 'REG-88219A',
      color: 'White',
      model: 'Scania R500',
      from: 'Logistics Hub',
      eta: '1h 20m',
      costPerKm: 0.20,
      rating: 4.8,
      status: 'Ready for dispatch',
    ),
    TruckItem(
      id: 'truck-2',
      driver: 'Moses K.',
      vehicle: 'Flatbed Trailer (24 Tonnes)',
      plateNumber: 'AEC-4822',
      regNumber: 'REG-99120B',
      color: 'Blue',
      model: 'Volvo FH16',
      from: 'Harare Depot',
      eta: '35m',
      costPerKm: 0.35,
      rating: 4.9,
      status: 'En route to pickup',
    ),
    TruckItem(
      id: 'truck-3',
      driver: 'Chipo D.',
      vehicle: 'Refrigerated Box Van (4 Tonnes)',
      plateNumber: 'AEF-1102',
      regNumber: 'REG-10492C',
      color: 'Yellow',
      model: 'Isuzu NPR',
      from: 'Chinhoyi Hub',
      eta: '2h 10m',
      costPerKm: 0.15,
      rating: 4.7,
      status: 'Ready for dispatch',
    ),
    TruckItem(
      id: 'truck-4',
      driver: 'Tendai G.',
      vehicle: 'Light Drop-side Truck (2 Tonnes)',
      plateNumber: 'AEG-3392',
      regNumber: 'REG-82910D',
      color: 'Red',
      model: 'Toyota Dyna',
      from: 'Marondera Station',
      eta: '10m',
      costPerKm: 0.10,
      rating: 4.6,
      status: 'Ready for dispatch',
    ),
  ];

  TrucksNotifier({required this.isDemo}) : super(isDemo ? [..._userTrucks, ..._mockTrucks] : [..._userTrucks]);

  void addTruck(TruckItem truck) {
    _userTrucks.add(truck);
    state = isDemo ? [..._userTrucks, ..._mockTrucks] : [..._userTrucks];
  }
}

final trucksListProvider =
    StateNotifierProvider<TrucksNotifier, List<TruckItem>>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  return TrucksNotifier(isDemo: isDemo);
});

class PaymentItem {
  final String id;
  final String party;
  final String type;
  final String amount;
  final String status;
  final String method;
  final String date;
  final String ref;
  final String note;
  final String riskLevel;
  final String settlementWindow;
  final String currency;
  final String destination;
  final List<String> timeline;

  const PaymentItem({
    required this.id,
    required this.party,
    required this.type,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
    required this.ref,
    required this.note,
    required this.riskLevel,
    required this.settlementWindow,
    required this.currency,
    required this.destination,
    required this.timeline,
  });
}

// Order State
class OrdersNotifier extends StateNotifier<List<OrderItem>> {
  final bool isDemo;
  static final List<OrderItem> _userOrders = [];
  static const List<OrderItem> _mockOrders = [
    OrderItem(
      id: '#ORD-1001',
      buyer: 'FreshMart Ltd',
      product: 'Tomatoes',
      quantity: '120 kg',
      destination: 'Harare',
      status: 'In Transit',
      payment: 'Paid',
      total: 'US\$ 96',
      date: 'Today, 09:20',
      eta: '1h 20m',
      priority: 'High',
      supplier: 'Mufasa Farm',
    ),
    OrderItem(
      id: '#ORD-1002',
      buyer: 'Green Basket',
      product: 'Maize',
      quantity: '430 kg',
      destination: 'Masvingo',
      status: 'Confirmed',
      payment: 'Pending',
      total: 'US\$ 258',
      date: 'Today, 10:10',
      eta: '3h 15m',
      priority: 'Medium',
      supplier: 'Mazowe Blueberries Ltd',
    ),
    OrderItem(
      id: '#ORD-1003',
      buyer: 'City Grocers',
      product: 'Potatoes',
      quantity: '220 kg',
      destination: 'Bulawayo',
      status: 'Delivered',
      payment: 'Paid',
      total: 'US\$ 176',
      date: 'Yesterday, 16:45',
      eta: 'Completed',
      priority: 'Low',
      supplier: 'Mufasa Farm',
    ),
    OrderItem(
      id: '#ORD-1004',
      buyer: 'Hotel Supply Co',
      product: 'Mango',
      quantity: '60 crates',
      destination: 'Mutare',
      status: 'Pending',
      payment: 'Unpaid',
      total: 'US\$ 144',
      date: 'Today, 11:05',
      eta: 'Awaiting',
      priority: 'High',
      supplier: 'Mutare Fresh Holdings',
    ),
  ];

  OrdersNotifier({required this.isDemo}) : super(isDemo ? [..._userOrders, ..._mockOrders] : [..._userOrders]);

  void addOrder(OrderItem order) {
    _userOrders.insert(0, order);
    state = isDemo ? [..._userOrders, ..._mockOrders] : [..._userOrders];
  }

  void updateOrder(OrderItem updatedOrder) {
    final idx = _userOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (idx != -1) {
      _userOrders[idx] = updatedOrder;
    }
    state = isDemo ? [..._userOrders, ..._mockOrders] : [..._userOrders];
  }

  void removeOrder(String id) {
    _userOrders.removeWhere((o) => o.id == id);
    state = isDemo ? [..._userOrders, ..._mockOrders] : [..._userOrders];
  }
}

final ordersListProvider =
    StateNotifierProvider<OrdersNotifier, List<OrderItem>>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  return OrdersNotifier(isDemo: isDemo);
});

// Payments State
class PaymentsNotifier extends StateNotifier<List<PaymentItem>> {
  final bool isDemo;
  static final List<PaymentItem> _userPayments = [];
  static const List<PaymentItem> _mockPayments = [
    PaymentItem(
      id: '#PAY-1001',
      party: 'FreshMart Ltd',
      type: 'Buyer Payment',
      amount: 'US\$ 96',
      status: 'Completed',
      method: 'EcoCash',
      date: 'Today, 09:20',
      ref: 'TXN-8821',
      note: 'Tomatoes order',
      riskLevel: 'Low',
      settlementWindow: 'Completed',
      currency: 'USD',
      destination: 'Harare Wallet',
      timeline: ['Initiated', 'Cleared', 'Settled'],
    ),
    PaymentItem(
      id: '#PAY-1002',
      party: 'Green Basket',
      type: 'Buyer Payment',
      amount: 'US\$ 258',
      status: 'Pending',
      method: 'Bank Transfer',
      date: 'Today, 10:10',
      ref: 'TXN-8822',
      note: 'Maize order',
      riskLevel: 'Medium',
      settlementWindow: '2 hrs',
      currency: 'USD',
      destination: 'Stanbic Account',
      timeline: ['Initiated', 'Awaiting confirmation'],
    ),
    PaymentItem(
      id: '#PAY-1003',
      party: 'City Grocers',
      type: 'Payout',
      amount: 'US\$ 176',
      status: 'Completed',
      method: 'Wallet',
      date: 'Yesterday, 16:45',
      ref: 'TXN-8819',
      note: 'Potatoes settlement',
      riskLevel: 'Low',
      settlementWindow: 'Completed',
      currency: 'USD',
      destination: 'Platform Wallet',
      timeline: ['Queued', 'Processed', 'Confirmed'],
    ),
  ];

  PaymentsNotifier({this.isDemo = true}) : super(isDemo ? [..._userPayments, ..._mockPayments] : [..._userPayments]);

  void addPayment(PaymentItem payment) {
    _userPayments.insert(0, payment);
    state = isDemo ? [..._userPayments, ..._mockPayments] : [..._userPayments];
  }

  void updatePayment(
    String id, {
    required String status,
    required String note,
    required String riskLevel,
    String? settlementWindow,
    String? destination,
    List<String>? timeline,
  }) {
    state = state.map((payment) {
      if (payment.id != id) return payment;
      return PaymentItem(
        id: payment.id,
        party: payment.party,
        type: payment.type,
        amount: payment.amount,
        status: status,
        method: payment.method,
        date: payment.date,
        ref: payment.ref,
        note: note,
        riskLevel: riskLevel,
        settlementWindow: settlementWindow ?? payment.settlementWindow,
        currency: payment.currency,
        destination: destination ?? payment.destination,
        timeline: timeline ?? payment.timeline,
      );
    }).toList();
  }
}

final paymentsListProvider =
    StateNotifierProvider<PaymentsNotifier, List<PaymentItem>>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  return PaymentsNotifier(isDemo: isDemo);
});

// Logistics Deliveries State
class DeliveriesNotifier extends StateNotifier<List<DeliveryItem>> {
  final bool isDemo;
  static final List<DeliveryItem> _userDeliveries = [];

  DeliveriesNotifier({required this.isDemo})
      : super(isDemo ? [..._userDeliveries, ...LogisticsMockData.deliveries] : [..._userDeliveries]);

  void addDelivery(DeliveryItem delivery) {
    _userDeliveries.insert(0, delivery);
    state = isDemo ? [..._userDeliveries, ...LogisticsMockData.deliveries] : [..._userDeliveries];
  }

  void updateDeliveryStatus(String id, String status) {
    state = state.map((d) {
      if (d.id == id) {
        double progress = 0.12;
        if (status == 'Picked up') progress = 0.45;
        if (status == 'On the way') progress = 0.72;
        if (status == 'Delivered') progress = 1.0;

        return DeliveryItem(
          id: d.id,
          customer: d.customer,
          product: d.product,
          quantity: d.quantity,
          from: d.from,
          to: d.to,
          status: status,
          driver: d.driver,
          vehicle: d.vehicle,
          eta: status == 'Delivered' ? 'Delivered' : d.eta,
          progress: progress,
          hub: d.hub,
          priority: d.priority,
          riskLevel: d.riskLevel,
          exceptionType: d.exceptionType,
          proofStatus: d.proofStatus,
          temperature: d.temperature,
          distanceRemaining: d.distanceRemaining,
          timeline: d.timeline,
        );
      }
      return d;
    }).toList();
  }
}

final deliveriesListProvider =
    StateNotifierProvider<DeliveriesNotifier, List<DeliveryItem>>((ref) {
  final isDemo = ref.watch(isDemoModeProvider);
  return DeliveriesNotifier(isDemo: isDemo);
});
