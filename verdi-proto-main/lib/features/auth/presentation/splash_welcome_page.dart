import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../app_shell.dart';
import '../state/auth_state.dart';
import '../../../widgets/verdi_logo.dart';
import 'speech_helper.dart';

class SplashWelcomePage extends ConsumerStatefulWidget {
  const SplashWelcomePage({super.key});

  @override
  ConsumerState<SplashWelcomePage> createState() => _SplashWelcomePageState();
}

class _SplashWelcomePageState extends ConsumerState<SplashWelcomePage> with SingleTickerProviderStateMixin {
  bool _completed = false;
  Timer? _timer;
  late AnimationController _waveController;
  bool _voiceEnabled = true;
  FlutterTts? _flutterTts;
  bool _briefingStarted = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    try {
      _flutterTts = FlutterTts();
      _flutterTts?.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _completed = true;
          });
        }
      });
    } catch (e) {
      debugPrint('Failed to initialize FlutterTts: $e');
      _flutterTts = null;
      _voiceEnabled = false;
    }

    // Auto-start briefing on mobile; Web must wait for user tap to satisfy browser policy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        setState(() {
          _briefingStarted = true;
        });
        _speakWelcome();
        
        // Safety Fallback Timers for Mobile:
        if (!_voiceEnabled || _flutterTts == null) {
          // If TTS is disabled/failed, auto-skip to console in 1.5 seconds
          _timer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted && !_completed) {
              setState(() {
                _completed = true;
              });
            }
          });
        } else {
          // If TTS is working, set a safety fallback of 12 seconds to prevent being stuck forever
          _timer = Timer(const Duration(seconds: 12), () {
            if (mounted && !_completed) {
              setState(() {
                _completed = true;
              });
            }
          });
        }
      }
    });
  }

  Future<void> _speakWelcome() async {
    final authState = ref.read(authStateProvider);
    final userName = authState.user?.fullName ?? 'Operator';
    
    final greetingText = '${_greeting()}, $userName. Welcome back to Verdi. Here is your morning briefing summary: ';
    const briefingText = 'First, three high stress zones require drone review. Second, irrigation is scheduled for Field 4 in two hours. Third, two supplier export permits have been approved. Launching your dashboard now.';
    final fullText = greetingText + briefingText;

    if (!_voiceEnabled) return;

    // Stop any existing speech before starting a new one
    try {
      _flutterTts?.stop();
    } catch (_) {}
    stopWebPlatform();

    if (kIsWeb) {
      speakWebPlatform(fullText);
      return;
    }
    
    try {
      await _flutterTts?.setLanguage("en-US");
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setPitch(0.85);
      await _flutterTts?.setSpeechRate(0.45);

      try {
        final voices = await _flutterTts?.getVoices;
        if (voices != null) {
          for (final voice in voices) {
            final Map map = voice is Map ? voice : {};
            final name = (map['name'] ?? '').toString().toLowerCase();
            final locale = (map['locale'] ?? map['lang'] ?? '').toString().toLowerCase();

            // Exclude female voice names
            if (name.contains('female') || name.contains('zira') || name.contains('aria') || 
                name.contains('samantha') || name.contains('victoria') || name.contains('jenny') || 
                name.contains('google us english')) {
              continue;
            }

            if (locale.startsWith('en') && 
                (name.contains('male') || name.contains('david') || name.contains('guy') || 
                 name.contains('mark') || name.contains('george') || name.contains('james') || 
                 name.contains('brian') || name.contains('daniel'))) {
              await _flutterTts?.setVoice(Map<String, String>.from(map.cast<String, String>()));
              break;
            }
          }
        }
      } catch (_) {}

      await _flutterTts?.speak(fullText);
    } catch (e) {
      debugPrint('Desktop TTS error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    try {
      _flutterTts?.stop();
    } catch (_) {}
    stopWebPlatform();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    if (_completed || kIsWeb) {
      return const AppShell();
    }

    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final userName = user?.fullName ?? 'Operator';
    final role = user?.role;
    final roleLabel = role?.label ?? 'Platform Admin';
    final orgName = 'Eastern Highlands Produce';
    final location = 'Harare, Zimbabwe';

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Image overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/agriculture_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xDD0F172A), Color(0x991E293B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo / Brand
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const VerdiLogo(size: 32),
                          const SizedBox(width: 8),
                          Text(
                            'VERDI',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),

                      // Greetings Card
                      Card(
                        color: Colors.white.withOpacity(0.92),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _TypewriterText(
                                text: '${_greeting()},',
                                duration: const Duration(milliseconds: 1000),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              _TypewriterText(
                                text: userName,
                                duration: const Duration(milliseconds: 1800),
                                style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF16A34A).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      roleLabel,
                                      style: const TextStyle(
                                        color: Color(0xFF16A34A),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '• $orgName • $location',
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 32, color: Colors.black12),

                              // Voice Welcome Message Wave
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _voiceEnabled = !_voiceEnabled;
                                      });
                                      if (!_voiceEnabled) {
                                        _flutterTts?.stop();
                                        stopWebPlatform();
                                      } else {
                                        _speakWelcome();
                                      }
                                    },
                                    icon: Icon(
                                      _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _voiceEnabled
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Synthesizing operational briefing...',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF16A34A),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              _buildWaveAnimation(),
                                            ],
                                          )
                                        : const Text(
                                            'Voice assistant welcome is muted.',
                                            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Urgent Alerts & Updates Summary Card
                      Card(
                        color: Colors.black.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.white10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notifications_active_outlined, color: Colors.amber, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Morning Briefing Summary',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildSummaryItem(
                                icon: Icons.warning_amber_outlined,
                                color: Colors.amber,
                                text: '3 high-stress zones require drone review',
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryItem(
                                icon: Icons.water_drop_outlined,
                                color: Colors.blue.shade400,
                                text: 'Irrigation scheduled for Field 4 in 2h',
                              ),
                              const SizedBox(height: 8),
                              _buildSummaryItem(
                                icon: Icons.check_circle_outline,
                                color: const Color(0xFF16A34A),
                                text: '2 supplier export permits approved',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Loading & Skip
                      if (!_briefingStarted && kIsWeb)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _briefingStarted = true;
                              });
                              _speakWelcome();
                              _timer = Timer(const Duration(seconds: 12), () {
                                if (mounted && !_completed) {
                                  setState(() {
                                    _completed = true;
                                  });
                                }
                              });
                            },
                            icon: const Icon(Icons.play_circle_fill_outlined, size: 20),
                            label: const Text(
                              'Initialize Console & Play Briefing',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF16A34A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Playing briefing...',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                _flutterTts?.stop();
                                stopWebPlatform();
                                setState(() {
                                  _completed = true;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Row(
                                children: const [
                                  Text('Skip to Console', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4),
                                  Icon(Icons.skip_next, size: 16),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildSummaryItem({required IconData icon, required Color color, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: _TypewriterText(
            text: text,
            duration: const Duration(milliseconds: 2200),
            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveAnimation() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          height: 12,
          child: Row(
            children: List.generate(14, (index) {
              final waveHeight = 2 + (8 * (index % 3 + 1) * _waveController.value);
              return Container(
                width: 3,
                height: waveHeight.clamp(2.0, 12.0),
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typewriter Text Animation Widget
// ─────────────────────────────────────────────────────────────────────────────

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const _TypewriterText({
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 3000),
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _characterCount = StepTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _characterCount = StepTween(begin: 0, end: widget.text.length).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final count = _characterCount.value.clamp(0, widget.text.length);
        final displayedText = widget.text.substring(0, count);
        final isDone = count >= widget.text.length;

        return RichText(
          text: TextSpan(
            children: [
              TextSpan(text: displayedText, style: widget.style),
              if (!isDone)
                TextSpan(
                  text: '▌',
                  style: widget.style.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
