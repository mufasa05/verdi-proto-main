import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verdi/features/crop_health/data/crop_health_models.dart';
import 'package:verdi/features/notifications/providers/notification_provider.dart';
import 'package:verdi/features/notifications/repositories/notification_repository.dart';
import 'package:verdi/features/weather/data/weather_model.dart';
import 'package:verdi/state/platform_data_state.dart';

class _FakeWeatherRepository {
  Future<WeatherData> fetchWeather() async {
    return const WeatherData(
      location: 'Harare',
      summary: 'Heavy rain',
      temperature: 24,
      feelsLike: 25,
      humidity: 80,
      windSpeed: 18,
      pressure: 1008,
      rainChance: 80,
      visibility: 6,
      alerts: [WeatherAlert(title: 'Heavy rain', message: 'Flooding risk', severity: 'High')],
      hourly: [],
      daily: [],
    );
  }
}

void main() {
  test('notification provider builds grouped summaries and counts', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(notificationCenterProvider.notifier);
    await notifier.loadNotifications();

    final state = container.read(notificationCenterProvider);

    expect(state.notifications, isNotEmpty);
    expect(state.groupedNotifications, isNotEmpty);
    expect(state.unreadCount, greaterThan(0));
    expect(state.criticalCount, greaterThan(0));
    expect(state.aiDigest, isNotEmpty);
    expect(state.aiDigest.toLowerCase(), contains('critical'));
  });

  test('repository derives notifications from live module data', () async {
    final repository = NotificationRepository(
      weatherRepository: _FakeWeatherRepository(),
      cropHealthSnapshot: CropHealthSnapshot(
        capturedAt: DateTime.now(),
        title: 'Crop watch',
        summary: 'Stress levels elevated',
        fieldIndexReadings: const [],
        fields: const [
          FieldHealthDetail(
            name: 'Field A',
            crop: 'Maize',
            ndvi: 0.41,
            ndre: 0.38,
            msavi: 0.42,
            biomass: 0.39,
            stressLevel: 0.72,
            hotspotCount: 5,
            lastScanned: '2h ago',
            fieldStatus: 'High stress',
            notes: 'Needs scouting',
          ),
        ],
        stressZones: const [
          StressZone(zoneLabel: 'North patch', issue: 'Water stress', severity: 0.72, needsScouting: true),
        ],
        scoutingNotes: const [],
        imageDiagnoses: const [],
        weatherRisk: WeatherRisk(summary: 'Storm risk', level: 'High', alerts: ['Storm']),
        recommendations: const [],
        treatmentHistory: const [],
        comparison: HealthComparison(periodLabel: '7d', previousHealth: 0.6, currentHealth: 0.4, trend: '-33%'),
      ),
      orderItems: const [
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
          supplier: 'Verdi Partner',
        ),
      ],
      paymentItems: const [
        PaymentItem(
          id: '#PAY-1004',
          party: 'Hotel Supply Co',
          type: 'Buyer Payment',
          amount: 'US\$ 144',
          status: 'Failed',
          method: 'Card',
          date: 'Today, 11:05',
          ref: 'TXN-8823',
          note: 'Mango order',
          riskLevel: 'High',
          settlementWindow: 'Retry in 30 min',
          currency: 'USD',
          destination: 'Visa Gateway',
          timeline: ['Submitted', 'Declined by issuer'],
        ),
      ],
    );

    final notifications = await repository.loadNotifications();

    expect(notifications.any((n) => n.module == 'Weather' && n.title.contains('Heavy rain')), isTrue);
    expect(notifications.any((n) => n.module == 'Crop Health' && n.title.contains('stress')), isTrue);
    expect(notifications.any((n) => n.module == 'Orders' && n.title.contains('Pending')), isTrue);
    expect(notifications.any((n) => n.module == 'Payments' && n.title.contains('Failed')), isTrue);
  });
}
