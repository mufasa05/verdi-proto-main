import 'dart:collection';
import 'package:flutter/material.dart';

enum RateLimitCategory {
  auth(defaultMaxRequests: 5, windowSeconds: 60, name: 'Authentication & Security'),
  aiAssistant(defaultMaxRequests: 20, windowSeconds: 60, name: 'AI Copilot & Voice'),
  escrowPayment(defaultMaxRequests: 10, windowSeconds: 60, name: 'Escrow & Payments'),
  iotTelemetry(defaultMaxRequests: 20, windowSeconds: 60, name: 'IoT Telemetry Ping'),
  marketplace(defaultMaxRequests: 30, windowSeconds: 60, name: 'Marketplace & Orders'),
  geospatial(defaultMaxRequests: 40, windowSeconds: 60, name: 'Geospatial & Satellite'),
  adminActions(defaultMaxRequests: 15, windowSeconds: 60, name: 'Admin Command Console');

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
}

class RateLimiterService {
  RateLimiterService._();
  static final RateLimiterService instance = RateLimiterService._();

  final Map<String, Queue<DateTime>> _requestHistory = {};
  final Map<RateLimitCategory, int> _customLimits = {};

  // Token monitoring state
  int _dailyTokenCap = 1000000;
  int _tokensUsedToday = 142850;
  int _tokensPerMinuteLimit = 25000;

  final List<RateViolationRecord> _violations = [
    RateViolationRecord(
      id: 'VIO-901',
      categoryName: 'Authentication & Security',
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
      ipOrUser: 'USR-99214 (Harare Fresh Produce Hub)',
    ),
  ];

  // Getters
  int get dailyTokenCap => _dailyTokenCap;
  int get tokensUsedToday => _tokensUsedToday;
  int get tokensPerMinuteLimit => _tokensPerMinuteLimit;
  List<RateViolationRecord> get violations => List.unmodifiable(_violations);

  int getCategoryLimit(RateLimitCategory category) {
    return _customLimits[category] ?? category.defaultMaxRequests;
  }

  void setCategoryLimit(RateLimitCategory category, int newLimit) {
    _customLimits[category] = newLimit.clamp(1, 1000);
  }

  void setDailyTokenCap(int newCap) {
    _dailyTokenCap = newCap.clamp(10000, 100000000);
  }

  void setTokensPerMinuteLimit(int newLimit) {
    _tokensPerMinuteLimit = newLimit.clamp(1000, 1000000);
  }

  void consumeTokens(int tokenCount) {
    _tokensUsedToday += tokenCount;
  }

  void flushAllCooldowns() {
    _requestHistory.clear();
  }

  void flushCategoryCooldown(RateLimitCategory category) {
    _requestHistory.removeWhere((key, _) => key.startsWith(category.name));
  }

  int getActiveRequestCountInWindow(RateLimitCategory category, {String keySuffix = 'global'}) {
    final key = '${category.name}_$keySuffix';
    final history = _requestHistory[key];
    if (history == null || history.isEmpty) return 0;

    final now = DateTime.now();
    final windowDuration = Duration(seconds: category.windowSeconds);
    return history.where((dt) => now.difference(dt) <= windowDuration).length;
  }

  /// Checks if an action is permitted under its rate limit.
  /// If permitted, records the timestamp and returns `true`.
  /// If exceeded, records a violation record, returns `false` and optionally calls [onRateLimited].
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

      // Record violation
      _violations.insert(
        0,
        RateViolationRecord(
          id: 'VIO-${DateTime.now().millisecondsSinceEpoch % 10000}',
          categoryName: category.name,
          targetKey: key,
          timestamp: now,
          rejectedRequests: 1,
          ipOrUser: keySuffix == 'global' ? 'Client Device' : keySuffix,
        ),
      );

      if (onRateLimited != null) {
        onRateLimited(secondsRemaining);
      }
      return false;
    }

    history.addLast(now);
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
