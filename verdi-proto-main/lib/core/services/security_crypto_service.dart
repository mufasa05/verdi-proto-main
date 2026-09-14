import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Cryptographic and Cyber-Defense Security Service for the Verdi Platform.
/// Handles salted key-derivation, constant-time verification, RFC 6238 TOTP (2FA),
/// anti-tamper seals, PIN hashing, and input sanitization.
class SecurityCryptoService {
  SecurityCryptoService._();
  static final SecurityCryptoService instance = SecurityCryptoService._();

  static final Random _secureRandom = Random.secure();

  // Internal secret pepper for system-level HMAC signing (fallback key)
  static const String _systemHmacKey = 'verdi_sovereign_security_seal_key_2026_v1';

  // ───────────────────────────────────────────────────────────────────────────
  // 1. PASSWORD & PIN HASHING WITH CONSTANT-TIME VERIFICATION
  // ───────────────────────────────────────────────────────────────────────────

  /// Generates a cryptographically secure random salt in hex representation
  String generateSalt([int lengthBytes = 16]) {
    final bytes = Uint8List(lengthBytes);
    for (int i = 0; i < lengthBytes; i++) {
      bytes[i] = _secureRandom.nextInt(256);
    }
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Generates a salted PBKDF2-like iterated HMAC-SHA256 hash for passwords
  String hashPassword(String password, String salt, {int iterations = 10000}) {
    final keyBytes = utf8.encode(salt);
    List<int> currentBytes = utf8.encode(password);

    // Iterated HMAC-SHA256 key stretching
    for (int i = 0; i < iterations; i++) {
      final hmac = Hmac(sha256, keyBytes);
      currentBytes = hmac.convert(currentBytes).bytes;
    }

    return currentBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Verifies a plain-text password against a stored salt and hash in constant time
  bool verifyPassword({
    required String plainPassword,
    required String salt,
    required String storedHash,
    int iterations = 10000,
  }) {
    final computedHash = hashPassword(plainPassword, salt, iterations: iterations);
    return _constantTimeEquals(computedHash, storedHash);
  }

  /// Hashes a 4-to-6 digit security PIN
  String hashPin(String pin, String salt) {
    return hashPassword(pin, 'pin_$salt', iterations: 5000);
  }

  /// Verifies a security PIN in constant time
  bool verifyPin({
    required String pin,
    required String salt,
    required String storedHash,
  }) {
    final computedHash = hashPin(pin, salt);
    return _constantTimeEquals(computedHash, storedHash);
  }

  /// Constant-time string comparison to prevent timing side-channel attacks
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. TWO-FACTOR AUTHENTICATION (RFC 6238 TOTP ENGINE)
  // ───────────────────────────────────────────────────────────────────────────

  static const String _base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  /// Generates a random Base32 TOTP secret key for Google Authenticator / Authy
  String generateTotpSecret([int byteLength = 20]) {
    final bytes = Uint8List(byteLength);
    for (int i = 0; i < byteLength; i++) {
      bytes[i] = _secureRandom.nextInt(256);
    }
    return _base32Encode(bytes);
  }

  /// Generates a 6-digit TOTP code for a given timestamp step (default 30-sec window)
  String generateTotpCode(String base32Secret, {int? timeInterval}) {
    final secretBytes = _base32Decode(base32Secret);
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final interval = timeInterval ?? (nowSeconds ~/ 30);

    // Convert interval to 8-byte big-endian
    final msg = Uint8List(8);
    var temp = interval;
    for (int i = 7; i >= 0; i--) {
      msg[i] = temp & 0xff;
      temp = temp >> 8;
    }

    final hmac = Hmac(sha1, secretBytes);
    final hash = hmac.convert(msg).bytes;

    final offset = hash[hash.length - 1] & 0xf;
    final binary = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);

    final otp = binary % 1000000;
    return otp.toString().padLeft(6, '0');
  }

  /// Verifies a 6-digit TOTP code with standard ±1 time step tolerance (prevents drift rejection)
  bool verifyTotpCode({
    required String base32Secret,
    required String userCode,
    int toleranceSteps = 1,
  }) {
    final cleanCode = userCode.trim().replaceAll(' ', '');
    if (cleanCode.length != 6) return false;

    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final currentStep = nowSeconds ~/ 30;

    for (int stepOffset = -toleranceSteps; stepOffset <= toleranceSteps; stepOffset++) {
      final validOtp = generateTotpCode(base32Secret, timeInterval: currentStep + stepOffset);
      if (_constantTimeEquals(validOtp, cleanCode)) {
        return true;
      }
    }
    return false;
  }

  // Base32 helpers
  String _base32Encode(Uint8List data) {
    var result = '';
    int buffer = 0;
    int bitsLeft = 0;

    for (final byte in data) {
      buffer = (buffer << 8) | byte;
      bitsLeft += 8;
      while (bitsLeft >= 5) {
        bitsLeft -= 5;
        result += _base32Chars[(buffer >> bitsLeft) & 31];
      }
    }

    if (bitsLeft > 0) {
      buffer = buffer << (5 - bitsLeft);
      result += _base32Chars[buffer & 31];
    }

    return result;
  }

  Uint8List _base32Decode(String input) {
    final clean = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    final bytes = <int>[];
    int buffer = 0;
    int bitsLeft = 0;

    for (int i = 0; i < clean.length; i++) {
      final val = _base32Chars.indexOf(clean[i]);
      if (val < 0) continue;
      buffer = (buffer << 5) | val;
      bitsLeft += 5;
      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        bytes.add((buffer >> bitsLeft) & 255);
      }
    }

    return Uint8List.fromList(bytes);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. CRYPTOGRAPHIC INTEGRITY SEALS (ANTI-TAMPER FOR BATCHES & ESCROW)
  // ───────────────────────────────────────────────────────────────────────────

  /// Generates an HMAC-SHA256 digital integrity seal for traceability batches
  String generateBatchSeal({
    required String batchCode,
    required String farmId,
    required String harvestDate,
    required double quantity,
    required double latitude,
    required double longitude,
  }) {
    final canonicalPayload = '$batchCode|$farmId|$harvestDate|${quantity.toStringAsFixed(2)}|${latitude.toStringAsFixed(6)}|${longitude.toStringAsFixed(6)}';
    final hmac = Hmac(sha256, utf8.encode(_systemHmacKey));
    return hmac.convert(utf8.encode(canonicalPayload)).toString();
  }

  /// Validates that a traceability batch payload has not been tampered with
  bool verifyBatchSeal({
    required String batchCode,
    required String farmId,
    required String harvestDate,
    required double quantity,
    required double latitude,
    required double longitude,
    required String expectedSeal,
  }) {
    final computed = generateBatchSeal(
      batchCode: batchCode,
      farmId: farmId,
      harvestDate: harvestDate,
      quantity: quantity,
      latitude: latitude,
      longitude: longitude,
    );
    return _constantTimeEquals(computed, expectedSeal);
  }

  /// Generates a signed cryptographic seal for escrow transactions
  String generateEscrowSeal({
    required String orderId,
    required String buyerName,
    required String sellerName,
    required double amountUsd,
    required String nonce,
    required String timestamp,
  }) {
    final canonicalPayload = '$orderId|$buyerName|$sellerName|${amountUsd.toStringAsFixed(2)}|$nonce|$timestamp';
    final hmac = Hmac(sha256, utf8.encode(_systemHmacKey));
    return hmac.convert(utf8.encode(canonicalPayload)).toString();
  }

  /// Verifies an escrow transaction signature
  bool verifyEscrowSeal({
    required String orderId,
    required String buyerName,
    required String sellerName,
    required double amountUsd,
    required String nonce,
    required String timestamp,
    required String seal,
  }) {
    final computed = generateEscrowSeal(
      orderId: orderId,
      buyerName: buyerName,
      sellerName: sellerName,
      amountUsd: amountUsd,
      nonce: nonce,
      timestamp: timestamp,
    );
    return _constantTimeEquals(computed, seal);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. NONCES & REPLAY ATTACK PROTECTION
  // ───────────────────────────────────────────────────────────────────────────

  /// Generates a cryptographic one-time nonce
  String generateNonce([int lengthBytes = 16]) {
    final bytes = Uint8List(lengthBytes);
    for (int i = 0; i < lengthBytes; i++) {
      bytes[i] = _secureRandom.nextInt(256);
    }
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 5. INPUT SANITIZATION & DEFENSE-IN-DEPTH
  // ───────────────────────────────────────────────────────────────────────────

  /// Sanitizes generic text strings by stripping dangerous control chars & HTML tags
  String sanitizeInput(String input) {
    var clean = input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    clean = clean.replaceAll(RegExp(r'<[^>]*>'), '');
    return clean.trim();
  }

  /// Sanitizes potential HTML/Markdown injection characters
  String sanitizeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Validates password strength (min 8 chars, at least 1 digit or special char)
  bool isPasswordStrong(String password) {
    if (password.length < 8) return false;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasDigitOrSpecial = RegExp(r'[\d!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    return hasLetter && hasDigitOrSpecial;
  }
}
