import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../assistant/services/shona_speech_service.dart';
import '../../../assistant/services/verdi_agro_autonomous_agent.dart';
import '../../../assistant/presentation/widgets/modal_shona_stt_dialog.dart';
import '../../../../state/chat_state.dart';
import '../../../../state/app_state.dart';

class NativeVoiceConsoleWidget extends ConsumerStatefulWidget {
  const NativeVoiceConsoleWidget({super.key});

  @override
  ConsumerState<NativeVoiceConsoleWidget> createState() => _NativeVoiceConsoleWidgetState();
}

class _NativeVoiceConsoleWidgetState extends ConsumerState<NativeVoiceConsoleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  bool _isListening = false;
  String _selectedPersona = 'Kari';
  String _liveTranscript = '';

  static const _green = Color(0xFF16A34A);
  static const _teal = Color(0xFF0F766E);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  final List<Map<String, String>> _hdVoices = [
    {'name': 'Kari', 'title': 'Warm Female Agronomist', 'desc': 'Hyper-realistic female voice'},
    {'name': 'Echo', 'title': 'Trade & Market Specialist', 'desc': 'Clear natural male voice'},
    {'name': 'Nova', 'title': 'Energetic Field Advisor', 'desc': 'Fluent advisory voice'},
    {'name': 'Onyx', 'title': 'Deep Diagnostics Lead', 'desc': 'Deep analytical voice'},
    {'name': 'Alloy', 'title': 'Balanced Conversational', 'desc': 'Smooth natural voice'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    ShonaSpeechService.instance.stopListening();
    ShonaSpeechService.instance.stopShona();
    super.dispose();
  }

  void _toggleMic() {
    if (_isListening) {
      ShonaSpeechService.instance.stopListening();
      setState(() {
        _isListening = false;
        _liveTranscript = '';
      });
    } else {
      ShonaSpeechService.instance.startListeningWithVad(
        onResult: (text) {
          setState(() {
            _liveTranscript = text;
          });
        },
        onAutoSubmit: () {
          if (_liveTranscript.trim().isNotEmpty) {
            _submitVoicePrompt(_liveTranscript.trim());
          }
        },
        onStatus: (listening) {
          setState(() {
            _isListening = listening;
          });
        },
      );
    }
  }

  Future<void> _submitVoicePrompt(String prompt) async {
    if (prompt.isEmpty) return;

    final notifier = ref.read(verdiAiChatProvider.notifier);
    notifier.sendMessage(prompt);
    setState(() {
      _liveTranscript = '';
      _isListening = false;
    });

    // Process voice prompt via Autonomous Agent for action routing and speech feedback
    final agentResult = await VerdiAgroAutonomousAgent.instance.processAutonomousCommand(prompt);

    if (mounted && agentResult.navIndex != null) {
      ref.read(appStateProvider.notifier).setNavIndex(agentResult.navIndex!);
    }

    notifier.receiveMessage(agentResult.responseSpeech);

    // Speak response using selected HD Voice Persona
    ShonaSpeechService.instance.speakShona(
      agentResult.responseSpeech,
      voicePersona: _selectedPersona,
    );
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(verdiAiChatProvider);

    return Container(
      color: _dark,
      child: Column(
        children: [
          // Top Control & Voice Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(bottom: BorderSide(color: Color(0xFF334155))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_green, _teal]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verdi Native HD Voice Console',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'State-of-the-Art Multilingual Audio Engine',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
                const Spacer(),
                // Dedicated Modal Shona STT Launcher Button
                ElevatedButton.icon(
                  onPressed: () => ModalShonaSttDialog.show(context),
                  icon: const Icon(Icons.bolt_rounded, size: 15),
                  label: const Text('⚡ Modal Shona STT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                // Voice Persona Selector Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPersona,
                      dropdownColor: const Color(0xFF1E293B),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPersona = val);
                      },
                      items: _hdVoices.map((v) {
                        return DropdownMenuItem<String>(
                          value: v['name'],
                          child: Row(
                            children: [
                              const Icon(Icons.record_voice_over_outlined, size: 14, color: _green),
                              const SizedBox(width: 6),
                              Text('${v['name']} (${v['title']})'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Central Voice Visualizer Canvas
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing Voice Orb & Waveform Visualizer
                      GestureDetector(
                        onTap: _toggleMic,
                        child: AnimatedBuilder(
                          animation: _animCtrl,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _VoiceOrbPainter(
                                progress: _animCtrl.value,
                                isActive: _isListening,
                              ),
                              child: SizedBox(
                                width: 130,
                                height: 130,
                                child: Center(
                                  child: Icon(
                                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Animated Voice Waveform Visualizer Bars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(9, (idx) {
                          final h = 6.0 + math.sin(_animCtrl.value * math.pi * 2 + idx * 0.7).abs() * (_isListening ? 26.0 : 8.0);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: 3.5,
                            height: h,
                            decoration: BoxDecoration(
                              color: _isListening ? const Color(0xFF4ADE80) : const Color(0xFF475569),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isListening ? 'Listening for English Voice Command...' : 'Tap Orb or Mic to Talk Hands-Free',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _isListening ? const Color(0xFF4ADE80) : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isListening
                            ? '⚡ Auto-submits after 1.8s pause'
                            : 'Voice Activity Detection (VAD) Active',
                        style: GoogleFonts.inter(fontSize: 11.5, color: _muted),
                      ),
                      if (_liveTranscript.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            '“$_liveTranscript”',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF86EFAC),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFF334155)),

          // Live Transcript Chat Feed
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(0xFF0B132B),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: thread.messages.length,
                itemBuilder: (context, index) {
                  final msg = thread.messages[index];
                  final isUser = msg.isUser;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isUser
                            ? const LinearGradient(colors: [_green, _teal])
                            : null,
                        color: isUser ? null : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: isUser ? null : Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isUser ? 'You' : 'Verdi AI ($_selectedPersona)',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isUser ? Colors.white70 : const Color(0xFF4ADE80),
                                ),
                              ),
                              if (!isUser) ...[
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    ShonaSpeechService.instance.speakShona(
                                      msg.text,
                                      voicePersona: _selectedPersona,
                                    );
                                  },
                                  child: const Icon(Icons.volume_up_rounded, size: 14, color: Colors.white70),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg.text,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering pulsing animated 3D voice orb.
class _VoiceOrbPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _VoiceOrbPainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    if (isActive) {
      for (int i = 3; i >= 1; i--) {
        final radius = baseRadius + (i * 12 * math.sin(progress * math.pi * 2 + i));
        final paint = Paint()
          ..color = const Color(0xFF16A34A).withOpacity(0.2 / i)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, radius, paint);
      }
    }

    final mainPaint = Paint()
      ..shader = RadialGradient(
        colors: isActive
            ? [const Color(0xFF22C55E), const Color(0xFF0F766E)]
            : [const Color(0xFF334155), const Color(0xFF1E293B)],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    canvas.drawCircle(center, baseRadius * 0.75, mainPaint);
  }

  @override
  bool shouldRepaint(covariant _VoiceOrbPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}
