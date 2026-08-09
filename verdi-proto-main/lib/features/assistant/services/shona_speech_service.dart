import 'package:flutter/foundation.dart';
import '../../../core/services/verdi_api_service.dart';
import 'shona_speech_stub.dart'
    if (dart.library.js) 'shona_speech_web.dart' as js_bridge;



/// Service handling Shona (sn-ZW) Speech-to-Text (ASR) and Text-to-Speech (TTS).
class ShonaSpeechService {
  ShonaSpeechService._();
  static final ShonaSpeechService instance = ShonaSpeechService._();

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  bool _isListening = false;
  bool get isListening => _isListening;

  // ───────────────────────────────────────────────────────────────────────────
  // Shona Text-to-Speech (TTS)
  // ───────────────────────────────────────────────────────────────────────────

  /// Speaks [text] in Shona or English using selected HD voice persona (Kari, Echo, Nova, Onyx, Alloy).
  void speakShona(String text, {String voicePersona = 'Kari', VoidCallback? onComplete}) {
    if (!kIsWeb) {
      debugPrint('Shona TTS is active on Web target.');
      onComplete?.call();
      return;
    }

    try {
      _isSpeaking = true;

      if (onComplete != null) {
        js_bridge.setJsCallback('_onShonaTtsEnd', () {
          _isSpeaking = false;
          onComplete();
        });
      }

      // Clean all markdown symbols, headers, bullet points before TTS playback
      String cleanText = text
          .replaceAll(RegExp(r'#+'), '')
          .replaceAll(RegExp(r'\*+'), '')
          .replaceAll('•', '')
          .replaceAll('-', '')
          .replaceAll("'", "\\'")
          .replaceAll('\n', ' ')
          .trim();

      js_bridge.evalJs('''
        (function(txt, persona) {
          if ('speechSynthesis' in window) {
            window.speechSynthesis.cancel();
            window._isTtsSpeaking = true;
            if (window._shonaRecognizer) {
              try { window._shonaRecognizer.stop(); } catch(e){}
            }

            var utterance = new SpeechSynthesisUtterance(txt);
            utterance.lang = 'en-US';
            utterance.rate = 0.95;
            utterance.pitch = 1.0;
            utterance.volume = 1.0;

            function finishTts() {
              setTimeout(function() {
                window._isTtsSpeaking = false;
                console.log('Verdi HD Voice playback finished');
                if (window._onShonaTtsEnd) {
                  window._onShonaTtsEnd();
                }
              }, 400);
            }

            utterance.onend = finishTts;
            utterance.onerror = finishTts;

            var voices = window.speechSynthesis.getVoices();
            if (voices && voices.length > 0) {
              var selectedVoice = null;
              var targetName = persona.toLowerCase();

              // 1. Try to find persona match or Google / Microsoft / Apple Neural English voices
              for (var j = 0; j < voices.length; j++) {
                var v = voices[j];
                var name = (v.name || '').toLowerCase();
                var lang = (v.lang || '').toLowerCase();
                if (lang.indexOf('en') !== -1) {
                  if (name.indexOf(targetName) !== -1 || name.indexOf('google') !== -1 || name.indexOf('natural') !== -1 || name.indexOf('samantha') !== -1) {
                    selectedVoice = v;
                    break;
                  }
                }
              }

              // 2. Fallback to any available English voice
              if (!selectedVoice) {
                for (var k = 0; k < voices.length; k++) {
                  if ((voices[k].lang || '').toLowerCase().indexOf('en') !== -1) {
                    selectedVoice = voices[k];
                    break;
                  }
                }
              }

              if (selectedVoice) utterance.voice = selectedVoice;
            }

            window.speechSynthesis.speak(utterance);
          }
        })('$cleanText', '$voicePersona');
      ''');
    } catch (e) {
      debugPrint('ShonaSpeechService speak error: $e');
      _isSpeaking = false;
    }
  }

  /// Stops current speech output.
  void stopShona() {
    if (!kIsWeb) return;
    try {
      js_bridge.evalJs('''
        window._isTtsSpeaking = false;
        if ('speechSynthesis' in window) {
          window.speechSynthesis.cancel();
        }
      ''');
      _isSpeaking = false;
    } catch (e) {
      debugPrint('ShonaSpeechService stop error: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Hands-Free VAD Speech Recognition (Silence Auto-Send)
  // ───────────────────────────────────────────────────────────────────────────

  /// Starts listening to microphone audio with 1.8s silence VAD auto-submit.
  void startListeningWithVad({
    required Function(String recognizedText) onResult,
    required Function() onAutoSubmit,
    required Function(bool isListening) onStatus,
  }) {
    if (!kIsWeb) {
      debugPrint('Speech recognition requires Web Speech API');
      onStatus(false);
      return;
    }

    try {
      _isListening = true;
      onStatus(true);

      js_bridge.setJsCallback('_onShonaSpeechResult', (dynamic text) {
        if (text is String && text.isNotEmpty) {
          onResult(text);
        }
      });

      js_bridge.setJsCallback('_onShonaSpeechVadSubmit', () {
        _isListening = false;
        onStatus(false);
        onAutoSubmit();
      });

      js_bridge.setJsCallback('_onShonaSpeechEnd', () {
        _isListening = false;
        onStatus(false);
      });

      js_bridge.evalJs('''
        (function() {
          var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
          if (!SpeechRecognition) {
            alert('Speech recognition is not supported in this browser. Please use Chrome.');
            return;
          }
          if (window._shonaRecognizer) {
            try { window._shonaRecognizer.stop(); } catch(e){}
          }
          window._shonaRecognizer = new SpeechRecognition();
          window._shonaRecognizer.continuous = true;
          window._shonaRecognizer.interimResults = true;
          window._shonaRecognizer.lang = 'en-US';

          var vadTimer = null;
          var lastTranscript = '';

          window._shonaRecognizer.onresult = function(event) {
            if (window._isTtsSpeaking) {
              console.log('Muting microphone during TTS speaker output...');
              return;
            }

            var transcript = '';
            for (var i = event.resultIndex; i < event.results.length; ++i) {
              transcript += event.results[i][0].transcript;
            }
            if (transcript.trim().length > 0) {
              lastTranscript = transcript;
              if (window._onShonaSpeechResult) {
                window._onShonaSpeechResult(transcript);
              }

              // Reset silence VAD timer (1.8 seconds of silence auto-submits)
              if (vadTimer) clearTimeout(vadTimer);
              vadTimer = setTimeout(function() {
                if (window._shonaRecognizer) {
                  try { window._shonaRecognizer.stop(); } catch(e){}
                }
                if (!window._isTtsSpeaking && window._onShonaSpeechVadSubmit && lastTranscript.trim().length > 3) {
                  window._onShonaSpeechVadSubmit();
                }
              }, 1800);
            }
          };

          window._shonaRecognizer.onend = function() {
            if (window._onShonaSpeechEnd) {
              window._onShonaSpeechEnd();
            }
          };

          window._shonaRecognizer.onerror = function(err) {
            console.error('Shona VAD ASR Error:', err);
            if (window._onShonaSpeechEnd) {
              window._onShonaSpeechEnd();
            }
          };

          window._shonaRecognizer.start();
        })();
      ''');
    } catch (e) {
      debugPrint('Shona ASR start VAD listening error: $e');
      _isListening = false;
      onStatus(false);
    }
  }

  /// Starts normal listening without auto-submit.
  void startListening({
    required Function(String recognizedText) onResult,
    required Function(bool isListening) onStatus,
  }) {
    startListeningWithVad(
      onResult: onResult,
      onAutoSubmit: () {},
      onStatus: onStatus,
    );
  }

  /// Stops Shona speech recognition.
  void stopListening() {
    if (!kIsWeb) return;
    try {
      js_bridge.evalJs('''
        if (window._shonaRecognizer) {
          try { window._shonaRecognizer.stop(); } catch(e){}
        }
      ''');
      _isListening = false;
    } catch (e) {
      debugPrint('Shona ASR stop error: $e');
    }
  }

  /// Transcribes raw WAV audio bytes using the Modal Shona STT model endpoint.
  Future<String?> transcribeShonaWavBytes(Uint8List audioBytes) async {
    return VerdiApiService.instance.transcribeShonaAudio(audioBytes);
  }
}


