import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../live/models/live_ai_event.dart';
import '../live/providers/live_ai_provider.dart';

/// State-of-the-Art Real-Time Sovereign AI Copilot Interface
class AiCopilotPage extends StatefulWidget {
  const AiCopilotPage({super.key});

  @override
  State<AiCopilotPage> createState() => _AiCopilotPageState();
}

class _AiCopilotPageState extends State<AiCopilotPage> {
  final TextEditingController _promptCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  static const _green = Color(0xFF16A34A);
  static const _emerald = Color(0xFF059669);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFC);
  static const _cardBorder = Color(0xFFE2E8F0);

  final List<String> _quickPrompts = [
    '🌽 Sugar Beans & Maize Prices Today',
    '🐛 Fall Armyworm Diagnosis & Treatment',
    '💧 Optimize Drip Irrigation Schedule',
    '🛡️ Check EUDR Deforestation Compliance',
    '🚚 Find Available Reefer Freight Trucks',
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

  void _submitPrompt(String prompt) {
    final t = prompt.trim();
    if (t.isEmpty) return;

    final provider = Provider.of<LiveAiProvider>(context, listen: false);
    final convId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    _promptCtrl.clear();

    provider.sendPrompt(t, convId);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final liveAiState = Provider.of<LiveAiProvider>(context);

    // Auto-scroll when reply updates
    if (liveAiState.streamingReply) {
      _scrollToBottom();
    }

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
                gradient: const LinearGradient(
                  colors: [_green, _emerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: _green.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Verdi AI Agronomist', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: _dark)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text('Groq Llama 3.3 · 70B', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold, color: _green)),
                        ],
                      ),
                    ),
                  ],
                ),
                Text('Sovereign Agricultural Intelligence Engine', style: GoogleFonts.inter(fontSize: 11, color: _muted)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Prompts Carousel Bar
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
                      elevation: 0,
                      label: Text(p, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: _dark)),
                      backgroundColor: _bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: _cardBorder),
                      ),
                      onPressed: () => _submitPrompt(p),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Main Chat / Stream View
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Hero Card
                if (liveAiState.liveSummaries.isEmpty && !liveAiState.streamingReply) _buildWelcomeHeroCard(),

                // Live Platform Events Feed (if any)
                if (liveAiState.events.isNotEmpty) ...[
                  Text('⚡ Live Platform Feed', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: _muted)),
                  const SizedBox(height: 8),
                  ...liveAiState.events.take(3).map((evt) => _buildEventTile(evt)),
                  const SizedBox(height: 16),
                ],

                // Streamed Response Cards
                ...liveAiState.liveSummaries.reversed.map((summary) => _buildSummaryBubble(summary)),

                // Current Streaming Active Token Card
                if (liveAiState.streamingReply) _buildActiveStreamingBubble(liveAiState.currentReply, liveAiState.latestPrompt),

                // Error Notification Banner
                if (liveAiState.errorMessage != null) _buildErrorMessageCard(liveAiState.errorMessage!),
              ],
            ),
          ),

          // Stream Status Indicator
          if (liveAiState.streamingReply)
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
                  const SizedBox(width: 12),
                  Text('Verdi AI is streaming tokens live from Groq backend...', style: GoogleFonts.inter(fontSize: 11.5, color: _emerald, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          // Bottom Prompt Input Bar
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
                      hintText: 'Ask Verdi AI about crop health, market prices, EUDR...',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: _muted),
                      filled: true,
                      fillColor: _bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (v) => _submitPrompt(v),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_green, _emerald]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _submitPrompt(_promptCtrl.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeroCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.auto_awesome, color: _green, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sovereign AI Copilot Online', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _dark)),
                  Text('Connected to Live Groq Llama 3.3 70B Engine', style: GoogleFonts.inter(fontSize: 11.5, color: _emerald, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Ask me anything about crop cultivation (Maize, Sugar Beans, Avocados, Tomatoes, Tea), disease diagnostics, real-time market prices, EUDR deforestation compliance, or reefer transport logistics.',
            style: GoogleFonts.inter(fontSize: 13, color: _muted, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStreamingBubble(String text, String prompt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prompt.isNotEmpty) _buildUserBubble(prompt),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _green.withOpacity(0.15),
              radius: 16,
              child: const Icon(Icons.psychology_rounded, color: _green, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: _green.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(color: _green.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Verdi AI Agronomist', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: _green)),
                        const Spacer(),
                        Text('Streaming...', style: GoogleFonts.inter(fontSize: 10, color: _emerald, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMarkdownFormattedBody(text),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummaryBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _green.withOpacity(0.15),
            radius: 16,
            child: const Icon(Icons.psychology_rounded, color: _green, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: _cardBorder),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verdi AI Response', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: _green)),
                  const SizedBox(height: 8),
                  _buildMarkdownFormattedBody(text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownFormattedBody(String markdownText) {
    if (markdownText.trim().isEmpty) {
      return Text('Generating response...', style: GoogleFonts.inter(fontSize: 13.5, color: _dark, height: 1.45));
    }

    final lines = markdownText.split('\n');
    final List<Widget> widgets = [];

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      // Headers (### Header)
      if (line.startsWith('#')) {
        final cleanHeader = line.replaceAll(RegExp(r'^#+\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Text(
              cleanHeader,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _green,
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet / Numbered Points
      if (line.startsWith('• ') || line.startsWith('- ') || RegExp(r'^\d+\.\s').hasMatch(line)) {
        final cleanText = line.replaceFirst(RegExp(r'^(•|-|\d+\.)\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 14)),
                Expanded(child: _parseFormattedRichText(cleanText)),
              ],
            ),
          ),
        );
        continue;
      }

      // Standard Paragraph line
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _parseFormattedRichText(line),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _parseFormattedRichText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*)');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      final matchedStr = match.group(0)!;
      if (matchedStr.startsWith('**') && matchedStr.endsWith('**')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(2, matchedStr.length - 2),
            style: const TextStyle(fontWeight: FontWeight.bold, color: _dark),
          ),
        );
      } else if (matchedStr.startsWith('*') && matchedStr.endsWith('*')) {
        spans.add(
          TextSpan(
            text: matchedStr.substring(1, matchedStr.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic, color: _muted),
          ),
        );
      }
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: GoogleFonts.inter(fontSize: 13.5, color: _dark, height: 1.45),
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_green, _emerald]),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(color: _green.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Text(text, style: GoogleFonts.inter(fontSize: 13.5, color: Colors.white, height: 1.4)),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.15),
            radius: 14,
            child: const Icon(Icons.person, color: Colors.blue, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(LiveAiEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Icon(
            event.type == LiveAiEventType.alert ? Icons.warning_amber_rounded : Icons.info_outline,
            color: event.severity == LiveAiEventSeverity.high ? Colors.orange : Colors.blue,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('${event.sourceModule.toUpperCase()}: ${event.title}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _dark)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessageCard(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Text(error, style: GoogleFonts.inter(fontSize: 12, color: Colors.amber.shade900)),
    );
  }
}
