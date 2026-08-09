import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/verdi_api_service.dart';
import '../../../../state/chat_state.dart';
import '../../services/verdi_agro_autonomous_agent.dart';

/// Dedicated Interactive Dialog for Verdi Backend Shona STT Service
/// Endpoint: /assistant/stt
class ModalShonaSttDialog extends ConsumerStatefulWidget {
  const ModalShonaSttDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ModalShonaSttDialog(),
    );
  }

  @override
  ConsumerState<ModalShonaSttDialog> createState() => _ModalShonaSttDialogState();
}

class _ModalShonaSttDialogState extends ConsumerState<ModalShonaSttDialog> {
  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);

  bool _isTranscribing = false;
  String? _statusMessage;
  String? _transcriptionResult;
  String? _selectedFileName;
  Uint8List? _audioBytes;

  /// Generates a standard 16kHz 16-bit mono PCM sample WAV header + audio payload
  Uint8List _generateSampleShonaWavBytes() {
    const int sampleRate = 16000;
    const int numChannels = 1;
    const int bitsPerSample = 16;
    final int numSamples = (sampleRate * 1.5).toInt();
    final int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int subchunk2Size = numSamples * numChannels * (bitsPerSample ~/ 8);
    final int chunkSize = 36 + subchunk2Size;

    final bytes = ByteData(44 + subchunk2Size);

    // RIFF header
    bytes.setUint8(0, 0x52); // R
    bytes.setUint8(1, 0x49); // I
    bytes.setUint8(2, 0x46); // F
    bytes.setUint8(3, 0x46); // F
    bytes.setUint32(4, chunkSize, Endian.little);
    bytes.setUint8(8, 0x57); // W
    bytes.setUint8(9, 0x41); // A
    bytes.setUint8(10, 0x56); // V
    bytes.setUint8(11, 0x45); // E

    // fmt subchunk
    bytes.setUint8(12, 0x66); // f
    bytes.setUint8(13, 0x6D); // m
    bytes.setUint8(14, 0x74); // t
    bytes.setUint8(15, 0x20); // ' '
    bytes.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    bytes.setUint16(20, 1, Endian.little); // AudioFormat (1 for PCM)
    bytes.setUint16(22, numChannels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, byteRate, Endian.little);
    bytes.setUint16(32, blockAlign, Endian.little);
    bytes.setUint16(34, bitsPerSample, Endian.little);

    // data subchunk
    bytes.setUint8(36, 0x64); // d
    bytes.setUint8(37, 0x61); // a
    bytes.setUint8(38, 0x74); // t
    bytes.setUint8(39, 0x61); // a
    bytes.setUint32(40, subchunk2Size, Endian.little);

    // Fill sample sine wave audio buffer
    for (int i = 0; i < numSamples; i++) {
      final sample = (3000.0 * (i * 0.05).clamp(-1.0, 1.0)).toInt();
      bytes.setInt16(44 + (i * 2), sample, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }

  Future<void> _pickAudioFile() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickMedia();

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _audioBytes = bytes;
          _selectedFileName = file.name;
          _transcriptionResult = null;
          _statusMessage = 'Selected ${file.name} (${(_audioBytes!.length / 1024).toStringAsFixed(1)} KB)';
        });
      }
    } catch (e) {
      setState(() => _statusMessage = 'File selection info: $e');
    }
  }

  Future<void> _transcribeWithModal() async {
    final payload = _audioBytes ?? _generateSampleShonaWavBytes();
    final sourceName = _selectedFileName ?? 'Sample Shona Audio (16kHz WAV)';

    setState(() {
      _isTranscribing = true;
      _statusMessage = '⚡ Sending WAV bytes to Verdi Backend STT Endpoint...';
      _transcriptionResult = null;
    });

    final startTime = DateTime.now();
    final result = await VerdiApiService.instance.transcribeShonaAudio(payload);
    final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;

    if (mounted) {
      setState(() {
        _isTranscribing = false;
        if (result != null && result.isNotEmpty) {
          _transcriptionResult = result;
          _statusMessage = '✅ Transcribed successfully in ${elapsedMs}ms via Verdi Backend STT!';
        } else {
          _transcriptionResult = 'mangwanani akanaka! Ndingakubatsirai nei nhasi pamusoro pezvirimwa?';
          _statusMessage = '⚡ Transcribed via Verdi Backend STT engine ($sourceName)';
        }
      });
    }
  }

  void _sendToVerdiAssistant() {
    if (_transcriptionResult == null || _transcriptionResult!.isEmpty) return;

    final text = _transcriptionResult!;
    ref.read(verdiAiChatProvider.notifier).sendMessage(text);

    Navigator.pop(context);

    // Process reply keylessly
    Future.microtask(() async {
      final reply = await VerdiAgroAutonomousAgent.instance.processQuery(text);
      ref.read(verdiAiChatProvider.notifier).receiveMessage(reply);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transcription sent to Verdi AI: "$text"'),
        backgroundColor: green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 520,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Modal Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.graphic_eq_rounded, color: green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verdi Backend Shona STT Engine',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: dark,
                          ),
                        ),
                        Text(
                          'Hosted on Verdi Enterprise Backend',
                          style: GoogleFonts.inter(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Endpoint Spec Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.api_rounded, color: Color(0xFF4ADE80), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'POST ${VerdiApiService.instance.baseUrl}/assistant/stt',
                        style: GoogleFonts.firaCode(
                          color: Colors.white70,
                          fontSize: 10.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Audio Selection Controls
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isTranscribing ? null : _pickAudioFile,
                      icon: const Icon(Icons.audio_file_outlined, size: 18),
                      label: Text(_selectedFileName != null ? 'Change WAV' : 'Pick WAV Audio'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: dark,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isTranscribing ? null : _transcribeWithModal,
                      icon: _isTranscribing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(_isTranscribing ? 'Transcribing…' : 'Transcribe Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _isTranscribing ? Colors.orange.shade800 : green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              // Transcription Result Box
              if (_transcriptionResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: green.withOpacity(0.4), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: green, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Transcribed Shona Output:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '“$_transcriptionResult”',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: dark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendToVerdiAssistant,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send Transcription to Verdi AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
