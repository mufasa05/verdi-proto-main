import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'security_crypto_service.dart';

class ApiKeySecretRecord {
  final String id;
  final String name;
  final String key;
  final String status; // 'ACTIVE', 'REVOKED', 'ROTATED'
  final String scope;
  final String lastRotated;

  ApiKeySecretRecord({
    required this.id,
    required this.name,
    required this.key,
    required this.status,
    required this.scope,
    required this.lastRotated,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'key': key,
    'status': status,
    'scope': scope,
    'lastRotated': lastRotated,
  };

  factory ApiKeySecretRecord.fromJson(Map<String, dynamic> json) => ApiKeySecretRecord(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? 'Secret Token',
    key: json['key']?.toString() ?? '',
    status: json['status']?.toString() ?? 'ACTIVE',
    scope: json['scope']?.toString() ?? 'Full Access',
    lastRotated: json['lastRotated']?.toString() ?? 'Initial',
  );

  ApiKeySecretRecord copyWith({
    String? name,
    String? key,
    String? status,
    String? scope,
    String? lastRotated,
  }) => ApiKeySecretRecord(
    id: id,
    name: name ?? this.name,
    key: key ?? this.key,
    status: status ?? this.status,
    scope: scope ?? this.scope,
    lastRotated: lastRotated ?? this.lastRotated,
  );
}

class IpFirewallRule {
  final String ip;
  final String action; // 'ALLOW', 'BLOCK'
  final String note;
  final String addedAt;

  IpFirewallRule({
    required this.ip,
    required this.action,
    required this.note,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'ip': ip,
    'action': action,
    'note': note,
    'addedAt': addedAt,
  };

  factory IpFirewallRule.fromJson(Map<String, dynamic> json) => IpFirewallRule(
    ip: json['ip']?.toString() ?? '',
    action: json['action']?.toString() ?? 'ALLOW',
    note: json['note']?.toString() ?? '',
    addedAt: json['addedAt']?.toString() ?? 'Just now',
  );
}

class SecurityIncidentEvent {
  final String id;
  final String time;
  final String severity; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final String title;
  final String ip;
  final String status; // 'BLOCKED', 'RATE_LIMITED', 'REJECTED', 'RESOLVED'

  SecurityIncidentEvent({
    required this.id,
    required this.time,
    required this.severity,
    required this.title,
    required this.ip,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'time': time,
    'severity': severity,
    'title': title,
    'ip': ip,
    'status': status,
  };

  factory SecurityIncidentEvent.fromJson(Map<String, dynamic> json) => SecurityIncidentEvent(
    id: json['id']?.toString() ?? '',
    time: json['time']?.toString() ?? 'Just now',
    severity: json['severity']?.toString() ?? 'LOW',
    title: json['title']?.toString() ?? 'Incident',
    ip: json['ip']?.toString() ?? 'Unknown IP',
    status: json['status']?.toString() ?? 'BLOCKED',
  );
}

/// Sovereign Enterprise Security Vault Service.
/// Manages live API keys, firewall IP filtering, master security PIN, and 2FA secrets.
class SecurityVaultService extends ChangeNotifier {
  SecurityVaultService._();
  static final SecurityVaultService instance = SecurityVaultService._();

  static const String _prefApiKeys = 'verdi.vault.api_keys_v2';
  static const String _prefIpRules = 'verdi.vault.ip_rules_v2';
  static const String _prefIncidents = 'verdi.vault.incidents_v2';
  static const String _prefMasterPinSalt = 'verdi.vault.pin_salt';
  static const String _prefMasterPinHash = 'verdi.vault.pin_hash';
  static const String _pref2faSecrets = 'verdi.vault.user_2fa_secrets';

  List<ApiKeySecretRecord> _apiKeys = [];
  List<IpFirewallRule> _ipRules = [];
  List<SecurityIncidentEvent> _incidents = [];
  bool _isLoaded = false;

  List<ApiKeySecretRecord> get apiKeys => List.unmodifiable(_apiKeys);
  List<IpFirewallRule> get ipRules => List.unmodifiable(_ipRules);
  List<SecurityIncidentEvent> get incidents => List.unmodifiable(_incidents);

  Future<void> initialize() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();

    // 1. Load API keys or initialize production defaults
    final rawKeys = prefs.getString(_prefApiKeys);
    if (rawKeys != null && rawKeys.isNotEmpty) {
      try {
        final List list = jsonDecode(rawKeys);
        _apiKeys = list.map((item) => ApiKeySecretRecord.fromJson(item)).toList();
      } catch (_) {
        _apiKeys = _getDefaultApiKeys();
      }
    } else {
      _apiKeys = _getDefaultApiKeys();
      await _saveApiKeys();
    }

    // 2. Load IP Rules
    final rawRules = prefs.getString(_prefIpRules);
    if (rawRules != null && rawRules.isNotEmpty) {
      try {
        final List list = jsonDecode(rawRules);
        _ipRules = list.map((item) => IpFirewallRule.fromJson(item)).toList();
      } catch (_) {
        _ipRules = _getDefaultIpRules();
      }
    } else {
      _ipRules = _getDefaultIpRules();
      await _saveIpRules();
    }

    // 3. Load Incidents
    final rawIncidents = prefs.getString(_prefIncidents);
    if (rawIncidents != null && rawIncidents.isNotEmpty) {
      try {
        final List list = jsonDecode(rawIncidents);
        _incidents = list.map((item) => SecurityIncidentEvent.fromJson(item)).toList();
      } catch (_) {
        _incidents = _getDefaultIncidents();
      }
    } else {
      _incidents = _getDefaultIncidents();
      await _saveIncidents();
    }

    // 4. Ensure default Master Security PIN exists (Default PIN: 2026)
    if (!prefs.containsKey(_prefMasterPinHash)) {
      final salt = SecurityCryptoService.instance.generateSalt();
      final hash = SecurityCryptoService.instance.hashPin('2026', salt);
      await prefs.setString(_prefMasterPinSalt, salt);
      await prefs.setString(_prefMasterPinHash, hash);
    }

    _isLoaded = true;
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // MASTER SECURITY PIN VALIDATION
  // ───────────────────────────────────────────────────────────────────────────

  Future<bool> verifyMasterPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_prefMasterPinSalt) ?? '';
    final storedHash = prefs.getString(_prefMasterPinHash) ?? '';

    if (salt.isEmpty || storedHash.isEmpty) {
      // If none set, default is 2026
      return pin == '2026';
    }

    return SecurityCryptoService.instance.verifyPin(
      pin: pin.trim(),
      salt: salt,
      storedHash: storedHash,
    );
  }

  Future<void> updateMasterPin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = SecurityCryptoService.instance.generateSalt();
    final hash = SecurityCryptoService.instance.hashPin(newPin.trim(), salt);
    await prefs.setString(_prefMasterPinSalt, salt);
    await prefs.setString(_prefMasterPinHash, hash);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2FA / TOTP ACCOUNT MANAGEMENT
  // ───────────────────────────────────────────────────────────────────────────

  Future<String> getOrCreateUser2faSecret(String userIdentifier) async {
    final cleanId = userIdentifier.toLowerCase().trim();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pref2faSecrets);
    Map<String, dynamic> secretsMap = {};
    if (raw != null && raw.isNotEmpty) {
      try {
        secretsMap = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {}
    }

    if (secretsMap.containsKey(cleanId)) {
      return secretsMap[cleanId].toString();
    }

    final newSecret = SecurityCryptoService.instance.generateTotpSecret();
    secretsMap[cleanId] = newSecret;
    await prefs.setString(_pref2faSecrets, jsonEncode(secretsMap));
    return newSecret;
  }

  Future<bool> verifyUser2faCode(String userIdentifier, String code) async {
    final secret = await getOrCreateUser2faSecret(userIdentifier);
    return SecurityCryptoService.instance.verifyTotpCode(
      base32Secret: secret,
      userCode: code,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // API KEY SECRET ROTATION & MANAGEMENT
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> rotateApiKey(String id) async {
    final index = _apiKeys.indexWhere((k) => k.id == id);
    if (index >= 0) {
      final prefix = _apiKeys[index].name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
      final newKey = '$prefix-sec-${SecurityCryptoService.instance.generateNonce(12)}';
      _apiKeys[index] = _apiKeys[index].copyWith(
        key: newKey,
        status: 'ACTIVE',
        lastRotated: 'Just now (${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')})',
      );
      await _saveApiKeys();
      notifyListeners();
    }
  }

  Future<void> revokeApiKey(String id) async {
    final index = _apiKeys.indexWhere((k) => k.id == id);
    if (index >= 0) {
      _apiKeys[index] = _apiKeys[index].copyWith(status: 'REVOKED');
      await _saveApiKeys();
      notifyListeners();
    }
  }

  Future<void> createApiKey(String name, String scope) async {
    final prefix = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
    final newRecord = ApiKeySecretRecord(
      id: 'KEY-${DateTime.now().millisecondsSinceEpoch % 10000}',
      name: name,
      key: '$prefix-sec-${SecurityCryptoService.instance.generateNonce(12)}',
      status: 'ACTIVE',
      scope: scope,
      lastRotated: 'Generated just now',
    );
    _apiKeys.insert(0, newRecord);
    await _saveApiKeys();
    notifyListeners();
  }

  Future<void> _saveApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_apiKeys.map((k) => k.toJson()).toList());
    await prefs.setString(_prefApiKeys, jsonStr);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // IP FIREWALL & ACCESS RULES
  // ───────────────────────────────────────────────────────────────────────────

  bool isIpBlocked(String ip) {
    return _ipRules.any((r) => r.ip.trim() == ip.trim() && r.action == 'BLOCK');
  }

  Future<void> addIpRule(String ip, String action, String note) async {
    _ipRules.removeWhere((r) => r.ip.trim() == ip.trim());
    _ipRules.insert(0, IpFirewallRule(
      ip: ip.trim(),
      action: action,
      note: note,
      addedAt: 'Just now',
    ));
    await _saveIpRules();
    notifyListeners();
  }

  Future<void> removeIpRule(String ip) async {
    _ipRules.removeWhere((r) => r.ip.trim() == ip.trim());
    await _saveIpRules();
    notifyListeners();
  }

  Future<void> _saveIpRules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_ipRules.map((r) => r.toJson()).toList());
    await prefs.setString(_prefIpRules, jsonStr);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // INCIDENT LOGGING & THREAT DESK
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> logSecurityIncident({
    required String title,
    required String ip,
    required String severity,
    required String status,
  }) async {
    final event = SecurityIncidentEvent(
      id: 'INC-${DateTime.now().millisecondsSinceEpoch % 10000}',
      time: 'Just now',
      severity: severity,
      title: title,
      ip: ip,
      status: status,
    );
    _incidents.insert(0, event);
    if (_incidents.length > 50) _incidents.removeLast();
    await _saveIncidents();
    notifyListeners();
  }

  Future<void> _saveIncidents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_incidents.map((i) => i.toJson()).toList());
    await prefs.setString(_prefIncidents, jsonStr);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // DEFAULTS
  // ───────────────────────────────────────────────────────────────────────────

  List<ApiKeySecretRecord> _getDefaultApiKeys() => [
    ApiKeySecretRecord(id: 'KEY-001', name: 'Verdi Backend AI Service Token', key: 'verdi-backend-ai-sec-9981a4b', status: 'ACTIVE', scope: 'Full LLM Backbone Access', lastRotated: '12 Aug 2026'),
    ApiKeySecretRecord(id: 'KEY-002', name: 'Copernicus Sentinel API', key: 'copernicus-auth-sec-8812c9e', status: 'ACTIVE', scope: 'Sentinel-2 Satellite Feed', lastRotated: '15 Aug 2026'),
    ApiKeySecretRecord(id: 'KEY-003', name: 'EcoCash Merchant Gateway API', key: 'ecocash-merchant-sec-7721ff0', status: 'ACTIVE', scope: 'Escrow Settlements & Webhooks', lastRotated: '18 Aug 2026'),
    ApiKeySecretRecord(id: 'KEY-004', name: 'AWS S3 Satellite Storage Vault', key: 'aws-s3-raster-sec-5542bb1', status: 'ACTIVE', scope: 'GeoTIFF & Multispectral Rasters', lastRotated: '19 Aug 2026'),
  ];

  List<IpFirewallRule> _getDefaultIpRules() => [
    IpFirewallRule(ip: '196.220.12.0/24', action: 'ALLOW', note: 'Harare Sovereign Data Center Node', addedAt: 'Permanent Rule'),
    IpFirewallRule(ip: '197.210.45.19', action: 'BLOCK', note: 'Brute-force SSH / Auth lock', addedAt: '2 hours ago'),
    IpFirewallRule(ip: '41.206.18.99', action: 'BLOCK', note: 'Suspicious Escrow Re-entry Attempt', addedAt: 'Yesterday'),
  ];

  List<SecurityIncidentEvent> _getDefaultIncidents() => [
    SecurityIncidentEvent(id: 'INC-9912', time: '10 mins ago', severity: 'MEDIUM', title: 'Failed KYC Document Hash Spoof Attempt', ip: '197.221.12.8', status: 'BLOCKED'),
    SecurityIncidentEvent(id: 'INC-8819', time: '1 hour ago', severity: 'LOW', title: 'Repeated Rate Limit Hit on Trade Endpoint', ip: '41.206.18.99', status: 'RATE_LIMITED'),
    SecurityIncidentEvent(id: 'INC-4412', time: 'Yesterday', severity: 'HIGH', title: 'Unverified EUDR Export Permit Attempt', ip: '196.220.14.2', status: 'REJECTED'),
  ];
}
