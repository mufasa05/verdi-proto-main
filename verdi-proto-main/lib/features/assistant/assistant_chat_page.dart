import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/rate_limiter_service.dart';
import 'models/assistant_models.dart';
import 'providers/assistant_provider.dart';
import 'widgets/assistant_source_panel.dart';
import 'widgets/assistant_suggestion_chips.dart';

class AssistantChatPage extends StatefulWidget {
  const AssistantChatPage({super.key});

  @override
  State<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends State<AssistantChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssistantProvider>().init();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final allowed = RateLimiterService.instance.checkAndRecord(
      RateLimitCategory.aiAssistant,
      onRateLimited: (s) => RateLimiterService.instance.showRateLimitToast(context, RateLimitCategory.aiAssistant, s),
    );
    if (!allowed) return;

    _controller.clear();
    await context.read<AssistantProvider>().sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSuggestionTap(String text) {
    _controller.text = text;
    _send();
  }

  static const List<String> _suggestions = [
    'Show platform summary',
    'What are urgent issues?',
    'Review recent tasks',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssistantProvider>();
    final messages = provider.messages;
    final loading = provider.loading;
    final summary = provider.aiSummary;

    if (messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Verdi AI Copilot'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await provider.init();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (summary != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF16A34A)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      summary,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          AssistantSuggestionChips(
            suggestions: _suggestions,
            onTap: _handleSuggestionTap,
          ),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(provider.errorMessage!, style: TextStyle(color: Colors.red.shade700)),
              ),
            ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (loading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (loading && index == messages.length) {
                  return const _TypingBubble();
                }
                final message = messages[index];
                return _MessageBubble(
                  message: message,
                  onActionTap: message.actionRoute == null
                      ? null
                      : () {
                          Navigator.pushNamed(context, message.actionRoute!);
                        },
                );
              },
            ),
          ),
          if (provider.sources.isNotEmpty)
            AssistantSourcePanel(
              sources: provider.sources,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<AssistantProvider>().createTask(
                          'Review latest platform activity',
                          'notifications',
                        );
                  },
                  icon: const Icon(Icons.task_alt),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask Verdi AI...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _send,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AssistantMessage message;
  final VoidCallback? onActionTap;

  const _MessageBubble({
    required this.message,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AssistantMessageRole.user;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser ? const Color(0xFF16A34A) : Colors.white;
    final fg = isUser ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: isUser ? null : Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.text, style: TextStyle(color: fg, height: 1.35)),
              if (message.attachmentUrls.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: message.attachmentUrls
                      .map(
                        (url) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.white.withOpacity(0.18) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Attachment',
                            style: TextStyle(color: fg, fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (message.intent != AssistantIntent.unknown) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _metaChip(message.intent.name),
                    _metaChip(message.confidence.name),
                  ],
                ),
              ],
              if (message.actionLabel != null) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onActionTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isUser ? Colors.white : const Color(0xFF16A34A),
                    side: BorderSide(
                      color: isUser ? Colors.white.withOpacity(0.65) : const Color(0xFF16A34A),
                    ),
                  ),
                  child: Text(message.actionLabel!),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(message.createdAt),
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
        ),
        child: const Text('Verdi AI is typing...'),
      ),
    );
  }
}
