import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/chat_state.dart';

/// Dedicated Sovereign AI Agronomist Copilot & Diagnostic Screen
class AiCopilotPage extends ConsumerStatefulWidget {
  const AiCopilotPage({super.key});

  @override
  ConsumerState<AiCopilotPage> createState() => _AiCopilotPageState();
}

class _AiCopilotPageState extends ConsumerState<AiCopilotPage> {
  final TextEditingController _promptCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isAnalyzing = false;

  static const _green = Color(0xFF16A34A);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFC);
  static const _cardBorder = Color(0xFFE2E8F0);

  final List<String> _quickPrompts = [
    '🌽 Maize & Bean Market Prices',
    '🐛 Fall Armyworm Diagnosis & Treatment',
    '🚚 Find Available Refrigerated Trucks',
    '🛰️ Check NDVI Vegetative Stress',
    '🌧️ 7-Day Rainfall & Spraying Forecast',
  ];

  @override
  void dispose() {
    _promptCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendPrompt(String text) {
    if (text.trim().isEmpty) return;

    ref.read(verdiAiChatProvider.notifier).sendMessage(text.trim());
    _promptCtrl.clear();
    _scrollToBottom();

    setState(() => _isAnalyzing = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final promptLower = text.toLowerCase();
      String response = 'I have analyzed your farm telemetry and regional agricultural indices: ';

      if (promptLower.contains('price') || promptLower.contains('market') || promptLower.contains('maize')) {
        response += 'Today in Harare and Bulawayo: Grade-A Sugar Beans are trading at US\$ 1.20/kg, White Maize at US\$ 335/Tonne, and Tomatoes at US\$ 0.85/kg with strong buyer demand.';
      } else if (promptLower.contains('pest') || promptLower.contains('armyworm') || promptLower.contains('disease') || promptLower.contains('leaf')) {
        response += 'Based on current humidity (68%) and temperature (24°C), inspect for early blight or Fall Armyworm. Recommended treatment: Biological Bt spray or neem extract with 48h pre-harvest interval.';
      } else if (promptLower.contains('truck') || promptLower.contains('transport') || promptLower.contains('logistics')) {
        response += 'There are currently 4 verified refrigerated freight trucks within 25 km of your location on the Harare-Chiredzi corridor ready for dispatch.';
      } else if (promptLower.contains('ndvi') || promptLower.contains('stress') || promptLower.contains('satellite')) {
        response += 'Satellite radar shows an average parcel NDVI of 0.74 (Healthy Crop Canopy). Eastern Zone shows mild moisture deficit—recommend 45 mins drip irrigation at dawn.';
      } else {
        response += 'Weather conditions are optimal for harvest and spraying. 0% precipitation risk expected over the next 48 hours.';
      }

      ref.read(verdiAiChatProvider.notifier).receiveMessage(response);
      setState(() => _isAnalyzing = false);
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiThread = ref.watch(verdiAiChatProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology_rounded, color: _green, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verdi AI Agronomist', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _dark)),
                Text('Sovereign Agricultural Copilot · 24/7 Advisory', style: GoogleFonts.inter(fontSize: 11, color: _muted)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _muted),
            tooltip: 'Clear Conversation',
            onPressed: () {
              ref.read(verdiAiChatProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Quick Prompts Carousel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: _cardBorder)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickPrompts.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(p, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _dark)),
                      backgroundColor: _bg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: _cardBorder)),
                      onPressed: () => _sendPrompt(p),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: aiThread.messages.length,
              itemBuilder: (context, idx) {
                final msg = aiThread.messages[idx];
                final isMe = msg.isUser;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(
                          backgroundColor: _green.withOpacity(0.15),
                          radius: 16,
                          child: const Icon(Icons.psychology_rounded, color: _green, size: 18),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 520),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe ? _green : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe ? 'You' : 'Verdi AI Agronomist',
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : _green,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : _dark,
                                  fontSize: 13.5,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.15),
                          radius: 16,
                          child: const Icon(Icons.person_outline, color: Colors.blue, size: 18),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isAnalyzing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _green),
                  ),
                  const SizedBox(width: 10),
                  Text('Verdi AI is analyzing agronomic datasets...', style: GoogleFonts.inter(fontSize: 11, color: _muted)),
                ],
              ),
            ),

          // Prompt Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ask Verdi AI about crop health, pricing, weather...',
                      hintStyle: const TextStyle(fontSize: 13, color: _muted),
                      filled: true,
                      fillColor: _bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (v) => _sendPrompt(v),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _green,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _sendPrompt(_promptCtrl.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
