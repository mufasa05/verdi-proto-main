import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Immersive Transporter Splash & Welcoming Briefing Screen
class TransporterSplashScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const TransporterSplashScreen({super.key, required this.onContinue});

  @override
  State<TransporterSplashScreen> createState() => _TransporterSplashScreenState();
}

class _TransporterSplashScreenState extends State<TransporterSplashScreen> with SingleTickerProviderStateMixin {
  static const bgDark = Color(0xFF060B14);
  static const cardDark = Color(0xFF0D1626);
  static const amber = Color(0xFFFF9F1C);
  static const cyan = Color(0xFF00F0FF);
  static const green = Color(0xFF10B981);
  static const textMuted = Color(0xFF94A3B8);

  late AnimationController _pulseController;
  int _taglineIndex = 0;
  Timer? _taglineTimer;

  final List<String> _taglines = [
    '⚡ Hyper-Local Farmgate Aggregation Pools',
    '❄️ Live In-Transit Reefer Cold-Chain Telemetry (+2°C to +6°C)',
    '📦 Multi-Farmer Produce Batch QR Waybill Aggregation',
    '💳 Automated e-POD Smart Contract Escrow Settlements',
    '🛡️ SADC Cross-Border Corridors & EUDR Provenance Tracking',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _taglineTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (mounted) {
        setState(() {
          _taglineIndex = (_taglineIndex + 1) % _taglines.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _taglineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          // Background Radar Glow
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        amber.withOpacity(0.12 * _pulseController.value),
                        cyan.withOpacity(0.06 * _pulseController.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // High-Tech Radar Icon
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cardDark,
                          border: Border.all(color: amber.withOpacity(0.6), width: 2),
                          boxShadow: [
                            BoxShadow(color: amber.withOpacity(0.25), blurRadius: 20, spreadRadius: 2),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.local_shipping_rounded, color: amber, size: 44),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sovereign Carrier Badge Seal
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: amber.withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: amber),
                            SizedBox(width: 6),
                            Text('VERDI CARRIER OPERATING SYSTEM', style: TextStyle(color: amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Main Title
                      Text(
                        'Welcome to Verdi Logistics',
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Sovereign Agricultural Freight, Cold-Chain & Multi-Modal Value Chain Connectivity.',
                        style: GoogleFonts.inter(fontSize: 14, color: textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Dynamic Animated Telemetry Capability Ribbon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          key: ValueKey<int>(_taglineIndex),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: cyan.withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(color: cyan.withOpacity(0.1), blurRadius: 12),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: cyan)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _taglines[_taglineIndex],
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Feature Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoPill(
                              'Hyper-Local Pools',
                              'Short-trip farmgate aggregation via bikes, tricycles & light trucks.',
                              Icons.electric_rickshaw_outlined,
                              green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoPill(
                              'Bulk Reefer Haulage',
                              'Long-distance refrigerated haulage with live IoT cold-chain telemetry.',
                              Icons.ac_unit_outlined,
                              cyan,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // Launch Console Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: widget.onContinue,
                          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                          label: Text(
                            'Initialize Logistics Console',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: amber,
                            foregroundColor: bgDark,
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 11, color: textMuted, height: 1.3)),
        ],
      ),
    );
  }
}
