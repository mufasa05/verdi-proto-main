import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdi/core/config/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppConfig Tests', () {
    test('Defaults are loaded cleanly when no overrides exist', () async {
      await AppConfig.instance.clearOverrides();
      await AppConfig.instance.initialize();

      expect(AppConfig.instance.supabaseUrl, isNotEmpty);
      expect(AppConfig.instance.supabaseUrl, startsWith('https://'));
      expect(AppConfig.instance.supabaseAnonKey, isNotEmpty);
      expect(AppConfig.instance.isProduction, isTrue);
    });

    test('Custom overrides in SharedPreferences are respected', () async {
      final config = AppConfig.instance;
      await config.setCustomSupabaseCredentials(
        url: 'https://custom-project.supabase.co/rest/v1/',
        anonKey: 'test-custom-anon-key',
      );

      // Verify trailing slash sanitization
      expect(config.supabaseUrl, 'https://custom-project.supabase.co');
      expect(config.supabaseAnonKey, 'test-custom-anon-key');

      await config.setCustomBackendUrl('https://custom-api.verdi.org/');
      expect(config.backendBaseUrl, 'https://custom-api.verdi.org');

      // Cleanup
      await config.clearOverrides();
      expect(config.supabaseUrl, isNot('https://custom-project.supabase.co'));
    });
  });
}
