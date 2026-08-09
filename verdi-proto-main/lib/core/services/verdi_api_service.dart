import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton HTTP API client for all Verdi backend requests.
class VerdiApiService {
  VerdiApiService._();
  static final VerdiApiService instance = VerdiApiService._();

  static String? customBaseUrl;

  /// Sends query prompt to Verdi Backend AI endpoint (/assistant/ask).
  Future<String> askBackendAi(String prompt) async {
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
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.221:3000';
    }
    return 'http://localhost:3000';
  }

  // ──────────────────────────────────────────────
  // Crop Health & Irrigation
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCropZones() => _getList('/crop-health/zones');

  Future<Map<String, dynamic>> irrigateZone(int id, String status) =>
      _post('/crop-health/zones/$id/irrigate', {'status': status});

  // ──────────────────────────────────────────────
  // Drone Inspection
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDroneMissions() => _getList('/drone-inspection/missions');

  Future<Map<String, dynamic>> launchDroneMission(String title, String field) =>
      _post('/drone-inspection/missions/launch', {'title': title, 'field': field});

  Future<Map<String, dynamic>> updateDroneMissionStatus(String id, String status) =>
      _post('/drone-inspection/missions/$id/status', {'status': status});

  // ──────────────────────────────────────────────
  // Trade & Orders
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOrders() => _getList('/trade/orders');

  Future<Map<String, dynamic>> updateOrderStatus(String id, String status) =>
      _post('/trade/orders/$id/status', {'status': status});

  // ──────────────────────────────────────────────
  // Finance & Payments
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPayments() => _getList('/payments');

  Future<Map<String, dynamic>> releasePayment(String id) =>
      _post('/payments/$id/release', {});

  // ──────────────────────────────────────────────
  // Logistics
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDispatches() => _getList('/logistics/dispatches');

  Future<Map<String, dynamic>> updateDispatchStatus(String id, String status) =>
      _post('/logistics/dispatches/$id/status', {'status': status});

  // ──────────────────────────────────────────────
  // Marketplace
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getMarketplaceListings() =>
      _getList('/marketplace/listings');

  Future<Map<String, dynamic>> createMarketplaceListing(Map<String, dynamic> data) =>
      _post('/marketplace/listings', data);

  // ──────────────────────────────────────────────
  // Notifications
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNotifications() => _getList('/notifications');

  Future<Map<String, dynamic>> markNotificationRead(String id) =>
      _post('/notifications/$id/read', {});

  // ──────────────────────────────────────────────
  // Traceability
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getStockBatches() => _getList('/traceability/batches');

  Future<List<Map<String, dynamic>>> getScanLogs() => _getList('/traceability/scans');

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
      });

  // ──────────────────────────────────────────────
  // Government Permits
  // ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getGovernmentPermits() =>
      _getList('/government/permits');

  Future<Map<String, dynamic>> approvePermit(String id) =>
      _post('/government/permits/$id/approve', {});

  // ──────────────────────────────────────────────
  // Notifications
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> data) =>
      _post('/notifications', data);

  // ──────────────────────────────────────────────
  // Internal Helpers
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

  Future<List<Map<String, dynamic>>> _getList(String path) async {
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

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
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
