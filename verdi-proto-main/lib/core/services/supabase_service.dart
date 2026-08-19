import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static const String _prefUrlKey = 'verdi.supabase.url';
  static const String _prefAnonKey = 'verdi.supabase.anon_key';

  // Cloud Pub/Sub relay channel for zero-config cross-device real-time sync
  static const String _cloudRelayEndpoint = 'https://ntfy.sh/verdi_live_platform_sync_v2';
  static const String _cloudRelayStream = 'https://ntfy.sh/verdi_live_platform_sync_v2/sse';

  // Default production Supabase credentials
  static const String defaultUrl = 'https://ctlczfokxexgxwtdztbu.supabase.co';
  static const String defaultAnonKey = 'sb_publishable_QcurCLLt4o6GZjcD-NOKEQ_gLYQcrU1';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  SupabaseClient? get client => _isInitialized ? Supabase.instance.client : null;

  RealtimeChannel? _activityChannel;
  RealtimeChannel? _presenceChannel;

  http.Client? _streamClient;
  bool _isCloudRelayConnected = false;

  final _activityStreamController = StreamController<PlatformActivityEvent>.broadcast();
  Stream<PlatformActivityEvent> get activityStream => _activityStreamController.stream;

  final _sessionsStreamController = StreamController<LiveUserSession>.broadcast();
  Stream<LiveUserSession> get sessionsStream => _sessionsStreamController.stream;

  Future<void> initialize() async {
    // 1. Start Zero-Config High-Speed Cloud Sync Engine
    _startCloudRelayListener();

    // 2. Initialize Supabase with clean project credentials
    try {
      final prefs = await SharedPreferences.getInstance();
      String url = (prefs.getString(_prefUrlKey) ?? defaultUrl).trim();
      final anonKey = (prefs.getString(_prefAnonKey) ?? defaultAnonKey).trim();

      // Clean URL suffix if /rest/v1/ was provided
      if (url.endsWith('/rest/v1/')) {
        url = url.substring(0, url.length - '/rest/v1/'.length);
      } else if (url.endsWith('/rest/v1')) {
        url = url.substring(0, url.length - '/rest/v1'.length);
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

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
      debugPrint('[SupabaseService] Supabase init notice: $e');
      _isInitialized = false;
    }
  }

  Future<void> updateCredentials(String url, String anonKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUrlKey, url.trim());
    await prefs.setString(_prefAnonKey, anonKey.trim());
    await initialize();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ZERO-CONFIG REAL-TIME CLOUD RELAY (HTTP SSE & WebSockets)
  // ───────────────────────────────────────────────────────────────────────────
  void _startCloudRelayListener() {
    if (_isCloudRelayConnected) return;
    _isCloudRelayConnected = true;

    _listenToCloudStream();
  }

  Future<void> _listenToCloudStream() async {
    while (true) {
      try {
        _streamClient = http.Client();
        final request = http.Request('GET', Uri.parse(_cloudRelayStream));
        final response = await _streamClient!.send(request);

        await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (line.startsWith('data:')) {
            final jsonStr = line.substring(5).trim();
            if (jsonStr.isNotEmpty) {
              _handleIncomingCloudMessage(jsonStr);
            }
          }
        }
      } catch (e) {
        debugPrint('[SupabaseService] Cloud stream reconnecting: $e');
      }

      await Future.delayed(const Duration(seconds: 3));
    }
  }

  void _handleIncomingCloudMessage(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final msgType = data['type']?.toString();
      final payload = data['payload'] as Map<String, dynamic>? ?? {};

      if (msgType == 'activity_event') {
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
          device: payload['device']?.toString() ?? 'Verdi Remote Client',
          status: payload['status']?.toString() ?? 'Success',
          targetResource: payload['targetResource']?.toString() ?? 'Global',
          ipAddress: payload['ipAddress']?.toString() ?? 'Remote Sovereign Node',
          metadata: const <String, dynamic>{},
        );
        _activityStreamController.add(e);
      } else if (msgType == 'user_session') {
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
      }
    } catch (e) {
      debugPrint('[SupabaseService] Incoming message decode err: $e');
    }
  }

  void _setupRealtimeSubscriptions() {
    final c = client;
    if (c == null) return;

    try {
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
    _activityStreamController.add(event);

    final payload = {
      'type': 'activity_event',
      'payload': {
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
    };

    // 1. Broadcast via Global High-Speed Cloud Relay
    try {
      http.post(
        Uri.parse(_cloudRelayEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('', 500));
    } catch (_) {}

    // 2. Broadcast via Supabase channel if active
    if (_isInitialized && _activityChannel != null) {
      try {
        _activityChannel?.sendBroadcastMessage(
          event: 'activity_event',
          payload: payload['payload'] as Map<String, dynamic>,
        );
      } catch (_) {}
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

    final payload = {
      'type': 'user_session',
      'payload': {
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
    };

    // 1. Broadcast via Global High-Speed Cloud Relay
    try {
      http.post(
        Uri.parse(_cloudRelayEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('', 500));
    } catch (_) {}

    // 2. Broadcast via Supabase channel if active
    if (_isInitialized && _presenceChannel != null) {
      try {
        _presenceChannel?.sendBroadcastMessage(
          event: 'user_session',
          payload: payload['payload'] as Map<String, dynamic>,
        );
      } catch (_) {}
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
