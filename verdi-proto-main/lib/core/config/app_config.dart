import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized configuration service for Verdi.
/// Supports compile-time environment variables (--dart-define),
/// runtime SharedPreferences overrides, and production defaults.
class AppConfig {
  AppConfig._();
  static final AppConfig instance = AppConfig._();

  // Environment variable keys (pass via --dart-define=KEY=value)
  static const String _envKeySupabaseUrl = 'SUPABASE_URL';
  static const String _envKeySupabaseAnonKey = 'SUPABASE_ANON_KEY';
  static const String _envKeyBackendUrl = 'BACKEND_URL';
  static const String _envKeyEnvironment = 'ENVIRONMENT';
  static const String _envKeyDemoMode = 'DEFAULT_DEMO_MODE';

  // Local storage override keys
  static const String _prefUrlKey = 'verdi.supabase.url';
  static const String _prefAnonKey = 'verdi.supabase.anon_key';
  static const String _prefBackendUrlKey = 'verdi.backend.url';

  // Production defaults
  static const String _defaultSupabaseUrl = 'https://ctlczfokxexgxwtdztbu.supabase.co';
  static const String _defaultSupabaseAnonKey =
      'sb_publishable_QcurCLLt4o6GZjcD-NOKEQ_gLYQcrU1';
  static const String _defaultProductionBackendUrl = 'https://api.verdiagritech.com';

  String? _cachedSupabaseUrl;
  String? _cachedSupabaseAnonKey;
  String? _cachedBackendUrl;
  bool _initialized = false;

  /// Initializes the config and loads persisted user overrides.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedSupabaseUrl = prefs.getString(_prefUrlKey);
      _cachedSupabaseAnonKey = prefs.getString(_prefAnonKey);
      _cachedBackendUrl = prefs.getString(_prefBackendUrlKey);
    } catch (e) {
      debugPrint('AppConfig initialization warning: $e');
    }
    _initialized = true;
  }

  /// Environment Name: 'production', 'staging', 'development'
  String get environment {
    return const String.fromEnvironment(_envKeyEnvironment, defaultValue: 'production');
  }

  bool get isProduction => environment.toLowerCase() == 'production';
  bool get isDevelopment => environment.toLowerCase() == 'development';

  /// Whether demo mode is enabled by default
  bool get defaultDemoMode {
    return const bool.fromEnvironment(_envKeyDemoMode, defaultValue: false);
  }

  /// Supabase Project URL
  String get supabaseUrl {
    if (_cachedSupabaseUrl != null && _cachedSupabaseUrl!.isNotEmpty) {
      return _sanitizeUrl(_cachedSupabaseUrl!);
    }
    const envUrl = String.fromEnvironment(_envKeySupabaseUrl);
    if (envUrl.isNotEmpty) {
      return _sanitizeUrl(envUrl);
    }
    return _sanitizeUrl(_defaultSupabaseUrl);
  }

  /// Supabase Anon / Publishable Key
  String get supabaseAnonKey {
    if (_cachedSupabaseAnonKey != null && _cachedSupabaseAnonKey!.isNotEmpty) {
      return _cachedSupabaseAnonKey!.trim();
    }
    const envKey = String.fromEnvironment(_envKeySupabaseAnonKey);
    if (envKey.isNotEmpty) {
      return envKey.trim();
    }
    return _defaultSupabaseAnonKey;
  }

  /// Verdi Core NestJS/Python Backend Base URL
  String get backendBaseUrl {
    if (_cachedBackendUrl != null && _cachedBackendUrl!.isNotEmpty) {
      return _sanitizeUrl(_cachedBackendUrl!);
    }
    const envUrl = String.fromEnvironment(_envKeyBackendUrl);
    if (envUrl.isNotEmpty) {
      return _sanitizeUrl(envUrl);
    }

    if (isProduction) {
      return _defaultProductionBackendUrl;
    }

    // Local development platform-aware fallback
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Android Emulator maps 10.0.2.2 to host machine localhost
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  /// Update custom Supabase credentials dynamically
  Future<void> setCustomSupabaseCredentials({String? url, String? anonKey}) async {
    final prefs = await SharedPreferences.getInstance();
    if (url != null) {
      _cachedSupabaseUrl = url;
      await prefs.setString(_prefUrlKey, url);
    }
    if (anonKey != null) {
      _cachedSupabaseAnonKey = anonKey;
      await prefs.setString(_prefAnonKey, anonKey);
    }
  }

  /// Update custom backend URL dynamically
  Future<void> setCustomBackendUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    _cachedBackendUrl = url;
    if (url != null) {
      await prefs.setString(_prefBackendUrlKey, url);
    } else {
      await prefs.remove(_prefBackendUrlKey);
    }
  }

  /// Clear all persisted runtime overrides
  Future<void> clearOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUrlKey);
    await prefs.remove(_prefAnonKey);
    await prefs.remove(_prefBackendUrlKey);
    _cachedSupabaseUrl = null;
    _cachedSupabaseAnonKey = null;
    _cachedBackendUrl = null;
  }

  static String _sanitizeUrl(String url) {
    var sanitized = url.trim();
    if (sanitized.endsWith('/rest/v1/')) {
      sanitized = sanitized.substring(0, sanitized.length - '/rest/v1/'.length);
    } else if (sanitized.endsWith('/rest/v1')) {
      sanitized = sanitized.substring(0, sanitized.length - '/rest/v1'.length);
    }
    if (sanitized.endsWith('/')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }
    return sanitized;
  }
}
