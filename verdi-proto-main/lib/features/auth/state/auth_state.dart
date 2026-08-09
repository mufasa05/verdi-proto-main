import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:verdi/core/services/verdi_api_service.dart';
import '../../../state/app_state.dart';

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role.name,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
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
      _setRole(user.role);
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

  void enterOfflineDemoMode({required String email, required String fullName, required UserRole role}) {
    final mockUser = AppUser(
      id: 'usr_offline_${DateTime.now().millisecond}',
      fullName: fullName.isEmpty ? email.split('@').first : fullName,
      email: email.trim(),
      role: role,
    );

    _setRole(role);
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

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userJson = data['user'] as Map<String, dynamic>;

        final user = AppUser(
          id: userJson['id']?.toString() ?? '',
          fullName: userJson['fullName']?.toString() ?? '',
          email: userJson['email']?.toString() ?? '',
          role: UserRole.values.byName(userJson['role']?.toString() ?? 'farmer'),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
        await prefs.setString('verdi.auth.token', token);
        await prefs.setString('verdi.auth.last_email', email.trim());

        _setRole(user.role);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        String msg = 'Invalid email or password.';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody['message'] != null) {
            msg = errBody['message'].toString();
          }
        } catch (_) {}
        state = state.copyWith(
          isLoading: false,
          errorMessage: msg,
        );
        return false;
      }
    } catch (e) {
      // Auto-fallback to Offline Demo Mode if local backend is unreachable
      enterOfflineDemoMode(
        email: email.trim(),
        fullName: email.contains('@') ? email.split('@').first : 'Operator',
        role: UserRole.farmer,
      );
      return true;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName.trim(),
          'email': email.trim(),
          'password': password,
          'role': role.name,
        }),
      ).timeout(const Duration(milliseconds: 3000));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']?.toString() ?? '';
        final userJson = data['user'] as Map<String, dynamic>;

        final user = AppUser(
          id: userJson['id']?.toString() ?? '',
          fullName: userJson['fullName']?.toString() ?? '',
          email: userJson['email']?.toString() ?? '',
          role: UserRole.values.byName(userJson['role']?.toString() ?? 'farmer'),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
        await prefs.setString('verdi.auth.token', token);
        await prefs.setString('verdi.auth.last_email', email.trim());

        _setRole(user.role);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        );
        return true;
      } else {
        String msg = 'Registration failed.';
        try {
          final errBody = jsonDecode(response.body);
          if (errBody['message'] != null) {
            msg = errBody['message'].toString();
          }
        } catch (_) {}
        state = state.copyWith(
          isLoading: false,
          errorMessage: msg,
        );
        return false;
      }
    } catch (e) {
      // Auto-fallback to Offline Demo Mode if local backend is unreachable
      enterOfflineDemoMode(
        email: email.trim(),
        fullName: fullName.trim(),
        role: role,
      );
      return true;
    }
  }

  void authenticateUser(AppUser user) {
    _setRole(user.role);
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
        role: role,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(updatedUser.toJson()));
      
      _setRole(role);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> signOut() async {
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
