import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static const String _prefUrlKey = 'verdi.supabase.url';
  static const String _prefAnonKey = 'verdi.supabase.anon_key';

  // Default production Supabase credentials (can be customized by user)
  static const String defaultUrl = 'https://ihujrsqjfgznknvqqpku.supabase.co';
  static const String defaultAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlodWpyc3FqZmd6bmtudnFxcGt1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMTIwMDB9.dummy';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  SupabaseClient? get client => _isInitialized ? Supabase.instance.client : null;

  RealtimeChannel? _activityChannel;
  RealtimeChannel? _presenceChannel;

  final _activityStreamController = StreamController<PlatformActivityEvent>.broadcast();
  Stream<PlatformActivityEvent> get activityStream => _activityStreamController.stream;

  final _sessionsStreamController = StreamController<LiveUserSession>.broadcast();
  Stream<LiveUserSession> get sessionsStream => _sessionsStreamController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString(_prefUrlKey) ?? defaultUrl;
      final anonKey = prefs.getString(_prefAnonKey) ?? defaultAnonKey;

      if (url.isNotEmpty && anonKey.isNotEmpty) {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
          realtimeClientOptions: const RealtimeClientOptions(
            logLevel: RealtimeLogLevel.info,
          ),
        );
        _isInitialized = true;
        _setupRealtimeSubscriptions();
      }
    } catch (e) {
      debugPrint('[SupabaseService] Initialization notice: $e');
      _isInitialized = false;
    }
  }

  Future<void> updateCredentials(String url, String anonKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUrlKey, url.trim());
    await prefs.setString(_prefAnonKey, anonKey.trim());
  }

  void _setupRealtimeSubscriptions() {
    final c = client;
    if (c == null) return;

    try {
      // 1. Listen to broadcast audit logs
      _activityChannel = c.channel('public:platform_activity_logs');
      _activityChannel?.onBroadcast(
        event: 'activity_event',
        callback: (payload) {
          try {
            final e = PlatformActivityEvent(
              id: payload['id']?.toString() ?? 'evt_${DateTime.now().millisecondsSinceEpoch}',
              userName: payload['userName']?.toString() ?? 'Stakeholder',
              userId: payload['userId']?.toString() ?? 'USR-LIVE',
              userRole: _parseRole(payload['userRole']?.toString()),
              userAvatar: payload['userAvatar']?.toString() ?? 'ST',
              actionTitle: payload['actionTitle']?.toString() ?? 'Platform Action',
              actionDescription: payload['actionDescription']?.toString() ?? '',
              timestamp: payload['timestamp']?.toString() ?? 'Just now',
              exactTime: payload['exactTime']?.toString() ?? 'Live',
              module: payload['module']?.toString() ?? 'System',
              device: payload['device']?.toString() ?? 'Verdi Web / Mobile',
              status: payload['status']?.toString() ?? 'Success',
              targetResource: payload['targetResource']?.toString() ?? 'Global',
              ipAddress: payload['ipAddress']?.toString() ?? '192.168.1.1 (Harare Node)',
              metadata: const <String, dynamic>{},
            );
            _activityStreamController.add(e);
          } catch (err) {
            debugPrint('[SupabaseService] Activity payload parsing err: $err');
          }
        },
      ).subscribe();

      // 2. Listen to presence / user sessions
      _presenceChannel = c.channel('public:live_sessions');
      _presenceChannel?.onBroadcast(
        event: 'user_session',
        callback: (payload) {
          try {
            final session = LiveUserSession(
              id: payload['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
              name: payload['name']?.toString() ?? 'User',
              role: _parseRole(payload['role']?.toString()),
              avatar: payload['avatar']?.toString() ?? 'U',
              location: payload['location']?.toString() ?? 'Harare Central',
              device: payload['device']?.toString() ?? 'Verdi Mobile Client',
              ipAddress: payload['ipAddress']?.toString() ?? 'Active Node',
              isOnline: payload['isOnline'] == true,
              lastHeartbeat: payload['lastHeartbeat']?.toString() ?? 'Just now',
              currentAction: payload['currentAction']?.toString() ?? 'Connected to Sovereign Node',
            );
            _sessionsStreamController.add(session);
          } catch (err) {
            debugPrint('[SupabaseService] Session payload parsing err: $err');
          }
        },
      ).subscribe();
    } catch (e) {
      debugPrint('[SupabaseService] Realtime subscription notice: $e');
    }
  }

  Future<void> broadcastActivityEvent(PlatformActivityEvent event) async {
    // Notify locally first
    _activityStreamController.add(event);

    if (!_isInitialized || _activityChannel == null) return;
    try {
      await _activityChannel?.sendBroadcastMessage(
        event: 'activity_event',
        payload: {
          'id': event.id,
          'userName': event.userName,
          'userId': event.userId,
          'userRole': event.userRole.name,
          'userAvatar': event.userAvatar,
          'actionTitle': event.actionTitle,
          'actionDescription': event.actionDescription,
          'timestamp': event.timestamp,
          'exactTime': event.exactTime,
          'module': event.module,
          'device': event.device,
          'status': event.status,
          'targetResource': event.targetResource,
          'ipAddress': event.ipAddress,
        },
      );

      // Attempt PostgreSQL DB insert if table exists
      final c = client;
      if (c != null) {
        c.from('platform_activity_logs').insert({
          'id': event.id,
          'user_name': event.userName,
          'user_role': event.userRole.name,
          'action_title': event.actionTitle,
          'action_description': event.actionDescription,
          'module': event.module,
          'status': event.status,
          'target_resource': event.targetResource,
          'ip_address': event.ipAddress,
          'created_at': DateTime.now().toIso8601String(),
        }).catchError((_) {});
      }
    } catch (e) {
      debugPrint('[SupabaseService] Broadcast activity error: $e');
    }
  }

  Future<void> broadcastUserPresence({
    required String userId,
    required String fullName,
    required UserRole role,
    required bool isOnline,
    String? location,
  }) async {
    final initials = fullName.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
    final session = LiveUserSession(
      id: userId,
      name: fullName,
      role: role,
      avatar: initials.isEmpty ? 'U' : initials,
      location: location ?? 'Harare, Zimbabwe',
      device: 'Verdi Mobile / Web Client',
      ipAddress: 'Sovereign Node (${role.name.toUpperCase()})',
      isOnline: isOnline,
      lastHeartbeat: 'Just now',
      currentAction: isOnline ? 'Connected to Sovereign Node' : 'Disconnected',
    );

    _sessionsStreamController.add(session);

    if (!_isInitialized || _presenceChannel == null) return;
    try {
      await _presenceChannel?.sendBroadcastMessage(
        event: 'user_session',
        payload: {
          'id': session.id,
          'name': session.name,
          'role': session.role.name,
          'avatar': session.avatar,
          'location': session.location,
          'device': session.device,
          'ipAddress': session.ipAddress,
          'isOnline': session.isOnline,
          'lastHeartbeat': session.lastHeartbeat,
          'currentAction': session.currentAction,
        },
      );

      final c = client;
      if (c != null) {
        c.from('live_sessions').upsert({
          'id': userId,
          'user_name': fullName,
          'user_role': role.name,
          'region': location ?? 'Harare Metropolitan',
          'is_online': isOnline,
          'last_heartbeat': DateTime.now().toIso8601String(),
        }).catchError((_) {});
      }
    } catch (e) {
      debugPrint('[SupabaseService] Broadcast presence error: $e');
    }
  }

  UserRole _parseRole(String? roleName) {
    if (roleName == null) return UserRole.farmer;
    return UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == roleName.toLowerCase(),
      orElse: () => UserRole.farmer,
    );
  }
}
