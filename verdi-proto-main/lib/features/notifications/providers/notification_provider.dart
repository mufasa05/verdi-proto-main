import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_models.dart';
import '../repositories/notification_repository.dart';

class NotificationCenterState {
  final List<PlatformNotification> notifications;
  final List<NotificationGroup> groupedNotifications;
  final List<NotificationRule> rules;
  final List<NotificationHistoryEntry> history;
  final String selectedFilter;
  final String selectedModule;
  final String aiDigest;
  final List<AiInsight> aiInsights;
  final bool loading;
  final String? error;
  final int unreadCount;
  final int criticalCount;

  const NotificationCenterState({
    required this.notifications,
    required this.groupedNotifications,
    required this.rules,
    required this.history,
    required this.selectedFilter,
    required this.selectedModule,
    required this.aiDigest,
    required this.aiInsights,
    required this.loading,
    required this.error,
    required this.unreadCount,
    required this.criticalCount,
  });

  factory NotificationCenterState.initial() {
    return const NotificationCenterState(
      notifications: [],
      groupedNotifications: [],
      rules: [],
      history: [],
      selectedFilter: 'all',
      selectedModule: 'all',
      aiDigest: 'No alerts yet.',
      aiInsights: [],
      loading: false,
      error: null,
      unreadCount: 0,
      criticalCount: 0,
    );
  }

  NotificationCenterState copyWith({
    List<PlatformNotification>? notifications,
    List<NotificationGroup>? groupedNotifications,
    List<NotificationRule>? rules,
    List<NotificationHistoryEntry>? history,
    String? selectedFilter,
    String? selectedModule,
    String? aiDigest,
    List<AiInsight>? aiInsights,
    bool? loading,
    String? error,
    int? unreadCount,
    int? criticalCount,
  }) {
    return NotificationCenterState(
      notifications: notifications ?? this.notifications,
      groupedNotifications: groupedNotifications ?? this.groupedNotifications,
      rules: rules ?? this.rules,
      history: history ?? this.history,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedModule: selectedModule ?? this.selectedModule,
      aiDigest: aiDigest ?? this.aiDigest,
      aiInsights: aiInsights ?? this.aiInsights,
      loading: loading ?? this.loading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
      criticalCount: criticalCount ?? this.criticalCount,
    );
  }
}

class NotificationCenterNotifier extends StateNotifier<NotificationCenterState> {
  NotificationCenterNotifier(this._repository) : super(NotificationCenterState.initial());

  final NotificationRepository _repository;

  Future<void> loadNotifications() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final notifications = await _repository.loadNotifications();
      final rules = await _repository.loadRules();
      final history = await _repository.loadHistory();
      final filtered = _filterNotifications(notifications);
      final grouped = _groupNotifications(filtered);
      final unreadCount = filtered.where((item) => item.status == NotificationStatus.unread).length;
      final criticalCount = filtered.where((item) => item.severity == NotificationSeverity.critical).length;
      final aiDigest = _generateAiDigest(filtered);
      final aiInsights = _generateInsights(filtered);

      state = state.copyWith(
        notifications: notifications,
        groupedNotifications: grouped,
        rules: rules,
        history: history,
        loading: false,
        unreadCount: unreadCount,
        criticalCount: criticalCount,
        aiDigest: aiDigest,
        aiInsights: aiInsights,
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
    final notifications = _filterNotifications(state.notifications);
    state = state.copyWith(groupedNotifications: _groupNotifications(notifications));
  }

  void setModule(String module) {
    state = state.copyWith(selectedModule: module);
    final notifications = _filterNotifications(state.notifications);
    state = state.copyWith(groupedNotifications: _groupNotifications(notifications));
  }

  void acknowledge(String id) {
    final updated = state.notifications.map((item) {
      if (item.id == id) {
        return PlatformNotification(
          id: item.id,
          title: item.title,
          body: item.body,
          category: item.category,
          severity: item.severity,
          status: NotificationStatus.acknowledged,
          module: item.module,
          source: item.source,
          topic: item.topic,
          createdAt: item.createdAt,
          resolvedAt: item.resolvedAt,
          requiresAction: item.requiresAction,
          actions: item.actions,
          aiSummary: item.aiSummary,
          destinationRoute: item.destinationRoute,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(notifications: updated, groupedNotifications: _groupNotifications(_filterNotifications(updated)));
  }

  void resolve(String id) {
    final updated = state.notifications.map((item) {
      if (item.id == id) {
        return PlatformNotification(
          id: item.id,
          title: item.title,
          body: item.body,
          category: item.category,
          severity: item.severity,
          status: NotificationStatus.resolved,
          module: item.module,
          source: item.source,
          topic: item.topic,
          createdAt: item.createdAt,
          resolvedAt: DateTime.now(),
          requiresAction: item.requiresAction,
          actions: item.actions,
          aiSummary: item.aiSummary,
          destinationRoute: item.destinationRoute,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(notifications: updated, groupedNotifications: _groupNotifications(_filterNotifications(updated)));
  }

  List<PlatformNotification> _filterNotifications(List<PlatformNotification> notifications) {
    var filtered = notifications.where((item) {
      final moduleMatch = state.selectedModule == 'all' || item.module.toLowerCase() == state.selectedModule.toLowerCase();
      final filterMatch = switch (state.selectedFilter) {
        'unread' => item.status == NotificationStatus.unread,
        'critical' => item.severity == NotificationSeverity.critical,
        'action required' => item.requiresAction,
        'resolved' => item.status == NotificationStatus.resolved,
        _ => true,
      };
      return moduleMatch && filterMatch;
    }).toList();

    return filtered;
  }

  List<NotificationGroup> _groupNotifications(List<PlatformNotification> notifications) {
    final byGroup = <String, List<PlatformNotification>>{};
    for (final notification in notifications) {
      final key = '${notification.category}:${notification.topic ?? notification.source}';
      byGroup.putIfAbsent(key, () => []).add(notification);
    }

    return byGroup.entries.map((entry) {
      final items = entry.value;
      final first = items.first;
      return NotificationGroup(
        id: entry.key,
        title: first.title,
        category: first.category,
        severity: items.map((item) => item.severity).reduce((a, b) => a.index >= b.index ? a : b),
        notifications: items,
        summary: items.map((item) => item.aiSummary ?? item.body).join(' • '),
        hasUnread: items.any((item) => item.status == NotificationStatus.unread),
      );
    }).toList();
  }

  String _generateAiDigest(List<PlatformNotification> notifications) {
    if (notifications.isEmpty) {
      return 'Your operations are steady. No urgent items need attention.';
    }

    final critical = notifications.where((item) => item.severity == NotificationSeverity.critical).length;
    final action = notifications.where((item) => item.requiresAction).length;
    final unread = notifications.where((item) => item.status == NotificationStatus.unread).length;
    final crop = notifications.where((item) => item.category == NotificationCategory.cropHealth).length;
    final orders = notifications.where((item) => item.category == NotificationCategory.order).length;
    final payments = notifications.where((item) => item.category == NotificationCategory.payment).length;
    final chats = notifications.where((item) => item.category == NotificationCategory.chat).length;

    return '$critical critical issues need attention. '
        '$action items require your action. '
        '$unread notifications are unread. '
        '$orders orders updated. '
        '$payments payment items require follow-up. '
        '$crop field events detected. '
        '$chats new chats are waiting.';
  }

  List<AiInsight> _generateInsights(List<PlatformNotification> notifications) {
    final insights = <AiInsight>[];
    if (notifications.any((item) => item.category == NotificationCategory.cropHealth)) {
      insights.add(const AiInsight(
        title: 'Crop stress anomaly',
        description: 'A stress pattern suggests a field should be reviewed immediately.',
        recommendedRoute: '/crop-health',
      ));
    }
    if (notifications.any((item) => item.category == NotificationCategory.payment)) {
      insights.add(const AiInsight(
        title: 'Payment risk',
        description: 'A delayed settlement could affect operating cash flow.',
        recommendedRoute: '/payments',
      ));
    }
    if (notifications.any((item) => item.category == NotificationCategory.order)) {
      insights.add(const AiInsight(
        title: 'Order momentum',
        description: 'Order volume is increasing and should be monitored today.',
        recommendedRoute: '/orders',
      ));
    }

    return insights;
  }
}

final notificationCenterProvider = StateNotifierProvider<NotificationCenterNotifier, NotificationCenterState>((ref) {
  return NotificationCenterNotifier(NotificationRepository());
});
