import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'security_vault_service.dart';

enum RateLimitCategory {
  auth(defaultMaxRequests: 5, windowSeconds: 60, name: 'Authentication & 2FA'),
  aiAssistant(defaultMaxRequests: 20, windowSeconds: 60, name: 'AI Copilot & Voice'),
  escrowPayment(defaultMaxRequests: 10, windowSeconds: 60, name: 'Escrow & Payments'),
  marketplace(defaultMaxRequests: 30, windowSeconds: 60, name: 'Marketplace & Orders'),
  iotTelemetry(defaultMaxRequests: 25, windowSeconds: 60, name: 'IoT Drone & Telemetry'),
  geospatial(defaultMaxRequests: 40, windowSeconds: 60, name: 'Geospatial & Satellite NDVI'),
  adminActions(defaultMaxRequests: 15, windowSeconds: 60, name: 'Admin Security Controls'),
  exportPermits(defaultMaxRequests: 10, windowSeconds: 60, name: 'e-Phyto Export Permits'),
  traceability(defaultMaxRequests: 35, windowSeconds: 60, name: 'Traceability & QR Scans');

  final int defaultMaxRequests;
  final int windowSeconds;
  final String name;

  const RateLimitCategory({
    required this.defaultMaxRequests,
    required this.windowSeconds,
    required this.name,
  });
}

class RateViolationRecord {
  final String id;
  final String categoryName;
  final String targetKey;
  final DateTime timestamp;
  final int rejectedRequests;
  final String ipOrUser;

  RateViolationRecord({
    required this.id,
    required this.categoryName,
    required this.targetKey,
    required this.timestamp,
    required this.rejectedRequests,
    required this.ipOrUser,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryName': categoryName,
    'targetKey': targetKey,
    'timestamp': timestamp.toIso8601String(),
    'rejectedRequests': rejectedRequests,
    'ipOrUser': ipOrUser,
  };

  factory RateViolationRecord.fromJson(Map<String, dynamic> json) => RateViolationRecord(
    id: json['id']?.toString() ?? 'VIO-0',
    categoryName: json['categoryName']?.toString() ?? 'General',
    targetKey: json['targetKey']?.toString() ?? 'target',
    timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    rejectedRequests: (json['rejectedRequests'] as num?)?.toInt() ?? 1,
    ipOrUser: json['ipOrUser']?.toString() ?? 'Client',
  );
}

/// Enterprise-Grade Sliding-Window Rate Limiter & Token Quota Throttler.
class RateLimiterService extends ChangeNotifier {
  RateLimiterService._();
  static final RateLimiterService instance = RateLimiterService._();

  static const String _prefCustomLimits = 'verdi.rate_limiter.custom_limits';
  static const String _prefTokenUsage = 'verdi.rate_limiter.tokens_used';

  final Map<String, Queue<DateTime>> _requestHistory = {};
  final Map<RateLimitCategory, int> _customLimits = {};

  int _dailyTokenCap = 1000000;
  int _tokensUsedToday = 142850;
  int _tokensPerMinuteLimit = 25000;
  bool _isLoaded = false;

  final List<RateViolationRecord> _violations = [
    RateViolationRecord(
      id: 'VIO-901',
      categoryName: 'Authentication & 2FA',
      targetKey: 'auth_ip_197.210.45.19',
      timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      rejectedRequests: 12,
      ipOrUser: '197.210.45.19 (IP Lockout Active)',
    ),
    RateViolationRecord(
      id: 'VIO-882',
      categoryName: 'AI Copilot & Voice',
      targetKey: 'ai_USR-88901',
      timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
      rejectedRequests: 4,
      ipOrUser: 'USR-88901 (Tendai Moyo)',
    ),
    RateViolationRecord(
      id: 'VIO-714',
      categoryName: 'Escrow & Payments',
      targetKey: 'escrow_USR-99214',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      rejectedRequests: 2,
      ipOrUser: 'USR-99214 (Harare Hub)',
    ),
  ];

  int get dailyTokenCap => _dailyTokenCap;
  int get tokensUsedToday => _tokensUsedToday;
  int get tokensPerMinuteLimit => _tokensPerMinuteLimit;
  List<RateViolationRecord> get violations => List.unmodifiable(_violations);

  Future<void> initialize() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final rawLimits = prefs.getString(_prefCustomLimits);
    if (rawLimits != null && rawLimits.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(rawLimits);
        for (final entry in decoded.entries) {
          final cat = RateLimitCategory.values.firstWhere(
            (c) => c.name == entry.key,
            orElse: () => RateLimitCategory.auth,
          );
          _customLimits[cat] = (entry.value as num).toInt();
        }
      } catch (_) {}
    }

    _tokensUsedToday = prefs.getInt(_prefTokenUsage) ?? _tokensUsedToday;
    _isLoaded = true;
    notifyListeners();
  }

  int getCategoryLimit(RateLimitCategory category) {
    return _customLimits[category] ?? category.defaultMaxRequests;
  }

  Future<void> setCategoryLimit(RateLimitCategory category, int newLimit) async {
    _customLimits[category] = newLimit.clamp(1, 1000);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final map = _customLimits.map((k, v) => MapEntry(k.name, v));
    await prefs.setString(_prefCustomLimits, jsonEncode(map));
  }

  void setDailyTokenCap(int newCap) {
    _dailyTokenCap = newCap.clamp(10000, 100000000);
    notifyListeners();
  }

  void setTokensPerMinuteLimit(int newLimit) {
    _tokensPerMinuteLimit = newLimit.clamp(1000, 1000000);
    notifyListeners();
  }

  Future<void> consumeTokens(int tokenCount) async {
    _tokensUsedToday += tokenCount;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTokenUsage, _tokensUsedToday);
  }

  void flushAllCooldowns() {
    _requestHistory.clear();
    notifyListeners();
  }

  void flushCategoryCooldown(RateLimitCategory category) {
    _requestHistory.removeWhere((key, _) => key.startsWith(category.name));
    notifyListeners();
  }

  int getActiveRequestCountInWindow(RateLimitCategory category, {String keySuffix = 'global'}) {
    final key = '${category.name}_$keySuffix';
    final history = _requestHistory[key];
    if (history == null || history.isEmpty) return 0;

    final now = DateTime.now();
    final windowDuration = Duration(seconds: category.windowSeconds);
    return history.where((dt) => now.difference(dt) <= windowDuration).length;
  }

  double getCategoryUsageRatio(RateLimitCategory category, {String keySuffix = 'global'}) {
    final active = getActiveRequestCountInWindow(category, keySuffix: keySuffix);
    final limit = getCategoryLimit(category);
    if (limit == 0) return 0.0;
    return (active / limit).clamp(0.0, 1.0);
  }

  /// Checks if an action is permitted under its sliding window rate limit.
  /// If permitted, records the timestamp and returns `true`.
  /// If exceeded, records a violation record, triggers threat logging, returns `false`.
  bool checkAndRecord(
    RateLimitCategory category, {
    String keySuffix = 'global',
    void Function(int secondsRemaining)? onRateLimited,
  }) {
    final key = '${category.name}_$keySuffix';
    final now = DateTime.now();
    final windowDuration = Duration(seconds: category.windowSeconds);
    final maxRequests = getCategoryLimit(category);

    final history = _requestHistory.putIfAbsent(key, () => Queue<DateTime>());

    // Evict timestamps older than the sliding window
    while (history.isNotEmpty && now.difference(history.first) > windowDuration) {
      history.removeFirst();
    }

    if (history.length >= maxRequests) {
      final oldestInWindow = history.first;
      final timeSinceOldest = now.difference(oldestInWindow);
      final secondsRemaining = (category.windowSeconds - timeSinceOldest.inSeconds).clamp(1, category.windowSeconds);

      // Record violation locally
      final violation = RateViolationRecord(
        id: 'VIO-${DateTime.now().millisecondsSinceEpoch % 10000}',
        categoryName: category.name,
        targetKey: key,
        timestamp: now,
        rejectedRequests: 1,
        ipOrUser: keySuffix == 'global' ? 'Client Device' : keySuffix,
      );
      _violations.insert(0, violation);
      if (_violations.length > 50) _violations.removeLast();

      // Log threat event to SecurityVaultService
      SecurityVaultService.instance.logSecurityIncident(
        title: 'Rate Limit Exceeded on ${category.name}',
        ip: keySuffix == 'global' ? '127.0.0.1' : keySuffix,
        severity: category == RateLimitCategory.auth || category == RateLimitCategory.escrowPayment ? 'HIGH' : 'LOW',
        status: 'RATE_LIMITED',
      );

      notifyListeners();

      if (onRateLimited != null) {
        onRateLimited(secondsRemaining);
      }
      return false;
    }

    history.addLast(now);
    notifyListeners();
    return true;
  }

  /// Convenience method to show a standard Toast / SnackBar when rate limited
  void showRateLimitToast(BuildContext context, RateLimitCategory category, int secondsRemaining) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.speed_outlined, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rate limit reached for ${category.name}. Please wait ${secondsRemaining}s before retrying.',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
