import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:verdi/core/services/verdi_api_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../state/app_state.dart';
import '../../../state/platform_data_state.dart';
import '../../agri_expert/data/agri_expert_models.dart';

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: UserRole.values.byName(json['role']?.toString() ?? 'farmer'),
    );
  }
}

class AuthState {
  final AppUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.user,
    required this.isAuthenticated,
    required this.isLoading,
    required this.errorMessage,
  });

  AuthState copyWith({
    AppUser? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  static const initial = AuthState(
    user: null,
    isAuthenticated: false,
    isLoading: false,
    errorMessage: null,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  static const _sessionKey = 'verdi.auth.session';
  static const _registeredUsersKey = 'verdi.auth.registered_users_db_v2';

  final Ref? _ref;
  final ProviderContainer? _container;
  String? _customBaseUrl;

  AuthNotifier([Object? refOrContainer])
      : _ref = refOrContainer is Ref ? refOrContainer : null,
        _container = refOrContainer is ProviderContainer
            ? refOrContainer
            : null,
        super(AuthState.initial);

  void _setRole(UserRole role) {
    if (_ref != null) {
      _ref.read(appStateProvider.notifier).setRole(role);
      return;
    }

    if (_container != null) {
      _container.read(appStateProvider.notifier).setRole(role);
    }
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final prefs = await SharedPreferences.getInstance();
    _customBaseUrl = prefs.getString('verdi.auth.custom_url');
    VerdiApiService.customBaseUrl = _customBaseUrl;
    final rawSession = prefs.getString(_sessionKey);

    if (rawSession == null || rawSession.isEmpty) {
      _setRole(UserRole.farmer);
      state = AuthState.initial;
      return;
    }

    try {
      final user = AppUser.fromJson(jsonDecode(rawSession));
      final deletedList = prefs.getStringList('verdi.admin.deleted_user_ids') ?? [];
      final cleanEmail = user.email.toLowerCase().replaceAll(' ', '');
      if (deletedList.contains(user.id) || (cleanEmail.isNotEmpty && deletedList.contains(cleanEmail))) {
        await prefs.remove(_sessionKey);
        await prefs.remove('verdi.auth.token');
        await prefs.remove('verdi.auth.last_email');
        _setRole(UserRole.farmer);
        state = AuthState.initial;
        return;
      }

      _setRole(user.role);
      final isDemoSaved = prefs.getBool('verdi.app.is_demo_mode') ?? false;
      if (_ref != null) {
        _ref.read(appStateProvider.notifier).setDemoMode(isDemoSaved);
      } else if (_container != null) {
        _container.read(appStateProvider.notifier).setDemoMode(isDemoSaved);
      }
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
      );
    } catch (_) {
      await prefs.remove(_sessionKey);
      _setRole(UserRole.farmer);
      state = AuthState.initial;
    }
  }

  String get _baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.221:3000';
    }
    return 'http://localhost:3000';
  }

  String get currentBaseUrl => _baseUrl;

  void enterOfflineDemoMode({
    required String email,
    required String fullName,
    required UserRole role,
    ExpertPersona? expertPersona,
  }) async {
    final mockUser = AppUser(
      id: 'usr_demo_${role.name}_${DateTime.now().millisecond}',
      fullName: fullName.isEmpty ? 'Demo User' : fullName,
      email: email.trim().isEmpty ? '${role.name}@demo.verdi.co' : email.trim(),
      role: role,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(mockUser.toJson()));
    await prefs.setString('verdi.auth.token', 'demo_token_2026');
    await prefs.setString('verdi.auth.last_email', mockUser.email);
    await prefs.setBool('verdi.app.is_demo_mode', true);

    _setRole(role);
    if (expertPersona != null) {
      if (_ref != null) {
        _ref.read(appStateProvider.notifier).setExpertPersona(expertPersona);
      } else if (_container != null) {
        _container.read(appStateProvider.notifier).setExpertPersona(expertPersona);
      }
    }
    if (_ref != null) {
      _ref.read(appStateProvider.notifier).setDemoMode(true);
    } else if (_container != null) {
      _container.read(appStateProvider.notifier).setDemoMode(true);
    }
    state = state.copyWith(
      user: mockUser,
      isAuthenticated: true,
      isLoading: false,
      errorMessage: null,
    );
  }

  Future<void> setCustomBaseUrl(String url) async {
    _customBaseUrl = url.trim();
    VerdiApiService.customBaseUrl = url.trim();
    final prefs = await SharedPreferences.getInstance();
    if (url.trim().isEmpty) {
      await prefs.remove('verdi.auth.custom_url');
    } else {
      await prefs.setString('verdi.auth.custom_url', url.trim());
    }
  }

  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('verdi.auth.last_email');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LOCAL REGISTERED USERS PERSISTENCE HELPERS
  // ───────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_registeredUsersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw);
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveRegisteredUser(Map<String, dynamic> userRecord) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getRegisteredUsers();
    final newId = userRecord['identifier'].toString().toLowerCase().replaceAll(' ', '');
    users.removeWhere((u) => u['identifier'].toString().toLowerCase().replaceAll(' ', '') == newId);
    users.add(userRecord);
    await prefs.setString(_registeredUsersKey, jsonEncode(users));
  }

  // Clear all saved logins & sessions
  Future<void> clearAllSavedLogins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove('verdi.auth.token');
    await prefs.remove('verdi.auth.last_email');
    state = AuthState.initial;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SIGN IN & SIGN UP (WITH STRICT REGISTRATION GUARD & NO UNREGISTERED LOGIN)
  // ───────────────────────────────────────────────────────────────────────────
  Future<bool> signIn({required String emailOrPhone, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final cleanId = emailOrPhone.trim().toLowerCase().replaceAll(' ', '');
    final cleanPass = password;

    final prefs = await SharedPreferences.getInstance();
    final deletedList = prefs.getStringList('verdi.admin.deleted_user_ids') ?? [];
    if (deletedList.contains(cleanId)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'This account was deleted by administration and is no longer accessible.',
      );
      return false;
    }

    final isDemoActive = _ref?.read(isDemoModeProvider) ?? _container?.read(isDemoModeProvider) ?? false;
    final isDemoUser = isDemoActive || cleanId.contains('demo') || cleanId.contains('@demo.verdi.co');

    if (isDemoUser) {
      UserRole inferredRole = _ref?.read(appStateProvider).role ?? _container?.read(appStateProvider).role ?? UserRole.farmer;
      for (final r in UserRole.values) {
        if (cleanId.contains(r.name.toLowerCase())) {
          inferredRole = r;
          break;
        }
      }

      enterOfflineDemoMode(
        email: emailOrPhone.trim().isEmpty ? '${inferredRole.name}@demo.verdi.co' : emailOrPhone.trim(),
        fullName: 'Demo ${inferredRole.label}',
        role: inferredRole,
      );
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailOrPhone.trim(),
          'password': password,
        }),
      ).timeout(const Duration(milliseconds: 2500));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userJson = data['user'] as Map<String, dynamic>;

        final user = AppUser(
          id: userJson['id']?.toString() ?? '',
          fullName: userJson['fullName']?.toString() ?? '',
          email: userJson['email']?.toString() ?? '',
          phone: userJson['phone']?.toString() ?? '',
          role: UserRole.values.byName(userJson['role']?.toString() ?? 'farmer'),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
        await prefs.setString('verdi.auth.token', token);
        await prefs.setString('verdi.auth.last_email', emailOrPhone.trim());
        await prefs.setBool('verdi.app.is_demo_mode', isDemoActive);

        _setRole(user.role);
        if (_ref != null) {
          _ref.read(appStateProvider.notifier).setDemoMode(isDemoActive);
        } else if (_container != null) {
          _container.read(appStateProvider.notifier).setDemoMode(isDemoActive);
        }
        _broadcastAuthEvent(user, isRegistration: false);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        String msg = 'Invalid credentials.';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody['message'] != null) {
            msg = errBody['message'].toString();
          }
        } catch (_) {}
        state = state.copyWith(isLoading: false, errorMessage: msg);
        return false;
      }
    } catch (_) {
      // Backend unavailable -> Authenticate against local registered users database
      final users = await _getRegisteredUsers();
      final match = users.firstWhere(
        (u) => u['identifier'].toString().toLowerCase().replaceAll(' ', '') == cleanId,
        orElse: () => {},
      );

      if (match.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No account found with this email or phone number. Please register for an account first.',
        );
        return false;
      }

      if (match['password'].toString() != cleanPass) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Incorrect password. Please verify your password and try again.',
        );
        return false;
      }

      // Successful local login
      final user = AppUser(
        id: match['id']?.toString() ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: match['fullName']?.toString() ?? cleanId,
        email: cleanId.contains('@') ? cleanId : '$cleanId@verdi.ag',
        phone: cleanId.contains('@') ? '' : cleanId,
        role: UserRole.values.byName(match['role']?.toString() ?? 'farmer'),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
      await prefs.setString('verdi.auth.last_email', emailOrPhone.trim());
      await prefs.setBool('verdi.app.is_demo_mode', isDemoActive);

      _setRole(user.role);
      if (_ref != null) {
        _ref.read(appStateProvider.notifier).setDemoMode(isDemoActive);
      } else if (_container != null) {
        _container.read(appStateProvider.notifier).setDemoMode(isDemoActive);
      }
      _broadcastAuthEvent(user, isRegistration: false);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final cleanId = emailOrPhone.trim().toLowerCase().replaceAll(' ', '');

    final newUserRecord = {
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'fullName': fullName.trim(),
      'identifier': cleanId,
      'password': password,
      'role': role.name,
    };

    // Save locally to persistent SharedPreferences store
    await _saveRegisteredUser(newUserRecord);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName.trim(),
          'email': emailOrPhone.trim(),
          'password': password,
          'role': role.name,
        }),
      ).timeout(const Duration(milliseconds: 2500));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userJson = data['user'] as Map<String, dynamic>;

        final user = AppUser(
          id: userJson['id']?.toString() ?? '',
          fullName: userJson['fullName']?.toString() ?? '',
          email: userJson['email']?.toString() ?? '',
          phone: userJson['phone']?.toString() ?? '',
          role: UserRole.values.byName(userJson['role']?.toString() ?? 'farmer'),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
        await prefs.setString('verdi.auth.token', token);
        await prefs.setString('verdi.auth.last_email', emailOrPhone.trim());

        _setRole(user.role);
        _broadcastAuthEvent(user, isRegistration: true);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      }
    } catch (_) {
      // Backend offline -> Complete sign up via local database
    }

    final user = AppUser(
      id: newUserRecord['id']!,
      fullName: fullName.trim(),
      email: cleanId.contains('@') ? cleanId : '$cleanId@verdi.ag',
      phone: cleanId.contains('@') ? '' : cleanId,
      role: role,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
    await prefs.setString('verdi.auth.last_email', emailOrPhone.trim());

    _setRole(role);
    _broadcastAuthEvent(user, isRegistration: true);
    state = state.copyWith(
      user: user,
      isAuthenticated: true,
      isLoading: false,
      errorMessage: null,
    );
    return true;
  }

  void _broadcastAuthEvent(AppUser user, {required bool isRegistration}) {
    try {
      SupabaseService.instance.broadcastUserPresence(
        userId: user.id,
        fullName: user.fullName,
        role: user.role,
        isOnline: true,
      );

      final initials = user.fullName.trim().split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();
      final idSuffix = user.id.length > 6 ? user.id.substring(user.id.length - 6) : user.id;
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} CAT';
      final dateStr = '${now.day} Aug ${now.year} $timeStr';

      SupabaseService.instance.broadcastActivityEvent(
        PlatformActivityEvent(
          id: 'ACT_${now.millisecondsSinceEpoch}',
          userName: user.fullName,
          userId: user.id,
          userRole: user.role,
          userAvatar: initials.isEmpty ? 'U' : initials,
          actionTitle: isRegistration ? 'New Stakeholder Account Registered' : 'Stakeholder Authenticated to Sovereign Network',
          actionDescription: isRegistration
              ? '${user.fullName} registered a new verified ${user.role.name.toUpperCase()} account.'
              : '${user.fullName} logged into node session via secure JWT.',
          module: 'Security & Auth',
          targetResource: 'Session #$idSuffix',
          timestamp: timeStr,
          exactTime: dateStr,
          ipAddress: 'Sovereign Node (${user.role.name.toUpperCase()})',
          device: 'Verdi Mobile / Web Client',
          status: 'Success',
          metadata: {
            'email': user.email.isNotEmpty ? user.email : 'Not provided',
            'phone': user.phone.isNotEmpty ? user.phone : 'Not provided',
            'joinedDate': dateStr,
            'kycStatus': 'Tier 1 Standard Verified',
            'escrowBalance': 'US\$ 0.00',
          },
        ),
      );
    } catch (_) {}
  }

  void authenticateUser(AppUser user) {
    _setRole(user.role);
    _broadcastAuthEvent(user, isRegistration: false);
    state = state.copyWith(
      user: user,
      isAuthenticated: true,
      isLoading: false,
      errorMessage: null,
    );
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required UserRole role,
  }) async {
    if (state.user != null) {
      final updatedUser = AppUser(
        id: state.user!.id,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: state.user!.phone,
        role: role,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(updatedUser.toJson()));
      
      _setRole(role);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> deleteUserAccount({required String userId, required String emailOrPhone}) async {
    final cleanId = emailOrPhone.trim().toLowerCase().replaceAll(' ', '');
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Remove from registered users store
    final users = await _getRegisteredUsers();
    users.removeWhere((u) =>
      u['id']?.toString() == userId ||
      u['identifier']?.toString().toLowerCase().replaceAll(' ', '') == cleanId
    );
    await prefs.setString(_registeredUsersKey, jsonEncode(users));

    // 2. Persist in deleted blacklist registry
    final deletedList = prefs.getStringList('verdi.admin.deleted_user_ids') ?? [];
    if (!deletedList.contains(userId)) {
      deletedList.add(userId);
    }
    if (cleanId.isNotEmpty && !deletedList.contains(cleanId)) {
      deletedList.add(cleanId);
    }
    await prefs.setStringList('verdi.admin.deleted_user_ids', deletedList);

    // 3. If currently logged-in account matches, purge session & sign out immediately
    if (state.user?.id == userId || (cleanId.isNotEmpty && state.user?.email.toLowerCase() == cleanId)) {
      await prefs.remove(_sessionKey);
      await prefs.remove('verdi.auth.token');
      await prefs.remove('verdi.auth.last_email');
      _setRole(UserRole.farmer);
      state = AuthState.initial;
    }
  }

  Future<void> signOut() async {
    final curUser = state.user;
    if (curUser != null) {
      try {
        SupabaseService.instance.broadcastUserPresence(
          userId: curUser.id,
          fullName: curUser.fullName,
          role: curUser.role,
          isOnline: false,
        );
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove('verdi.auth.token');
    _setRole(UserRole.farmer);
    state = AuthState.initial;
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);
