import 'package:verdi/features/crop_health/data/crop_health_models.dart';
import 'package:verdi/features/weather/data/weather_model.dart';
import 'package:verdi/state/platform_data_state.dart';
import '../models/notification_models.dart';

class NotificationRepository {
  NotificationRepository({
    this.weatherRepository,
    this.cropHealthSnapshot,
    this.orderItems = const [],
    this.paymentItems = const [],
  });

  final dynamic weatherRepository;
  final CropHealthSnapshot? cropHealthSnapshot;
  final List<OrderItem> orderItems;
  final List<PaymentItem> paymentItems;

  Future<List<PlatformNotification>> loadNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final notifications = <PlatformNotification>[];

    if (weatherRepository != null) {
      try {
        final weather = await weatherRepository.fetchWeather();
        if (weather.alerts.isNotEmpty) {
          notifications.add(_buildWeatherNotification(weather));
        }
      } catch (_) {
        // Fall back to sample data below.
      }
    }

    if (cropHealthSnapshot != null) {
      final highStressFields = cropHealthSnapshot!.fields.where((field) => field.stressLevel >= 0.6).toList();
      if (highStressFields.isNotEmpty) {
        notifications.add(_buildCropHealthNotification(highStressFields.first));
      }
    }

    if (orderItems.isNotEmpty) {
      for (final order in orderItems.where((item) => item.status == 'Pending' || item.payment == 'Unpaid' || item.priority == 'High')) {
        notifications.add(_buildOrderNotification(order));
      }
    }

    if (paymentItems.isNotEmpty) {
      for (final payment in paymentItems.where((item) => item.status == 'Failed' || item.status == 'Pending')) {
        notifications.add(_buildPaymentNotification(payment));
      }
    }

    if (notifications.isEmpty) {
      notifications.addAll(_fallbackNotifications());
    }

    return notifications;
  }

  PlatformNotification _buildWeatherNotification(WeatherData weather) {
    final alert = weather.alerts.first;
    return PlatformNotification(
      id: 'n-weather',
      title: 'Weather alert: ${alert.title}',
      body: alert.message,
      category: NotificationCategory.weather,
      severity: NotificationSeverity.high,
      status: NotificationStatus.unread,
      module: 'Weather',
      source: 'weather',
      topic: 'forecast',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      requiresAction: true,
      actions: const [
        NotificationAction(id: 'a-weather', label: 'Review forecast', type: NotificationActionType.navigate, route: '/weather'),
      ],
      aiSummary: 'Weather conditions are deteriorating and may affect field operations.',
      destinationRoute: '/weather',
    );
  }

  PlatformNotification _buildCropHealthNotification(FieldHealthDetail field) {
    return PlatformNotification(
      id: 'n-crop',
      title: 'High crop stress in ${field.name}',
      body: '${field.fieldStatus}: ${field.notes}',
      category: NotificationCategory.cropHealth,
      severity: NotificationSeverity.critical,
      status: NotificationStatus.unread,
      module: 'Crop Health',
      source: 'crop-health',
      topic: field.name,
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      requiresAction: true,
      actions: const [
        NotificationAction(id: 'a-crop', label: 'Open crop health', type: NotificationActionType.navigate, route: '/crop-health'),
      ],
      aiSummary: 'A high-stress field needs immediate scouting and action planning.',
      destinationRoute: '/crop-health',
    );
  }

  PlatformNotification _buildOrderNotification(OrderItem order) {
    return PlatformNotification(
      id: 'n-order-${order.id}',
      title: 'Order ${order.id} is ${_titleCase(order.status)}',
      body: '${order.buyer} needs attention for ${order.product} to ${order.destination}.',
      category: NotificationCategory.order,
      severity: order.priority == 'High' ? NotificationSeverity.high : NotificationSeverity.medium,
      status: NotificationStatus.unread,
      module: 'Orders',
      source: 'orders',
      topic: order.id,
      createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
      requiresAction: true,
      actions: const [
        NotificationAction(id: 'a-order', label: 'Open orders', type: NotificationActionType.navigate, route: '/orders'),
      ],
      aiSummary: 'An order requires follow-up to avoid delays in fulfillment.',
      destinationRoute: '/orders',
    );
  }

  PlatformNotification _buildPaymentNotification(PaymentItem payment) {
    return PlatformNotification(
      id: 'n-payment-${payment.id}',
      title: 'Payment ${_titleCase(payment.status)} for ${payment.party}',
      body: '${payment.note} requires attention before settlement.',
      category: NotificationCategory.payment,
      severity: payment.riskLevel == 'High' ? NotificationSeverity.critical : NotificationSeverity.high,
      status: NotificationStatus.unread,
      module: 'Payments',
      source: 'payments',
      topic: payment.ref,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      requiresAction: true,
      actions: const [
        NotificationAction(id: 'a-payment', label: 'Review payment', type: NotificationActionType.navigate, route: '/payments'),
      ],
      aiSummary: 'A payment issue could affect near-term cash flow and settlement confidence.',
      destinationRoute: '/payments',
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value.substring(0, 1).toUpperCase() + value.substring(1).toLowerCase();
  }

  List<PlatformNotification> _fallbackNotifications() {
    return [
      PlatformNotification(
        id: 'n1',
        title: 'Critical crop stress',
        body: 'Field 4 shows abnormal NDVI stress and needs scouting.',
        category: NotificationCategory.cropHealth,
        severity: NotificationSeverity.critical,
        status: NotificationStatus.unread,
        module: 'Crop Health',
        source: 'crop-health',
        topic: 'field-4',
        createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
        requiresAction: true,
        actions: const [
          NotificationAction(id: 'a1', label: 'Open crop health', type: NotificationActionType.navigate, route: '/crop-health'),
        ],
        aiSummary: 'Abnormal stress detected in Field 4.',
        destinationRoute: '/crop-health',
      ),
      PlatformNotification(
        id: 'n2',
        title: 'Order bundle update',
        body: '2 orders moved into confirmation after buyer approvals.',
        category: NotificationCategory.order,
        severity: NotificationSeverity.high,
        status: NotificationStatus.unread,
        module: 'Orders',
        source: 'orders',
        topic: 'orders',
        createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
        requiresAction: true,
        actions: const [
          NotificationAction(id: 'a2', label: 'Open orders', type: NotificationActionType.navigate, route: '/orders'),
        ],
        aiSummary: 'Buyer approvals accelerated order flow.',
        destinationRoute: '/orders',
      ),
      PlatformNotification(
        id: 'n3',
        title: 'Payment overdue',
        body: 'A wholesale settlement is now overdue and needs follow-up.',
        category: NotificationCategory.payment,
        severity: NotificationSeverity.critical,
        status: NotificationStatus.unread,
        module: 'Payments',
        source: 'payments',
        topic: 'settlement',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        requiresAction: true,
        actions: const [
          NotificationAction(id: 'a3', label: 'Review payment', type: NotificationActionType.navigate, route: '/payments'),
        ],
        aiSummary: 'Cash flow issue requires payment follow-up.',
        destinationRoute: '/payments',
      ),
      PlatformNotification(
        id: 'n4',
        title: 'Weather alert cluster',
        body: 'Storm activity and heat stress are forming across the southern corridor.',
        category: NotificationCategory.weather,
        severity: NotificationSeverity.medium,
        status: NotificationStatus.read,
        module: 'Weather',
        source: 'weather',
        topic: 'forecast',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        requiresAction: false,
        actions: const [
          NotificationAction(id: 'a4', label: 'View forecast', type: NotificationActionType.navigate, route: '/weather'),
        ],
        aiSummary: 'Weather risk remains elevated for the next 24 hours.',
        destinationRoute: '/weather',
      ),
      PlatformNotification(
        id: 'n5',
        title: 'Buyer chat burst',
        body: '4 new buyer messages arrived in the operations inbox.',
        category: NotificationCategory.chat,
        severity: NotificationSeverity.medium,
        status: NotificationStatus.unread,
        module: 'Chats',
        source: 'chat',
        topic: 'buyers',
        createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
        requiresAction: true,
        actions: const [
          NotificationAction(id: 'a5', label: 'Reply', type: NotificationActionType.navigate, route: '/assistant'),
        ],
        aiSummary: 'Buyer communication volume is rising.',
        destinationRoute: '/assistant',
      ),
      PlatformNotification(
        id: 'n6',
        title: 'Logistics delay',
        body: 'One shipment is running late and affects downstream fulfillment.',
        category: NotificationCategory.logistics,
        severity: NotificationSeverity.high,
        status: NotificationStatus.flagged,
        module: 'Logistics',
        source: 'logistics',
        topic: 'delivery',
        createdAt: DateTime.now().subtract(const Duration(minutes: 55)),
        requiresAction: true,
        actions: const [
          NotificationAction(id: 'a6', label: 'Open logistics', type: NotificationActionType.navigate, route: '/logistics'),
        ],
        aiSummary: 'A delayed shipment could impact downstream orders.',
        destinationRoute: '/logistics',
      ),
    ];
  }

  Future<List<NotificationRule>> loadRules() async {
    return [
      const NotificationRule(
        id: 'r1',
        name: 'Critical crop alerts',
        category: NotificationCategory.cropHealth,
        minimumSeverity: NotificationSeverity.high,
        requireAction: true,
        destinationRoute: '/crop-health',
      ),
      const NotificationRule(
        id: 'r2',
        name: 'Urgent payment follow-up',
        category: NotificationCategory.payment,
        minimumSeverity: NotificationSeverity.critical,
        requireAction: true,
        destinationRoute: '/payments',
      ),
    ];
  }

  Future<List<NotificationHistoryEntry>> loadHistory() async {
    return [
      NotificationHistoryEntry(
        id: 'h1',
        title: 'Field 4 reviewed',
        detail: 'Crop health issue acknowledged and routed to operations.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: NotificationStatus.resolved,
      ),
    ];
  }
}
