import 'package:flutter/material.dart';

enum NotificationCategory {
  weather,
  cropHealth,
  satellite,
  order,
  chat,
  payment,
  trade,
  logistics,
  export,
  system,
  admin,
  insight,
}

enum NotificationSeverity { low, medium, high, critical }

enum NotificationStatus { unread, read, acknowledged, resolved, flagged }

enum NotificationActionType { navigate, acknowledge, resolve, openDetails }

class PlatformNotification {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final NotificationSeverity severity;
  final NotificationStatus status;
  final String module;
  final String source;
  final String? topic;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final bool requiresAction;
  final List<NotificationAction> actions;
  final String? aiSummary;
  final String? destinationRoute;

  const PlatformNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.severity,
    required this.status,
    required this.module,
    required this.source,
    this.topic,
    required this.createdAt,
    this.resolvedAt,
    required this.requiresAction,
    required this.actions,
    this.aiSummary,
    this.destinationRoute,
  });
}

class NotificationGroup {
  final String id;
  final String title;
  final NotificationCategory category;
  final NotificationSeverity severity;
  final List<PlatformNotification> notifications;
  final String summary;
  final bool hasUnread;

  const NotificationGroup({
    required this.id,
    required this.title,
    required this.category,
    required this.severity,
    required this.notifications,
    required this.summary,
    required this.hasUnread,
  });
}

class NotificationRule {
  final String id;
  final String name;
  final NotificationCategory category;
  final NotificationSeverity minimumSeverity;
  final bool requireAction;
  final String destinationRoute;

  const NotificationRule({
    required this.id,
    required this.name,
    required this.category,
    required this.minimumSeverity,
    required this.requireAction,
    required this.destinationRoute,
  });
}

class NotificationSource {
  final String id;
  final String name;
  final String module;
  final IconData icon;

  const NotificationSource({
    required this.id,
    required this.name,
    required this.module,
    required this.icon,
  });
}

class NotificationAction {
  final String id;
  final String label;
  final NotificationActionType type;
  final String? route;

  const NotificationAction({
    required this.id,
    required this.label,
    required this.type,
    this.route,
  });
}

class NotificationRecipient {
  final String id;
  final String name;
  final String role;
  final bool isDefault;

  const NotificationRecipient({
    required this.id,
    required this.name,
    required this.role,
    required this.isDefault,
  });
}

class NotificationSummary {
  final String headline;
  final String description;
  final int criticalCount;
  final int actionCount;
  final int unreadCount;

  const NotificationSummary({
    required this.headline,
    required this.description,
    required this.criticalCount,
    required this.actionCount,
    required this.unreadCount,
  });
}

class AiInsight {
  final String title;
  final String description;
  final String recommendedRoute;

  const AiInsight({
    required this.title,
    required this.description,
    required this.recommendedRoute,
  });
}

class NotificationPreference {
  final String id;
  final String module;
  final bool enabled;
  final NotificationSeverity minSeverity;
  final bool digestEnabled;

  const NotificationPreference({
    required this.id,
    required this.module,
    required this.enabled,
    required this.minSeverity,
    required this.digestEnabled,
  });
}

class NotificationHistoryEntry {
  final String id;
  final String title;
  final String detail;
  final DateTime? timestamp;
  final NotificationStatus status;

  const NotificationHistoryEntry({
    required this.id,
    required this.title,
    required this.detail,
    this.timestamp,
    required this.status,
  });
}
