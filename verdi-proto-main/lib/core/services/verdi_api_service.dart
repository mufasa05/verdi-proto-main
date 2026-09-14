import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'rate_limiter_service.dart';

/// Singleton HTTP API client for all Verdi backend requests with integrated Rate Limiter.
class VerdiApiService {
  VerdiApiService._();
  static final VerdiApiService instance = VerdiApiService._();

  static String? customBaseUrl;

  /// Sends query prompt to Verdi Backend AI endpoint (/assistant/ask).
  Future<String> askBackendAi(String prompt) async {
    final isAllowed = RateLimiterService.instance.checkAndRecord(
      RateLimitCategory.aiAssistant,
      keySuffix: 'ai_copilot_ask',
    );

    if (!isAllowed) {
      return '⚡ Rate limit reached for AI Copilot. Please wait before submitting more queries.';
    }

    // Track approximate token consumption (1 word ~ 1.3 tokens)
    final estimatedPromptTokens = (prompt.split(' ').length * 1.35).ceil() + 50;
    RateLimiterService.instance.consumeTokens(estimatedPromptTokens);

    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/assistant/ask'),
            headers: headers,
            body: jsonEncode({'text': prompt}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['reply'] != null) {
          final reply = decoded['reply'].toString().trim();
          final estimatedReplyTokens = (reply.split(' ').length * 1.35).ceil();
          RateLimiterService.instance.consumeTokens(estimatedReplyTokens);
          if (reply.isNotEmpty) return reply;
        }
      }
    } catch (e) {
      debugPrint('Verdi Backend AI request error: $e');
    }
    return 'Verdi Backend AI service is available. Please connect to the backend server for responses.';
  }

  /// Transcribes raw WAV audio bytes using Verdi Backend STT endpoint (/assistant/stt).
  Future<String?> transcribeShonaAudio(Uint8List audioBytes) async {
    final isAllowed = RateLimiterService.instance.checkAndRecord(
      RateLimitCategory.aiAssistant,
      keySuffix: 'ai_stt_transcribe',
    );

    if (!isAllowed) {
      debugPrint('⚡ Rate limit blocked Shona Audio STT transcription.');
      return null;
    }

    // Audio transcription token estimation (audio bytes / 200)
    RateLimiterService.instance.consumeTokens((audioBytes.length / 200).ceil().clamp(50, 2000));

    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'audio/wav';
      final response = await http
          .post(
            Uri.parse('$baseUrl/assistant/stt'),
            headers: headers,
            body: audioBytes,
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('transcription')) {
          final text = decoded['transcription'] as String?;
          debugPrint('⚡ Verdi Backend Shona STT transcription: $text');
          return text;
        }
      } else {
        debugPrint('Verdi Backend Shona STT API error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('transcribeShonaAudio failed: $e');
    }
    return null;
  }

  String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    return AppConfig.instance.backendBaseUrl;
  }

  // ──────────────────────────────────────────────
  // Crop Health & Irrigation
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCropZones() =>
      _getList('/crop-health/zones', category: RateLimitCategory.geospatial);

  Future<Map<String, dynamic>> irrigateZone(int id, String status) =>
      _post('/crop-health/zones/$id/irrigate', {'status': status}, category: RateLimitCategory.geospatial);

  // ──────────────────────────────────────────────
  // Drone Inspection
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDroneMissions() =>
      _getList('/drone-inspection/missions', category: RateLimitCategory.iotTelemetry);

  Future<Map<String, dynamic>> launchDroneMission(String title, String field) =>
      _post('/drone-inspection/missions/launch', {'title': title, 'field': field}, category: RateLimitCategory.iotTelemetry);

  Future<Map<String, dynamic>> updateDroneMissionStatus(String id, String status) =>
      _post('/drone-inspection/missions/$id/status', {'status': status}, category: RateLimitCategory.iotTelemetry);

  // ──────────────────────────────────────────────
  // Trade & Orders
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOrders() =>
      _getList('/trade/orders', category: RateLimitCategory.marketplace);

  Future<Map<String, dynamic>> updateOrderStatus(String id, String status) =>
      _post('/trade/orders/$id/status', {'status': status}, category: RateLimitCategory.marketplace);

  // ──────────────────────────────────────────────
  // Finance & Payments
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPayments() =>
      _getList('/payments', category: RateLimitCategory.escrowPayment);

  Future<Map<String, dynamic>> releasePayment(String id) =>
      _post('/payments/$id/release', {}, category: RateLimitCategory.escrowPayment);

  // ──────────────────────────────────────────────
  // Logistics
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDispatches() =>
      _getList('/logistics/dispatches', category: RateLimitCategory.iotTelemetry);

  Future<Map<String, dynamic>> updateDispatchStatus(String id, String status) =>
      _post('/logistics/dispatches/$id/status', {'status': status}, category: RateLimitCategory.iotTelemetry);

  // ──────────────────────────────────────────────
  // Marketplace
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMarketplaceListings() =>
      _getList('/marketplace/listings', category: RateLimitCategory.marketplace);

  Future<Map<String, dynamic>> createMarketplaceListing(Map<String, dynamic> data) =>
      _post('/marketplace/listings', data, category: RateLimitCategory.marketplace);

  // ──────────────────────────────────────────────
  // Notifications
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNotifications() => _getList('/notifications');

  Future<Map<String, dynamic>> markNotificationRead(String id) =>
      _post('/notifications/$id/read', {});

  // ──────────────────────────────────────────────
  // Traceability
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getStockBatches() =>
      _getList('/traceability/batches', category: RateLimitCategory.traceability);

  Future<List<Map<String, dynamic>>> getScanLogs() =>
      _getList('/traceability/scans', category: RateLimitCategory.traceability);

  Future<Map<String, dynamic>> recordScan({
    required String batchId,
    required String scannedBy,
    required String location,
    required String action,
  }) =>
      _post('/traceability/scan', {
        'batchId': batchId,
        'scannedBy': scannedBy,
        'location': location,
        'action': action,
      }, category: RateLimitCategory.traceability);

  // ──────────────────────────────────────────────
  // Government Permits
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getGovernmentPermits() =>
      _getList('/government/permits', category: RateLimitCategory.exportPermits);

  Future<Map<String, dynamic>> approvePermit(String id) =>
      _post('/government/permits/$id/approve', {}, category: RateLimitCategory.exportPermits);

  // ──────────────────────────────────────────────
  // Internal Helpers (With Rate Limiting Shield)
  // ──────────────────────────────────────────────

  Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('verdi.auth.token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return headers;
  }

  Future<List<Map<String, dynamic>>> _getList(String path, {RateLimitCategory? category}) async {
    if (category != null) {
      final allowed = RateLimiterService.instance.checkAndRecord(category, keySuffix: path);
      if (!allowed) {
        debugPrint('⚡ Rate limit blocked GET $path on category ${category.name}');
        return [];
      }
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: headers,
      ).timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      debugPrint('VerdiApiService _getList failed for path $path: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body, {RateLimitCategory? category}) async {
    if (category != null) {
      final allowed = RateLimiterService.instance.checkAndRecord(category, keySuffix: path);
      if (!allowed) {
        debugPrint('⚡ Rate limit blocked POST $path on category ${category.name}');
        return {'error': 'RATE_LIMITED', 'message': 'Rate limit reached for ${category.name}. Please wait before retrying.'};
      }
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(milliseconds: 3000));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (e) {
      debugPrint('VerdiApiService _post failed for path $path: $e');
    }
    return {};
  }
}
