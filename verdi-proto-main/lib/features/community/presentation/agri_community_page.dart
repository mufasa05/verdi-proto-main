import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../agri_expert/data/agri_expert_models.dart';
import '../../agri_expert/state/agri_expert_state.dart';

class AgriCommunityPage extends ConsumerStatefulWidget {
  const AgriCommunityPage({super.key});

  @override
  ConsumerState<AgriCommunityPage> createState() => _AgriCommunityPageState();
}

class _AgriCommunityPageState extends ConsumerState<AgriCommunityPage> {
  String _selectedCrop = 'All Crops';
  final _commentControllers = <String, TextEditingController>{};

  final List<String> _crops = [
    'All Crops',
    'Maize & Cereals',
    'Tobacco',
    'Soybeans & Oilseeds',
    'Horticulture & Vegetables',
    'Livestock & Pasture',
  ];

  @override
  void dispose() {
    for (var c in _commentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agriExpertProvider);
    final posts = state.communityPosts;

    final filtered = posts.where((p) {
      if (_selectedCrop == 'All Crops') return true;
      return p.cropCategory == _selectedCrop;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VERDI Agri-Community Hub', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const Text('Field bulletins, pest alerts, and verified agronomy answers', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add, color: Color(0xFF16A34A)),
            tooltip: 'Post Community Update',
            onPressed: () => _showNewPostDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Crop Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _crops.map((crop) {
                  final isSel = _selectedCrop == crop;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(crop, style: TextStyle(fontSize: 11.5, color: isSel ? Colors.white : const Color(0xFF334155))),
                      selected: isSel,
                      selectedColor: const Color(0xFF16A34A),
                      backgroundColor: const Color(0xFFF1F5F9),
                      onSelected: (_) => setState(() => _selectedCrop = crop),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('No Community Updates for $_selectedCrop', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('Be the first to post a field advisory or ask a question.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final p = filtered[i];
                      if (!_commentControllers.containsKey(p.id)) {
                        _commentControllers[p.id] = TextEditingController();
                      }
                      final commentCtrl = _commentControllers[p.id]!;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF16A34A).withOpacity(0.12),
                                    child: Icon(p.isExpert ? Icons.psychology : Icons.person, color: const Color(0xFF16A34A)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(p.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(width: 6),
                                            if (p.isVerifiedByState)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(4)),
                                                child: const Text('STATE VERIFIED', style: TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w800)),
                                              ),
                                          ],
                                        ),
                                        Text('${p.authorRoleTitle} • ${p.districtLocation} • ${p.timestamp}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                                    child: Text(p.cropCategory, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(p.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                              const SizedBox(height: 6),
                              Text(p.content, style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4)),
                              const Divider(height: 24),

                              // Upvotes and interactions
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => ref.read(agriExpertProvider.notifier).upvoteCommunityPost(p.id),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Color(0xFF16A34A)),
                                          const SizedBox(width: 6),
                                          Text('${p.upvotes} Upvotes', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF64748B)),
                                      const SizedBox(width: 6),
                                      Text('${p.comments.length} Comments', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                    ],
                                  ),
                                ],
                              ),

                              // Render comments if any
                              if (p.comments.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ...p.comments.map((c) => Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                          const SizedBox(width: 6),
                                          Text('(${c.authorRoleTag})', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                          const Spacer(),
                                          Text(c.timestamp, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(c.content, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                                    ],
                                  ),
                                )),
                              ],

                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: commentCtrl,
                                      decoration: InputDecoration(
                                        hintText: 'Write an agronomic answer or reply...',
                                        hintStyle: const TextStyle(fontSize: 12),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        filled: true,
                                        fillColor: const Color(0xFFF1F5F9),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.send, color: Color(0xFF16A34A)),
                                    onPressed: () {
                                      final text = commentCtrl.text.trim();
                                      if (text.isEmpty) return;
                                      final comment = CommunityComment(
                                        id: 'COM-${DateTime.now().millisecondsSinceEpoch % 1000}',
                                        authorName: 'Dr. Nyasha Sibanda',
                                        authorRoleTag: 'Agri-Expert',
                                        isVerifiedExpert: true,
                                        content: text,
                                        timestamp: 'Just now',
                                      );
                                      ref.read(agriExpertProvider.notifier).addCommunityComment(p.id, comment);
                                      commentCtrl.clear();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showNewPostDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String selectedCrop = 'Maize & Cereals';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Post Community Field Bulletin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title / Subject')),
            const SizedBox(height: 10),
            TextField(controller: contentCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Advisory Body / Farmer Question')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final post = CommunityPost(
                id: 'POST-${DateTime.now().millisecondsSinceEpoch % 1000}',
                authorName: 'Dr. Nyasha Sibanda',
                authorRoleTitle: 'Agronomy Specialist',
                cropCategory: selectedCrop,
                districtLocation: 'Mashonaland West',
                title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Agronomy Advisory',
                content: contentCtrl.text.trim().isNotEmpty ? contentCtrl.text.trim() : 'Field scouting recommendations.',
                timestamp: 'Just now',
              );
              ref.read(agriExpertProvider.notifier).addCommunityPost(post);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Posted to Community Hub!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
