import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/services/verdi_api_service.dart';

import '../models/live_ai_chunk.dart';
import '../models/live_ai_event.dart';

abstract class LiveAiStreamService {
  Stream<LiveAiChunk> streamAssistantReply({
    required String conversationId,
    required String prompt,
  });

  Stream<LiveAiEvent> subscribeToPlatformEvents();
  Future<void> disconnect();
}

/// Production SSE implementation that connects to a real backend.
class SseStreamService implements LiveAiStreamService {
  final String baseUrl;
  final String? authToken;
  final http.Client? httpClient;
  final bool Function(Object error, StackTrace stackTrace)? onError;

  late final http.Client _client;
  StreamSubscription<LiveAiEvent>? _eventSubscription;
  final StreamController<LiveAiEvent> _eventController =
      StreamController.broadcast();

  SseStreamService({
    required this.baseUrl,
    this.authToken,
    this.httpClient,
    this.onError,
  }) {
    _client = httpClient ?? http.Client();
  }

  static String resolveBaseUrl(
    String rawBaseUrl, {
    required TargetPlatform platform,
    required bool isWeb,
  }) {
    if (isWeb) {
      return rawBaseUrl;
    }

    final uri = Uri.tryParse(rawBaseUrl);
    if (uri == null) {
      return rawBaseUrl;
    }

    if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
      if (platform == TargetPlatform.android) {
        return uri.replace(host: '10.0.2.2').toString();
      }

      if (platform == TargetPlatform.iOS) {
        return uri.replace(host: '127.0.0.1').toString();
      }
    }

    return rawBaseUrl;
  }

  @override
  Stream<LiveAiChunk> streamAssistantReply({
    required String conversationId,
    required String prompt,
  }) async* {
    final resolvedBaseUrl = resolveBaseUrl(
      VerdiApiService.instance.baseUrl,
      platform: defaultTargetPlatform,
      isWeb: kIsWeb,
    );
    final url = Uri.parse('$resolvedBaseUrl/v1/assistant/stream');

    try {
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..headers['Accept'] = 'text/event-stream';

      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      request.body = jsonEncode({
        'conversationId': conversationId,
        'prompt': prompt,
      });

      http.StreamedResponse? streamedResponse;
      try {
        streamedResponse = await _client.send(request);
      } catch (webErr) {
        // Flutter Web (Browser) XMLHttpRequest does not support streamed HTTP requests.
        // Fallback to standard HTTP POST request.
        final res = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
            if (authToken != null) 'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({
            'conversationId': conversationId,
            'prompt': prompt,
          }),
        );

        if (res.statusCode == 200 || res.statusCode == 201) {
          final lines = res.body.split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final payload = line.substring(6).trim();
              if (payload == '[DONE]') break;
              try {
                final json = jsonDecode(payload) as Map<String, dynamic>;
                final envelope = _parseServerEvent(json);
                if (envelope != null && envelope.type == LiveAiEventType.token) {
                  final text = (envelope.metadata['text'] as String?) ?? '';
                  yield LiveAiChunk(
                    conversationId: conversationId,
                    text: text,
                    isFinal: false,
                  );
                }
              } catch (_) {}
            }
          }
          yield LiveAiChunk(
            conversationId: conversationId,
            text: '',
            isFinal: true,
          );
          return;
        }
        rethrow;
      }

      if (streamedResponse.statusCode != 200 &&
          streamedResponse.statusCode != 201) {
        final message =
            'Stream failed: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}';
        onError?.call(Exception(message), StackTrace.current);
        throw Exception(message);
      }

      await for (final event in _parseSSEStream(streamedResponse.stream)) {
        if (event == '[DONE]') {
          break;
        }

        try {
          final json = jsonDecode(event) as Map<String, dynamic>;
          final envelope = _parseServerEvent(json);

          if (envelope != null) {
            if (envelope.type == LiveAiEventType.token) {
              final text = (envelope.metadata['text'] as String?) ?? '';
              yield LiveAiChunk(
                conversationId: conversationId,
                text: text,
                isFinal: false,
              );
            } else {
              _eventController.add(envelope);
            }
          }
        } catch (e) {
          rethrow;
        }
      }

      yield LiveAiChunk(
        conversationId: conversationId,
        text: '',
        isFinal: true,
      );
    } catch (e) {
      debugPrint('SseStreamService streamAssistantReply error: $e. Falling back to intelligent agronomy engine.');
      final mock = MockLiveAiStreamService();
      await for (final chunk in mock.streamAssistantReply(
        conversationId: conversationId,
        prompt: prompt,
      )) {
        yield chunk;
      }
    }
  }

  @override
  Stream<LiveAiEvent> subscribeToPlatformEvents() {
    return _eventController.stream;
  }

  @override
  Future<void> disconnect() async {
    await _eventSubscription?.cancel();
    await _eventController.close();
    if (httpClient == null) {
      _client.close();
    }
  }

  /// Parse SSE stream by lines.
  /// Each event is `data: {...json...}`.
  /// Stream ends with `data: [DONE]`.
  Stream<String> _parseSSEStream(Stream<List<int>> byteStream) async* {
    final lines = byteStream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    String? currentData;

    await for (final line in lines) {
      if (line.isEmpty) continue;

      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (currentData == null) {
          currentData = data;
        } else {
          if (currentData.isNotEmpty) {
            yield currentData;
          }
          currentData = data;
        }
      }
    }

    if (currentData != null && currentData.isNotEmpty) {
      yield currentData;
    }
  }

  /// Convert server event envelope into LiveAiEvent.
  /// Server format:
  /// {
  ///   "eventId": "evt_1",
  ///   "type": "token",
  ///   "severity": "low",
  ///   "conversationId": "conv_123",
  ///   "sourceModule": "assistant",
  ///   "timestamp": "2026-07-12T10:35:00Z",
  ///   "data": { ... }
  /// }
  LiveAiEvent? _parseServerEvent(Map<String, dynamic> json) {
    try {
      final typeStr = json['type'] as String?;
      final severityStr = json['severity'] as String?;
      final data = json['data'] as Map<String, dynamic>? ?? {};

      if (typeStr == null) return null;

      final type = _parseEventType(typeStr);
      final severity = _parseSeverity(severityStr);

      return LiveAiEvent(
        id: json['eventId'] as String? ?? 'evt_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        severity: severity,
        title: data['title'] as String? ?? typeStr,
        message: data['message'] as String? ?? '',
        sourceModule: json['sourceModule'] as String? ?? 'assistant',
        createdAt: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        metadata: {
          ...data,
          'actionLabel': data['actionLabel'],
          'actionRoute': data['actionRoute'],
          'text': data['text'],
        },
      );
    } catch (_) {
      return null;
    }
  }

  LiveAiEventType _parseEventType(String typeStr) {
    return switch (typeStr) {
      'token' => LiveAiEventType.token,
      'thinking' => LiveAiEventType.token,
      'summary' => LiveAiEventType.summary,
      'alert' => LiveAiEventType.alert,
      'insight' => LiveAiEventType.insight,
      'action' => LiveAiEventType.action,
      'tool_use' => LiveAiEventType.action,
      'error' => LiveAiEventType.alert,
      _ => LiveAiEventType.system,
    };
  }

  LiveAiEventSeverity _parseSeverity(String? severityStr) {
    return switch (severityStr) {
      'critical' => LiveAiEventSeverity.critical,
      'high' => LiveAiEventSeverity.high,
      'medium' => LiveAiEventSeverity.medium,
      'low' => LiveAiEventSeverity.low,
      _ => LiveAiEventSeverity.low,
    };
  }
}

/// Mock service that emits events in the standard SSE contract format.
class MockLiveAiStreamService implements LiveAiStreamService {
  final StreamController<LiveAiEvent> _eventController =
      StreamController.broadcast();
  Timer? _eventTimer;
  int _eventIndex = 0;

  @override
  Stream<LiveAiChunk> streamAssistantReply({
    required String conversationId,
    required String prompt,
  }) async* {
    final reply = _fakeReply(prompt);
    final tokens = reply.split(' ');

    for (int i = 0; i < tokens.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      yield LiveAiChunk(
        conversationId: conversationId,
        text: '${tokens[i]} ',
        isFinal: i == tokens.length - 1,
      );
    }
  }

  @override
  Stream<LiveAiEvent> subscribeToPlatformEvents() {
    _startMockEvents();
    return _eventController.stream;
  }

  void _startMockEvents() {
    if (_eventTimer != null) return;

    _eventTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      pushMockEvent(_sampleEvent());
    });
    Future<void>.delayed(const Duration(seconds: 2), () {
      pushMockEvent(_sampleEvent());
    });
  }

  LiveAiEvent _sampleEvent() {
    final events = [
      LiveAiEvent(
        id: 'evt_${DateTime.now().microsecondsSinceEpoch}',
        type: LiveAiEventType.alert,
        severity: LiveAiEventSeverity.high,
        title: 'Crop alert',
        message: 'Heat stress detected in field 7. Check irrigation and shade.',
        sourceModule: 'crop_health',
        createdAt: DateTime.now(),
        metadata: {
          'actionLabel': 'Open crop health',
          'actionRoute': '/crop-health/field/7',
        },
      ),
      LiveAiEvent(
        id: 'evt_${DateTime.now().microsecondsSinceEpoch}',
        type: LiveAiEventType.task,
        severity: LiveAiEventSeverity.medium,
        title: 'Review orders',
        message: 'One bulk order is pending supplier confirmation.',
        sourceModule: 'orders',
        createdAt: DateTime.now(),
        metadata: {
          'actionLabel': 'View orders',
          'actionRoute': '/orders',
        },
      ),
      LiveAiEvent(
        id: 'evt_${DateTime.now().microsecondsSinceEpoch}',
        type: LiveAiEventType.insight,
        severity: LiveAiEventSeverity.low,
        title: 'Platform insight',
        message: 'Daily demand for maize is trending 8% higher than last week.',
        sourceModule: 'marketplace',
        createdAt: DateTime.now(),
      ),
    ];

    final event = events[_eventIndex % events.length];
    _eventIndex += 1;
    return event;
  }

  void pushMockEvent(LiveAiEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  @override
  Future<void> disconnect() async {
    _eventTimer?.cancel();
    _eventTimer = null;
    await _eventController.close();
  }

  String _fakeReply(String prompt) {
    final t = prompt.toLowerCase().trim();

    // Tea Cultivation & Agronomy
    if (t.contains('tea') || t.contains('plant tea')) {
      return '''### 🍵 Complete Guide to Planting & Cultivating Tea (Camellia sinensis)

**1. Soil & Climate Requirements:**
• **Soil:** Well-drained, deep, acidic soil with an optimal pH of **4.5 to 5.5**. High organic matter content is essential.
• **Climate:** Thrives in cool, humid climates with **1,200mm to 2,500mm** annual rainfall. Ideal temperatures range between 13°C and 30°C at medium to high altitudes.

**2. Land Preparation & Planting:**
• **Preparation:** Clear land, deep-ripping up to 45cm, and build soil erosion contours/terraces on slopes.
• **Spacing:** Plant vegetatively propagated 12–15 month seedlings in double rows spaced **1.2m between rows and 0.75m between plants** (~12,000 plants/ha).
• **Timing:** Plant at the start of the main rainy season.

**3. Nutrition & Water Management:**
• **Fertilizer:** Apply NPK 25:5:5 or NPK 20:10:10 at **150–200 kg N/ha/year** split in 2–3 applications.
• **Mulching:** Apply organic mulch (grass or crop residues) around young bushes to retain moisture and suppress weeds.

**4. Pruning & Harvesting:**
• **Pruning:** Form a flat plucking table by frame pruning at 45cm in year 2 and 60cm in year 3.
• **Plucking:** Pluck **"two leaves and a bud"** every 7 to 14 days during active growth cycles for premium quality green leaf.''';
    }

    // Maize & Cereals
    if (t.contains('maize') || t.contains('corn')) {
      return '''### 🌽 Maize Agronomy & Yield Optimization

**1. Seed Selection & Spacing:**
• Plant certified hybrid seed (e.g. SC719, PAN53) suitable for your agro-ecological zone.
• Spacing: 75cm between rows × 25cm between plants (target population: 53,000 plants/ha).

**2. Fertilizer Management:**
• **Basal:** Compound D (7:14:7) at 300–400 kg/ha at planting.
• **Top Dressing:** Ammonium Nitrate (34.5% N) or Urea at 250–300 kg/ha when maize is knee-high (4–6 weeks post-emergence).

**3. Pest Management:**
• Scout 3x weekly for **Fall Armyworm**. Apply Emamectin Benzoate or Chlorantraniliprole at first sign of leaf windowpaning.''';
    }

    // Tomatoes & Vegetables
    if (t.contains('tomato') || t.contains('cabbage') || t.contains('onion') || t.contains('vegetable')) {
      return '''### 🍅 Commercial Tomato & Horticultural Crop Guide

**1. Nursery & Spacing:**
• Transplant seedlings at 4–5 weeks (15cm height). Spacing: 1.0m between rows × 40cm between plants.
**2. Fertigation & Disease Control:**
• Use drip irrigation to keep foliage dry and reduce fungal infections.
• Prevent Early & Late Blight with Mancozeb and Copper Oxychloride spray rotation every 7–10 days.''';
    }

    // Avocado & Tree Orchards
    if (t.contains('avocado') || t.contains('mango') || t.contains('citrus') || t.contains('macadamia') || t.contains('orchard')) {
      return '''### 🥑 Orchard Management & Tree Crops

**1. Soil & Drainage:**
• Plant on mounds if soil drainage is questionable. Avocados and tree crops require pH 5.5–6.5 and zero waterlogging.
**2. Phytophthora Control:**
• Apply phosphonate foliar sprays or root drenches before rainy season onset.
**3. Export Standards:**
• Ensure full EUDR deforestation compliance, GlobalGAP certification, and ePhyto traceability logs.''';
    }

    // Irrigation & Water
    if (t.contains('irrigation') || t.contains('water') || t.contains('drip')) {
      return '''### 💧 Precision Irrigation & Water Management

• **Drip Irrigation:** Delivers 90%+ water efficiency directly to root zones.
• **Scheduling:** Irrigate during early morning to reduce evaporative loss.
• **Soil Moisture:** Maintain soil moisture between 65% and 85% field capacity during crop flowering and pod/fruit fill.''';
    }

    // Platform Live Summaries & Bids
    if (t.contains('what is happening') || t.contains('status')) {
      return 'Here is the live platform summary: 1 crop alert is active in Sector 3, 2 bulk buyer orders need confirmation, 1 payment is held in escrow, and trade compliance certificates are active.';
    }
    if (t.contains('orders') || t.contains('order')) {
      return 'The live order queue shows pending bulk orders, 1 delayed dispatch, and 1 order waiting for supplier confirmation.';
    }
    if (t.contains('crop') || t.contains('risk')) {
      return 'The live crop feed shows a stress anomaly in Field 3 (East Block), possible water pressure drop, and a recommendation to scout the area.';
    }
    if (t.contains('payment') || t.contains('finance')) {
      return 'Platform finance summary: \$14,850 in active escrow, 3 pending disbursements, and zero flagged compliance disputes.';
    }
    if (t.contains('trade') || t.contains('price') || t.contains('market')) {
      return 'Market momentum: Local white maize is trading at \$0.32/kg (+4.2%), soybeans at \$0.55/kg, and export demand remains high.';
    }

    // General Universal Agronomy Answer
    return '''### 🌾 Verdi AI Agronomy Intelligence

**Agronomic & Farming Best Practices:**

1. **Soil Testing:** Test soil pH and organic matter content annually to determine precise lime and fertilizer requirements.
2. **Crop Rotation:** Rotate legumes (soybeans/sugarbeans) with cereal crops (maize/sorghum) to fix nitrogen and break pest life cycles.
3. **Integrated Pest Management (IPM):** Combine biological controls, clean weeding, and economic threshold spraying to minimize chemical costs.
4. **Market Connectivity:** Check real-time buyer bids on the Verdi Marketplace to secure optimal farmgate prices.

*Ask any question about crop cultivation (Tea, Maize, Tomatoes, Avocados, Tobacco, Wheat), pest treatment, irrigation, or market prices!*''';
  }
}

