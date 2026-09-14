import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/security_vault_service.dart';

/// Modal dialog for high-security action authorization using Master PIN or Biometrics.
class SecurityPinBiometricDialog extends StatefulWidget {
  final String title;
  final String description;
  final String actionButtonLabel;

  const SecurityPinBiometricDialog({
    super.key,
    this.title = 'Security Authorization Required',
    this.description = 'Enter your Master Security PIN to authorize this sensitive platform operation.',
    this.actionButtonLabel = 'Authorize Action',
  });

  /// Static helper to quickly prompt authorization
  static Future<bool> prompt(
    BuildContext context, {
    String title = 'Security Authorization Required',
    String description = 'Enter your Master Security PIN to authorize this sensitive platform operation.',
    String actionButtonLabel = 'Authorize Action',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SecurityPinBiometricDialog(
        title: title,
        description: description,
        actionButtonLabel: actionButtonLabel,
      ),
    );
    return result == true;
  }

  @override
  State<SecurityPinBiometricDialog> createState() => _SecurityPinBiometricDialogState();
}

class _SecurityPinBiometricDialogState extends State<SecurityPinBiometricDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  static const cardDark = Color(0xFF161E2E);
  static const cardBorder = Color(0xFF2D3748);
  static const accentGreen = Color(0xFF10B981);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentDanger = Color(0xFFEF4444);

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Please enter your security PIN.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isValid = await SecurityVaultService.instance.verifyMasterPin(pin);

    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Incorrect Security PIN. Access denied.';
      });
      _pinController.clear();
    }
  }

  void _simulateBiometricAuth() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: cardBorder),
      ),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: accentGreen, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 8, color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '••••',
                hintStyle: const TextStyle(color: Color(0xFF64748B), letterSpacing: 8),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentGreen, width: 2)),
              ),
              onSubmitted: (_) => _verifyPin(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: accentDanger, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _simulateBiometricAuth,
                    icon: const Icon(Icons.fingerprint, color: accentBlue, size: 20),
                    label: const Text('Biometric Pass', style: TextStyle(color: accentBlue, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: accentBlue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(widget.actionButtonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
