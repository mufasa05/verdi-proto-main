import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verdi/core/services/security_crypto_service.dart';
import 'package:verdi/core/services/security_vault_service.dart';
import 'package:verdi/features/auth/state/auth_state.dart';
import 'package:verdi/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecurityCryptoService Tests', () {
    test('Password hashing and constant-time verification', () {
      final crypto = SecurityCryptoService.instance;
      final salt = crypto.generateSalt();
      expect(salt, isNotEmpty);

      final hashed = crypto.hashPassword('MySecurePassword2026!', salt);
      expect(hashed, isNotEmpty);

      final isValid = crypto.verifyPassword(
        plainPassword: 'MySecurePassword2026!',
        salt: salt,
        storedHash: hashed,
      );
      final isWrong = crypto.verifyPassword(
        plainPassword: 'WrongPassword',
        salt: salt,
        storedHash: hashed,
      );

      expect(isValid, isTrue);
      expect(isWrong, isFalse);
    });

    test('PBKDF2/Salted PIN hashing and verification', () {
      final crypto = SecurityCryptoService.instance;
      final salt = crypto.generateSalt();
      expect(salt, isNotEmpty);

      final hashed = crypto.hashPin('2026', salt);
      expect(hashed, isNotEmpty);

      final isCorrect = crypto.verifyPin(pin: '2026', salt: salt, storedHash: hashed);
      final isWrong = crypto.verifyPin(pin: '9999', salt: salt, storedHash: hashed);

      expect(isCorrect, isTrue);
      expect(isWrong, isFalse);
    });

    test('TOTP secret and code generation & verification', () {
      final crypto = SecurityCryptoService.instance;
      final secret = crypto.generateTotpSecret();
      expect(secret, isNotEmpty);
      expect(secret.length, equals(32));

      final code = crypto.generateTotpCode(secret);
      expect(code.length, equals(6));
      expect(int.tryParse(code), isNotNull);

      final isValidNow = crypto.verifyTotpCode(
        base32Secret: secret,
        userCode: code,
      );
      expect(isValidNow, isTrue);

      final isInvalid = crypto.verifyTotpCode(
        base32Secret: secret,
        userCode: '000000',
      );
      expect(isInvalid, isFalse);
    });

    test('Batch and Escrow tamper-evident seals generation and validation', () {
      final crypto = SecurityCryptoService.instance;
      final batchSeal = crypto.generateBatchSeal(
        batchCode: 'BATCH-2026-001',
        farmId: 'FARM-A',
        harvestDate: '2026-09-14',
        quantity: 5000.0,
        latitude: -17.824858,
        longitude: 31.053028,
      );

      expect(batchSeal, isNotEmpty);
      final isBatchValid = crypto.verifyBatchSeal(
        batchCode: 'BATCH-2026-001',
        farmId: 'FARM-A',
        harvestDate: '2026-09-14',
        quantity: 5000.0,
        latitude: -17.824858,
        longitude: 31.053028,
        expectedSeal: batchSeal,
      );
      expect(isBatchValid, isTrue);

      final isTampered = crypto.verifyBatchSeal(
        batchCode: 'BATCH-2026-001',
        farmId: 'FARM-A',
        harvestDate: '2026-09-14',
        quantity: 99999.0, // altered quantity
        latitude: -17.824858,
        longitude: 31.053028,
        expectedSeal: batchSeal,
      );
      expect(isTampered, isFalse);
    });

    test('Input sanitization strips malicious HTML and script tags', () {
      final crypto = SecurityCryptoService.instance;
      final raw = '<script>alert("hack")</script>Hello & <b>World</b>';
      final clean = crypto.sanitizeInput(raw);

      expect(clean.contains('<script>'), isFalse);
      expect(clean.contains('</script>'), isFalse);
      expect(clean.contains('&lt;'), isFalse);
      expect(clean, contains('Hello'));
      expect(clean, contains('World'));
    });

    test('Password strength validation rules', () {
      final crypto = SecurityCryptoService.instance;
      expect(crypto.isPasswordStrong('short'), isFalse);
      expect(crypto.isPasswordStrong('alllettersonly'), isFalse);
      expect(crypto.isPasswordStrong('12345678'), isFalse);
      expect(crypto.isPasswordStrong('StrongPass2026!'), isTrue);
    });
  });

  group('SecurityVaultService Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SecurityVaultService.instance.initialize();
    });

    test('Default records are initialized on fresh startup', () async {
      final vault = SecurityVaultService.instance;
      expect(vault.apiKeys, isNotEmpty);
      expect(vault.ipRules, isNotEmpty);
      expect(vault.incidents, isNotEmpty);

      // Default PIN is 2026
      final isDefaultPinValid = await vault.verifyMasterPin('2026');
      expect(isDefaultPinValid, isTrue);
    });

    test('Master PIN update and verification', () async {
      final vault = SecurityVaultService.instance;
      await vault.updateMasterPin('5432');

      final oldValid = await vault.verifyMasterPin('2026');
      final newValid = await vault.verifyMasterPin('5432');

      expect(oldValid, isFalse);
      expect(newValid, isTrue);
    });

    test('API key management: create, rotate, revoke', () async {
      final vault = SecurityVaultService.instance;
      final initialCount = vault.apiKeys.length;

      await vault.createApiKey('Test Gateway API', 'Payments Scope');
      expect(vault.apiKeys.length, equals(initialCount + 1));
      final created = vault.apiKeys.first;
      expect(created.name, equals('Test Gateway API'));
      expect(created.status, equals('ACTIVE'));

      final originalKey = created.key;
      await vault.rotateApiKey(created.id);
      final rotated = vault.apiKeys.firstWhere((k) => k.id == created.id);
      expect(rotated.key, isNot(equals(originalKey)));
      expect(rotated.status, equals('ACTIVE'));

      await vault.revokeApiKey(created.id);
      final revoked = vault.apiKeys.firstWhere((k) => k.id == created.id);
      expect(revoked.status, equals('REVOKED'));
    });

    test('IP Firewall rules and blocking check', () async {
      final vault = SecurityVaultService.instance;
      expect(vault.isIpBlocked('10.99.88.77'), isFalse);

      await vault.addIpRule('10.99.88.77', 'BLOCK', 'DDoS suspect');
      expect(vault.isIpBlocked('10.99.88.77'), isTrue);

      await vault.removeIpRule('10.99.88.77');
      expect(vault.isIpBlocked('10.99.88.77'), isFalse);
    });

    test('Incident logging and recording', () async {
      final vault = SecurityVaultService.instance;
      final initialCount = vault.incidents.length;

      await vault.logSecurityIncident(
        title: 'Unauthorized Export Token',
        ip: '192.168.1.50',
        severity: 'HIGH',
        status: 'BLOCKED',
      );

      expect(vault.incidents.length, equals(initialCount + 1));
      expect(vault.incidents.first.title, equals('Unauthorized Export Token'));
      expect(vault.incidents.first.severity, equals('HIGH'));
    });
  });

  group('AuthState 2FA Challenge Flow Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SecurityVaultService.instance.initialize();
    });

    test('High-security Admin login prompts 2FA challenge and validates successfully', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = AuthNotifier(container);
      await notifier.initialize();

      // Register an admin user account
      await notifier.signUp(
        fullName: 'Verdi Super Admin',
        emailOrPhone: 'admin@verdi.co',
        password: 'securePassword123!',
        role: UserRole.admin,
      );

      // Sign out to test sign-in flow
      await notifier.signOut();
      expect(notifier.state.isAuthenticated, isFalse);

      // Sign in as the registered admin
      final result = await notifier.signIn(
        emailOrPhone: 'admin@verdi.co',
        password: 'securePassword123!',
      );

      expect(result, isTrue);
      expect(notifier.state.requires2fa, isTrue);
      expect(notifier.state.pendingUser, isNotNull);
      expect(notifier.state.pendingUser?.role, equals(UserRole.admin));
      expect(notifier.state.totpSecret, isNotNull);
      expect(notifier.state.isAuthenticated, isFalse);

      // Generate the correct TOTP code for the user secret
      final secret = notifier.state.totpSecret!;
      final correctCode = SecurityCryptoService.instance.generateTotpCode(secret);

      // Verify with valid code
      final verified = await notifier.verify2faCode(correctCode);
      expect(verified, isTrue);
      expect(notifier.state.requires2fa, isFalse);
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.role, equals(UserRole.admin));
    });

    test('Invalid 2FA code is rejected and maintains challenge gate', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = AuthNotifier(container);
      await notifier.initialize();

      // Register an admin user account
      await notifier.signUp(
        fullName: 'Verdi Super Admin',
        emailOrPhone: 'admin@verdi.co',
        password: 'securePassword123!',
        role: UserRole.admin,
      );

      // Sign out
      await notifier.signOut();

      // Attempt sign in
      await notifier.signIn(
        emailOrPhone: 'admin@verdi.co',
        password: 'securePassword123!',
      );

      expect(notifier.state.requires2fa, isTrue);

      final verified = await notifier.verify2faCode('000000');
      expect(verified, isFalse);
      expect(notifier.state.requires2fa, isTrue);
      expect(notifier.state.isAuthenticated, isFalse);
      expect(notifier.state.errorMessage, contains('Invalid 2FA Authenticator code'));

      // Cancelling 2FA returns to sign in
      notifier.cancel2fa();
      expect(notifier.state.requires2fa, isFalse);
      expect(notifier.state.pendingUser, isNull);
    });
  });
}
