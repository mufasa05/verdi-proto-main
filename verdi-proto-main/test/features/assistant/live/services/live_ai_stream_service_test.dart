import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verdi/features/assistant/live/services/live_ai_stream_service.dart';

void main() {
  group('SseStreamService URL resolution', () {
    test('rewrites localhost for Android emulator', () {
      final resolved = SseStreamService.resolveBaseUrl(
        'http://localhost:3000',
        platform: TargetPlatform.android,
        isWeb: false,
      );

      expect(resolved, 'http://10.0.2.2:3000');
    });

    test('rewrites localhost for iOS simulator', () {
      final resolved = SseStreamService.resolveBaseUrl(
        'http://localhost:3000',
        platform: TargetPlatform.iOS,
        isWeb: false,
      );

      expect(resolved, 'http://127.0.0.1:3000');
    });

    test('keeps a custom base URL unchanged', () {
      final resolved = SseStreamService.resolveBaseUrl(
        'https://api.example.com',
        platform: TargetPlatform.android,
        isWeb: false,
      );

      expect(resolved, 'https://api.example.com');
    });
  });
}
