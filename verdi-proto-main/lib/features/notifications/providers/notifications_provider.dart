import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/verdi_api_service.dart';

class VerdiNotification {
  final String id;
  final String title;
  final String message;
  final bool read;
  final String severity;
  final String category;
  final String timestamp;

  const VerdiNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.severity,
    required this.category,
    required this.timestamp,
  });

  factory VerdiNotification.fromJson(Map<String, dynamic> json) {
    return VerdiNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      read: json['read'] == true,
      severity: json['severity']?.toString() ?? 'low',
      category: json['category']?.toString() ?? 'system',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  VerdiNotification copyWith({bool? read}) {
    return VerdiNotification(
      id: id,
      title: title,
      message: message,
      read: read ?? this.read,
      severity: severity,
      category: category,
      timestamp: timestamp,
    );
  }
}

class NotificationsState {
  final List<VerdiNotification> notifications;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    required this.notifications,
    required this.isLoading,
    this.error,
  });

  static const initial = NotificationsState(notifications: [], isLoading: true);

  NotificationsState copyWith({
    List<VerdiNotification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final _api = VerdiApiService.instance;

  NotificationsNotifier() : super(NotificationsState.initial) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _api.getNotifications();
      state = state.copyWith(
        notifications: data.map(VerdiNotification.fromJson).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markRead(String id) async {
    await _api.markNotificationRead(id);
    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(read: true) : n)
          .toList(),
    );
  }

  Future<void> markAllRead() async {
    final unread = state.notifications.where((n) => !n.read).toList();
    for (final n in unread) {
      await _api.markNotificationRead(n.id);
    }
    state = state.copyWith(
      notifications: state.notifications.map((n) => n.copyWith(read: true)).toList(),
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
  (ref) => NotificationsNotifier(),
);
