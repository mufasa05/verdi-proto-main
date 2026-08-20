import 'dart:collection';
import 'package:flutter/material.dart';

enum RateLimitCategory {
  auth(maxRequests: 5, windowSeconds: 60, name: 'Authentication'),
  aiAssistant(maxRequests: 20, windowSeconds: 60, name: 'AI Copilot & Voice'),
  escrowPayment(maxRequests: 10, windowSeconds: 60, name: 'Escrow & Payments'),
  iotTelemetry(maxRequests: 20, windowSeconds: 60, name: 'IoT Telemetry Ping'),
  marketplace(maxRequests: 30, windowSeconds: 60, name: 'Marketplace & Orders'),
  geospatial(maxRequests: 40, windowSeconds: 60, name: 'Geospatial & Satellite'),
  adminActions(maxRequests: 15, windowSeconds: 60, name: 'Admin Command Console');

  final int maxRequests;
  final int windowSeconds;
  final String name;

  const RateLimitCategory({
    required this.maxRequests,
    required this.windowSeconds,
    required this.name,
  });
}

class RateLimiterService {
  RateLimiterService._();
  static final RateLimiterService instance = RateLimiterService._();

  final Map<String, Queue<DateTime>> _requestHistory = {};

  /// Checks if an action is permitted under its rate limit.
  /// If permitted, records the timestamp and returns `true`.
  /// If exceeded, returns `false` and optionally calls [onRateLimited].
  bool checkAndRecord(
    RateLimitCategory category, {
    String keySuffix = 'global',
    void Function(int secondsRemaining)? onRateLimited,
  }) {
    final key = '${category.name}_$keySuffix';
    final now = DateTime.now();
    final windowDuration = Duration(seconds: category.windowSeconds);

    final history = _requestHistory.putIfAbsent(key, () => Queue<DateTime>());

    // Evict timestamps older than the sliding window
    while (history.isNotEmpty && now.difference(history.first) > windowDuration) {
      history.removeFirst();
    }

    if (history.length >= category.maxRequests) {
      final oldestInWindow = history.first;
      final timeSinceOldest = now.difference(oldestInWindow);
      final secondsRemaining = (category.windowSeconds - timeSinceOldest.inSeconds).clamp(1, category.windowSeconds);

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
