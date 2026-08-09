import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../state/chat_state.dart';
import '../../auth/state/auth_state.dart';

/// Clean, dedicated My Chats Page accessible from the bottom navigation bar.
class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All Chats';
  ChatThread? _activeMobileThread;

  static const _green = Color(0xFF16A34A);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    final currentUser = ref.watch(authStateProvider).user;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 850;

    // Filter chat threads by user and category/search
    final List<ChatThread> userThreads = chatState.threads.where((t) {
      if (t.participantA != null || t.participantB != null) {
        final name = currentUser?.fullName.toLowerCase() ?? '';
        final isA = t.participantA?.toLowerCase() == name;
        final isB = t.participantB?.toLowerCase() == name;
        if (!isA && !isB && name.isNotEmpty) {
          // Show all threads if no strict match to keep interface populated
        }
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchSub = t.subtitle.toLowerCase().contains(q);
        if (!matchTitle && !matchSub) return false;
      }
      if (_selectedCategory == 'Marketplace') {
        return t.title.toLowerCase().contains('market') || t.title.toLowerCase().contains('buyer') || t.title.toLowerCase().contains('price');
      } else if (_selectedCategory == 'Logistics') {
        return t.title.toLowerCase().contains('delivery') || t.title.toLowerCase().contains('truck') || t.title.toLowerCase().contains('driver');
      } else if (_selectedCategory == 'Advisory') {
        return t.title.toLowerCase().contains('plan') || t.title.toLowerCase().contains('expert') || t.title.toLowerCase().contains('verdi');
      }
      return true;
    }).toList();

    // Determine current selected thread
    final selectedIdx = chatState.selectedIndex < chatState.threads.length ? chatState.selectedIndex : 0;
    final currentSelectedThread = userThreads.isNotEmpty 
        ? (selectedIdx < userThreads.length ? userThreads[selectedIdx] : userThreads.first)
        : null;

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
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: _green, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Chats',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
                Text(
                  'Direct messages & advisory threads',
                  style: GoogleFonts.inter(fontSize: 11, color: _muted),
                ),
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
      body: Column(
        children: [
          // Search & Filter Category Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.inter(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Search chats by contact, produce, or order ID...',
                    hintStyle: GoogleFonts.inter(color: _muted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: _muted, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All Chats', 'Marketplace', 'Logistics', 'Advisory'].map((cat) {
                      final active = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: active,
                          label: Text(cat),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? Colors.white : _dark,
                          ),
                          selectedColor: _green,
                          backgroundColor: const Color(0xFFF1F5F9),
                          checkmarkColor: Colors.white,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Main Chat Body Split (Desktop vs Mobile)
          Expanded(
            child: isDesktop
                ? Row(
                    children: [
                      // Left: Thread List Column
                      SizedBox(
                        width: 320,
                        child: _buildThreadList(userThreads, notifier),
                      ),
                      const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                      // Right: Active Chat Conversation View
                      Expanded(
                        child: currentSelectedThread != null
                            ? _ThreadDetailPanel(thread: currentSelectedThread)
                            : _buildEmptyState(),
                      ),
                    ],
                  )
                : (_activeMobileThread != null
                    ? WillPopScope(
                        onWillPop: () async {
                          setState(() => _activeMobileThread = null);
                          return false;
                        },
                        child: Column(
                          children: [
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_rounded),
                                    onPressed: () => setState(() => _activeMobileThread = null),
                                  ),
                                  Text(
                                    'Back to all chats',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: _ThreadDetailPanel(thread: _activeMobileThread!)),
                          ],
                        ),
                      )
                    : _buildThreadList(userThreads, notifier, onMobileSelect: (thread) {
                        setState(() => _activeMobileThread = thread);
                      })),
          ),
        ],
      ),
    );
  }

  Widget _buildThreadList(List<ChatThread> threads, ChatNotifier notifier, {ValueChanged<ChatThread>? onMobileSelect}) {
    if (threads.isEmpty) {
      return _buildEmptyState();
    }

    final chatState = ref.watch(chatProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: threads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final t = threads[i];
        final selected = chatState.selectedIndex < chatState.threads.length &&
            chatState.threads[chatState.selectedIndex].title == t.title;

        // Role badge & avatar icon
        IconData avatarIcon = Icons.person_outline;
        Color badgeColor = Colors.blue;
        String roleLabel = 'DIRECT';

        if (t.title.contains('Planning') || t.title.contains('Verdi')) {
          avatarIcon = Icons.smart_toy_outlined;
          badgeColor = _green;
          roleLabel = 'AI ASSISTANT';
        } else if (t.title.contains('Market') || t.title.contains('Pricing') || t.title.contains('Buyer')) {
          avatarIcon = Icons.storefront_outlined;
          badgeColor = Colors.amber.shade800;
          roleLabel = 'BUYER';
        } else if (t.title.contains('Delivery') || t.title.contains('Truck') || t.title.contains('Driver')) {
          avatarIcon = Icons.local_shipping_outlined;
          badgeColor = Colors.indigo;
          roleLabel = 'TRANSPORTER';
        }

        final lastMsg = t.messages.isNotEmpty ? t.messages.last.text : t.subtitle;

        return Material(
          color: selected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          elevation: selected ? 1 : 0,
          child: InkWell(
            onTap: () {
              final origIdx = chatState.threads.indexOf(t);
              notifier.selectThread(origIdx != -1 ? origIdx : i);
              if (onMobileSelect != null) {
                onMobileSelect(t);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? _green : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: selected ? _green.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                        child: Icon(avatarIcon, color: selected ? _green : _dark, size: 20),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.title,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _dark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                roleLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: selected ? const Color(0xFF15803D) : _muted,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 56, color: _muted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'No Conversations Found',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: _dark),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "Start New Chat" above to initiate a message with a buyer, driver, or agronomist.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  void _showStartNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Start New Conversation', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFDCFCE7), child: Icon(Icons.storefront, color: _green)),
              title: const Text('FreshMart Ltd (Buyer)'),
              subtitle: const Text('Inquire about tomato purchase terms'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(chatProvider.notifier).startOrGetThread(
                  'FreshMart Ltd',
                  'Produce Buyer Inquiry',
                  'Hello! Are you accepting tomato deliveries this Friday?',
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFDBEAFE), child: Icon(Icons.local_shipping, color: Colors.blue)),
              title: const Text('Tafadzwa M. (Driver)'),
              subtitle: const Text('Coordinate freight pickup & cold storage'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(chatProvider.notifier).startOrGetThread(
                  'Tafadzwa Freight',
                  'Heavy Cargo Truck AEB-2910',
                  'Hi Tafadzwa, what time will you arrive for loading at Chiredzi Farm?',
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFFEF3C7), child: Icon(Icons.science, color: Colors.amber)),
              title: const Text('Dr. Nyoni (Agri Expert)'),
              subtitle: const Text('Consult on crop health & fertilizer mix'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(chatProvider.notifier).startOrGetThread(
                  'Agronomist Dr. Nyoni',
                  'Soil Science & Crop Health Advisory',
                  'Good day Dr. Nyoni, please advise on top-dressing fertilizer rates for winter maize.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Active Chat Detail Conversation View Panel
class _ThreadDetailPanel extends ConsumerStatefulWidget {
  final ChatThread thread;

  const _ThreadDetailPanel({required this.thread});

  @override
  ConsumerState<_ThreadDetailPanel> createState() => _ThreadDetailPanelState();
}

class _ThreadDetailPanelState extends ConsumerState<_ThreadDetailPanel> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const _green = Color(0xFF16A34A);
  static const _dark = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thread header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _green.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: _green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.thread.title,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: _dark),
                    ),
                    Text(
                      widget.thread.subtitle,
                      style: GoogleFonts.inter(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling contact via encrypted IP radio...')),
                  );
                },
                icon: const Icon(Icons.phone_outlined, color: _green),
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: widget.thread.messages.length,
            itemBuilder: (context, index) {
              final msg = widget.thread.messages[index];
              final isUser = msg.isUser;

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.70,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF16A34A), Color(0xFF0F766E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: isUser
                        ? null
                        : const [
                            BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2)),
                          ],
                  ),
                  child: Text(
                    msg.text,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isUser ? Colors.white : _dark,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file_rounded, color: _muted),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Attach invoice, receipt, or crop photo')),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _inputController,
                  onSubmitted: (_) => _sendMessage(),
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: GoogleFonts.inter(color: _muted, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: _green, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: _green,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}