import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/auth_state.dart';

/// Full-screen 2FA / TOTP Authenticator challenge screen.
class Totp2faVerificationScreen extends ConsumerStatefulWidget {
  const Totp2faVerificationScreen({super.key});

  @override
  ConsumerState<Totp2faVerificationScreen> createState() => _Totp2faVerificationScreenState();
}

class _Totp2faVerificationScreenState extends ConsumerState<Totp2faVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _showSecretKey = false;
  Timer? _countdownTimer;
  int _secondsRemaining = 30;

  static const bgDark = Color(0xFF0B1120);
  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentBlue = Color(0xFF3B82F6);
  static const textMuted = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    setState(() {
      _secondsRemaining = 30 - (nowSec % 30);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() {
    final code = _codeController.text.trim();
    if (code.length == 6) {
      ref.read(authStateProvider.notifier).verify2faCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final pendingUser = authState.pendingUser;
    final secret = authState.totpSecret ?? 'VERDI2FASECRETKEY2026';
    final userEmail = pendingUser?.email ?? 'operator@verdi.ag';
    final otpauthUri = 'otpauth://totp/Verdi:$userEmail?secret=$secret&issuer=Verdi';
    final isLoading = authState.isLoading;
    final errorMessage = authState.errorMessage;

    return Scaffold(
      backgroundColor: bgDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: accentBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentBlue.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.phonelink_lock, color: accentBlue, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  'Two-Factor Authentication',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit verification code from your Google Authenticator, Authy, or 1Password app for ${pendingUser?.fullName ?? "your account"}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 24),

                // 6-digit Code Input
                TextField(
                  controller: _codeController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    hintStyle: const TextStyle(color: Color(0xFF475569), letterSpacing: 12),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: cardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: cardBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: accentBlue, width: 2)),
                  ),
                  onChanged: (val) {
                    if (val.trim().length == 6) {
                      _submitCode();
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Live TOTP Freshness Timer Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        value: _secondsRemaining / 30.0,
                        strokeWidth: 2.2,
                        backgroundColor: Colors.white12,
                        color: _secondsRemaining <= 5 ? const Color(0xFFEF4444) : accentGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Code refreshes in ${_secondsRemaining}s',
                      style: TextStyle(
                        fontSize: 12,
                        color: _secondsRemaining <= 5 ? const Color(0xFFEF4444) : textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Verify & Authenticate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 16),

                // QR / Secret Setup Helper
                TextButton.icon(
                  onPressed: () => setState(() => _showSecretKey = !_showSecretKey),
                  icon: Icon(_showSecretKey ? Icons.visibility_off : Icons.key, size: 16, color: accentBlue),
                  label: Text(_showSecretKey ? 'Hide Setup Credentials' : 'Setup Authenticator Key', style: const TextStyle(color: accentBlue, fontSize: 12)),
                ),

                if (_showSecretKey) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Base32 Secret for Authenticator App:',
                          style: TextStyle(color: textMuted, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          secret,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: accentGreen, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: secret));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('2FA Secret Key copied to clipboard!'), backgroundColor: accentGreen),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 13, color: Colors.white),
                              label: const Text('Copy Secret Key', style: TextStyle(color: Colors.white, fontSize: 11)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: cardBorder)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: otpauthUri));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Authenticator Setup URI copied to clipboard!'), backgroundColor: accentBlue),
                                );
                              },
                              icon: const Icon(Icons.link, size: 13, color: accentBlue),
                              label: const Text('Copy otpauth URI', style: TextStyle(color: accentBlue, fontSize: 11)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: cardBorder)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).cancel2fa();
                  },
                  child: const Text('Cancel & Return to Login', style: TextStyle(color: textMuted, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
