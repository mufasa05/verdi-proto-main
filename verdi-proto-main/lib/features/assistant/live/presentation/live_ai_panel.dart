import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/live_ai_provider.dart';
import 'live_ai_event_tile.dart';

class LiveAiPanel extends StatefulWidget {
  final String conversationId;
  final TextEditingController controller;

  const LiveAiPanel({
    super.key,
    required this.conversationId,
    required this.controller,
  });

  @override
  State<LiveAiPanel> createState() => _LiveAiPanelState();
}

class _LiveAiPanelState extends State<LiveAiPanel> {
  bool? _isExpanded;

  Future<void> _send(BuildContext context, String text) async {
    widget.controller.text = text;
    await context.read<LiveAiProvider>().sendPrompt(text, widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LiveAiProvider>();
    _isExpanded ??= MediaQuery.of(context).size.width >= 600;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded!),
            child: Row(
              children: [
                Icon(
                  provider.connected ? Icons.wifi : Icons.wifi_off,
                  color: provider.connected ? const Color(0xFF16A34A) : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Live AI Console',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (provider.streamingReply)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text(
                      'streaming...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                Icon(
                  _isExpanded! ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isExpanded!) ...[
            const SizedBox(height: 12),
            if (provider.currentReply.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(provider.currentReply),
              ),
            if (provider.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PromptChip(
                  label: 'What is happening?',
                  onTap: () => _send(context, 'What is happening on the platform?'),
                ),
                _PromptChip(
                  label: 'Crop risk',
                  onTap: () => _send(context, 'Show crop health risks now'),
                ),
                _PromptChip(
                  label: 'Orders',
                  onTap: () => _send(context, 'Summarize current orders'),
                ),
                _PromptChip(
                  label: 'Payments',
                  onTap: () => _send(context, 'What payments are overdue?'),
                ),
                _PromptChip(
                  label: 'Trade',
                  onTap: () => _send(context, 'What trade issues need attention?'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                itemCount: provider.events.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final event = provider.events[index];
                  return LiveAiEventTile(event: event);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: const Color(0xFFF8FAFC),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    );
  }
}
