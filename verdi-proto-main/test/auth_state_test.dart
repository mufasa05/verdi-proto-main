import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdi/features/auth/state/auth_state.dart';
import 'package:verdi/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthNotifier', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('signs up a new user and authenticates them', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = AuthNotifier(container);
      await notifier.initialize();

      final success = await notifier.signUp(
        fullName: 'Ava Green',
        emailOrPhone: 'ava@example.com',
        password: 'secret123',
        role: UserRole.buyer,
      );

      expect(success, isTrue);
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.email, 'ava@example.com');
      expect(notifier.state.user?.role, UserRole.buyer);
    });

    test('signs in an existing seeded user', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = AuthNotifier(container);
      await notifier.initialize();

      final success = await notifier.signIn(
        emailOrPhone: 'farmer@verdi.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.role, UserRole.farmer);
    });
  });
}
