import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/app_state.dart';
import '../../../state/chat_state.dart';
import '../../../state/platform_data_state.dart';
import '../../auth/state/auth_state.dart';

/// Full-Featured Real-Time Cross-Device Messaging & Advisory Console
class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All Chats';
  final TextEditingController _msgInputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  ChatThread? _activeMobileThread;

  static const _green = Color(0xFF16A34A);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFC);
  static const _cardBorder = Color(0xFFE2E8F0);

  @override
  void dispose() {
    _msgInputCtrl.dispose();
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

  void _sendCurrentMessage(ChatNotifier notifier) {
    final text = _msgInputCtrl.text.trim();
    if (text.isEmpty) return;

    notifier.sendMessage(text);
    _msgInputCtrl.clear();
    _scrollToBottom();
  }

  void _sendTradeOffer(ChatNotifier notifier) {
    final commodityCtrl = TextEditingController(text: 'Grade-A Export Avocados');
    final qtyCtrl = TextEditingController(text: '1,000 kg');
    final priceCtrl = TextEditingController(text: 'US\$ 1.85 / kg');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.handshake_outlined, color: _green),
            const SizedBox(width: 8),
            Text('Attach Trade / Escrow Offer', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: commodityCtrl, decoration: const InputDecoration(labelText: 'Commodity', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity / Volume', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Unit Price', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.sendMessage(
                'I have submitted a formal trade contract offer for ${qtyCtrl.text.trim()} of ${commodityCtrl.text.trim()} at ${priceCtrl.text.trim()}.',
                orderAttachment: {
                  'commodity': commodityCtrl.text.trim(),
                  'quantity': qtyCtrl.text.trim(),
                  'price': priceCtrl.text.trim(),
                  'escrowState': 'Pending Lock',
                },
              );
              _scrollToBottom();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
            child: const Text('Send Trade Offer'),
          ),
        ],
      ),
    );
  }

  void _showStartNewChatDialog(BuildContext context) {
    final sessions = ref.read(liveUserSessionsProvider);
    final isDemo = ref.read(isDemoModeProvider);
    final notifier = ref.read(chatProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Start Direct Conversation', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose a platform stakeholder or AI assistant to connect with:', style: TextStyle(fontSize: 12, color: _muted)),
                const SizedBox(height: 14),

                // AI Agronomist Tile
                ListTile(
                  leading: CircleAvatar(backgroundColor: _green.withOpacity(0.15), child: const Icon(Icons.psychology, color: _green)),
                  title: const Text('Verdi AI Agronomist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  subtitle: const Text('Real-time crop advice, weather & pricing', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(context);
                    notifier.startOrGetThread(
                      'Verdi AI Agronomist',
                      'Sovereign Agricultural Copilot · 24/7',
                      'Hello! I need agronomic assistance with my harvest planning.',
                      'AI',
                    );
                  },
                ),

                const Divider(),

                // Live Active Users Tile
                Text(isDemo ? 'Sandbox Stakeholders' : 'Live Connected Stakeholders', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: _dark)),
                const SizedBox(height: 6),

                if (sessions.isEmpty && !isDemo)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No other stakeholders online yet. Open Verdi on a 2nd device to chat peer-to-peer!', style: TextStyle(fontSize: 11, color: _muted)),
                  )
                else
                  ...sessions.take(6).map((s) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.15),
                          child: Text(s.avatar, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${s.role.label} • ${s.location}', style: const TextStyle(fontSize: 11)),
                        trailing: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: s.isOnline ? _green : Colors.grey, shape: BoxShape.circle),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          notifier.startOrGetThread(
                            '${s.name} (${s.role.label})',
                            'Direct chat with ${s.name}',
                            'Hello ${s.name}, reaching out via Verdi Sovereign Terminal.',
                            s.role == UserRole.transporter ? 'Logistics' : 'Marketplace',
                            ref.read(authStateProvider).user?.fullName,
                            s.name,
                          );
                        },
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 850;

    // Filter threads
    final List<ChatThread> filteredThreads = chatState.threads.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) && !t.subtitle.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_selectedCategory == 'Marketplace') return t.category == 'Marketplace';
      if (_selectedCategory == 'Logistics') return t.category == 'Logistics';
      if (_selectedCategory == 'Advisory' || _selectedCategory == 'AI') return t.category == 'AI' || t.category == 'Advisory';
      return true;
    }).toList();

    final selectedIdx = chatState.selectedIndex < chatState.threads.length ? chatState.selectedIndex : 0;
    final activeThread = chatState.threads.isNotEmpty ? chatState.threads[selectedIdx] : null;

    // Trigger auto-scroll on active thread update
    _scrollToBottom();

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
              child: const Icon(Icons.chat_bubble_rounded, color: _green, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Chats', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: _dark)),
                Text('Live Peer-to-Peer & AI Advisory Mesh', style: GoogleFonts.inter(fontSize: 11, color: _muted)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showStartNewChatDialog(context),
              icon: const Icon(Icons.add_comment_rounded, size: 16),
              label: const Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                // Left Thread Sidebar
                SizedBox(
                  width: 340,
                  child: _buildThreadSidebar(filteredThreads, chatState, notifier),
                ),
                const VerticalDivider(width: 1, color: _cardBorder),
                // Right Active Conversation
                Expanded(
                  child: activeThread != null
                      ? _buildConversationPane(activeThread, notifier)
                      : _buildEmptyConversationView(),
                ),
              ],
            )
          : (_activeMobileThread != null
              ? _buildMobileConversationView(_activeMobileThread!, notifier)
              : _buildThreadSidebar(filteredThreads, chatState, notifier, isMobile: true)),
    );
  }

  Widget _buildThreadSidebar(List<ChatThread> threads, ChatState chatState, ChatNotifier notifier, {bool isMobile = false}) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search & Category Chips
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search chats & stakeholders...',
                    hintStyle: const TextStyle(fontSize: 12, color: _muted),
                    prefixIcon: const Icon(Icons.search, size: 18, color: _muted),
                    isDense: true,
                    filled: true,
                    fillColor: _bg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All Chats', 'Marketplace', 'Logistics', 'AI'].map((cat) {
                      final isSel = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                          selected: isSel,
                          selectedColor: _green.withOpacity(0.15),
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: _cardBorder),

          // Threads List
          Expanded(
            child: threads.isEmpty
                ? Center(
                    child: Text('No conversations found.', style: GoogleFonts.inter(color: _muted, fontSize: 12)),
                  )
                : ListView.separated(
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: _cardBorder),
                    itemBuilder: (context, idx) {
                      final t = threads[idx];
                      final isSelected = !isMobile && chatState.selectedIndex == chatState.threads.indexOf(t);

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: _green.withOpacity(0.08),
                        leading: CircleAvatar(
                          backgroundColor: t.category == 'AI' ? _green.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
                          child: Icon(
                            t.category == 'AI' ? Icons.psychology : (t.category == 'Logistics' ? Icons.local_shipping : Icons.person),
                            color: t.category == 'AI' ? _green : Colors.blue,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          t.title,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: _dark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          t.subtitle,
                          style: const TextStyle(fontSize: 11, color: _muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          final realIdx = chatState.threads.indexOf(t);
                          notifier.selectThread(realIdx);
                          if (isMobile) {
                            setState(() => _activeMobileThread = t);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationPane(ChatThread thread, ChatNotifier notifier) {
    return Container(
      color: _bg,
      child: Column(
        children: [
          // Conversation Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: _cardBorder)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: thread.category == 'AI' ? _green.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
                  child: Icon(
                    thread.category == 'AI' ? Icons.psychology : Icons.person,
                    color: thread.category == 'AI' ? _green : Colors.blue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(thread.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: _dark)),
                      Text(thread.subtitle, style: const TextStyle(fontSize: 11, color: _muted)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.handshake_outlined, color: _green),
                  tooltip: 'Attach Trade Offer',
                  onPressed: () => _sendTradeOffer(notifier),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: thread.messages.length,
              itemBuilder: (context, idx) {
                final msg = thread.messages[idx];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _cardBorder)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart_outlined, color: _green),
                  tooltip: 'Send Trade Offer',
                  onPressed: () => _sendTradeOffer(notifier),
                ),
                Expanded(
                  child: TextField(
                    controller: _msgInputCtrl,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(fontSize: 13, color: _muted),
                      filled: true,
                      fillColor: _bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendCurrentMessage(notifier),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _green,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _sendCurrentMessage(notifier),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(msg.senderName, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: _dark)),
              const SizedBox(width: 6),
              Text(msg.timestamp, style: const TextStyle(fontSize: 9.5, color: _muted)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? _green : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMe ? 14 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 14),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : _dark,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (msg.orderAttachment != null) ...[
                  const SizedBox(height: 8),
                  _buildTradeAttachmentCard(msg.orderAttachment!, isMe),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeAttachmentCard(Map<String, dynamic> data, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe ? Colors.black.withOpacity(0.15) : _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isMe ? Colors.white24 : _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 16, color: isMe ? Colors.white : _green),
              const SizedBox(width: 6),
              Text(
                'Trade Contract Offer',
                style: TextStyle(color: isMe ? Colors.white : _dark, fontWeight: FontWeight.bold, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('📦 ${data['commodity']} (${data['quantity']})', style: TextStyle(color: isMe ? Colors.white70 : _dark, fontSize: 11)),
          Text('💰 ${data['price']}', style: TextStyle(color: isMe ? Colors.white : _green, fontWeight: FontWeight.bold, fontSize: 11.5)),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Offer accepted! Locked into Smart Escrow Vault.'), backgroundColor: _green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isMe ? Colors.white : _green,
              foregroundColor: isMe ? _green : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(0, 26),
            ),
            child: const Text('Accept Offer & Lock Escrow', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileConversationView(ChatThread thread, ChatNotifier notifier) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _dark),
          onPressed: () => setState(() => _activeMobileThread = null),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thread.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: _dark)),
            Text(thread.subtitle, style: const TextStyle(fontSize: 10, color: _muted)),
          ],
        ),
      ),
      body: _buildConversationPane(thread, notifier),
    );
  }

  Widget _buildEmptyConversationView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 48, color: _muted),
          const SizedBox(height: 12),
          Text('Select a conversation to start chatting', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _dark)),
        ],
      ),
    );
  }
}