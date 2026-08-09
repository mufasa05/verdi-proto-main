import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../state/agent_state.dart';

class GlobalVoiceAgentOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalVoiceAgentOverlay({super.key, required this.child});

  @override
  ConsumerState<GlobalVoiceAgentOverlay> createState() => _GlobalVoiceAgentOverlayState();
}

class _GlobalVoiceAgentOverlayState extends ConsumerState<GlobalVoiceAgentOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  static const _dark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agentState = ref.watch(agentProvider);

    if (!agentState.isAgentModeOn) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,

        // Floating Hands-Free Voice Agent Banner & Orb
        Positioned(
          bottom: 24,
          right: 24,
          left: MediaQuery.of(context).size.width > 700 ? null : 24,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(28),
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: BoxDecoration(
                color: _dark.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: agentState.isListening ? const Color(0xFF4ADE80) : const Color(0xFF334155),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing 3D Voice Orb
                  GestureDetector(
                    onTap: () {
                      ref.read(agentProvider.notifier).startGlobalListening();
                    },
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _MiniVoiceOrbPainter(
                            progress: _pulseCtrl.value,
                            isActive: agentState.isListening,
                          ),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Agent Task Status & Live Transcript
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'VERDI AGENT MODE (V2)',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4ADE80),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          agentState.liveTranscript.isNotEmpty
                              ? '“${agentState.liveTranscript}”'
                              : agentState.currentTask.isNotEmpty
                                  ? agentState.currentTask
                                  : 'Say "Hey Verdi" + command...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Turn OFF Toggle Button
                  IconButton(
                    icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'Turn Agent Mode OFF',
                    onPressed: () {
                      ref.read(agentProvider.notifier).toggleAgentMode();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniVoiceOrbPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _MiniVoiceOrbPainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    if (isActive) {
      final pulseRadius = baseRadius + (6 * math.sin(progress * math.pi * 2));
      final ringPaint = Paint()
        ..color = const Color(0xFF22C55E).withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, pulseRadius, ringPaint);
    }

    final orbPaint = Paint()
      ..shader = RadialGradient(
        colors: isActive
            ? [const Color(0xFF22C55E), const Color(0xFF0F766E)]
            : [const Color(0xFF475569), const Color(0xFF1E293B)],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    canvas.drawCircle(center, baseRadius * 0.8, orbPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniVoiceOrbPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}
