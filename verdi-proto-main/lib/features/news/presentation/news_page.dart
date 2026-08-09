import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/news_repository.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const background = Color(0xFFF8FAFC);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsRepository _repository = NewsRepository();
  List<NewsArticle> _allArticles = [];
  List<NewsArticle> _filteredArticles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All News';
  String _selectedRegion = 'All Regions';
  Timer? _autoRefreshTimer;

  final List<String> _categories = [
    'All News',
    'Crops & Yields',
    'Markets & Prices',
    'Logistics & Trade',
    'Weather & Climate',
    'EUDR & Policy',
  ];

  final List<String> _regions = [
    'All Regions',
    'Zimbabwe 🇿🇼',
    'South Africa 🇿🇦',
    'Zambia 🇿🇲',
    'Mozambique 🇲🇿',
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
    
    // Auto-refresh every 15 minutes in background
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _loadNews(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNews({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final articles = await _repository.fetchLiveAgriNews(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _allArticles = articles;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    List<NewsArticle> list = List.from(_allArticles);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((a) {
        return a.title.toLowerCase().contains(q) ||
            a.snippet.toLowerCase().contains(q) ||
            a.publisher.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedCategory != 'All News') {
      list = list.where((a) => a.category == _selectedCategory).toList();
    }

    if (_selectedRegion != 'All Regions') {
      list = list.where((a) => a.region.contains(_selectedRegion.split(' ')[0])).toList();
    }

    _filteredArticles = list;
  }

  Future<void> _openArticleUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching news URL $url: $e');
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) {
      return 'Yesterday';
    }
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NewsPage.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NewsPage.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.newspaper_outlined, color: NewsPage.green, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Southern Africa Agri-News',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: NewsPage.dark,
                  ),
                ),
                Text(
                  'Real-time live RSS updates • 5-day rolling archive',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: NewsPage.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: NewsPage.green),
                  )
                : const Icon(Icons.refresh, color: NewsPage.dark),
            onPressed: () => _loadNews(forceRefresh: true),
            tooltip: 'Refresh live feeds',
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                // Top Search and Filter Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    children: [
                      // Search Input
                      TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                            _applyFilters();
                          });
                        },
                        style: GoogleFonts.inter(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search agricultural news, commodities, policy...',
                          hintStyle: GoogleFonts.inter(fontSize: 12.5, color: NewsPage.muted),
                          prefixIcon: const Icon(Icons.search, color: NewsPage.muted, size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Category Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSel = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSel,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = cat;
                                    _applyFilters();
                                  });
                                },
                                selectedColor: NewsPage.green.withValues(alpha: 0.15),
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? NewsPage.green : NewsPage.muted,
                                ),
                                side: BorderSide(color: isSel ? NewsPage.green : Colors.black12),
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Region Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _regions.map((reg) {
                            final isSel = _selectedRegion == reg;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(reg),
                                selected: isSel,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedRegion = reg;
                                    _applyFilters();
                                  });
                                },
                                selectedColor: const Color(0xFF0F172A).withValues(alpha: 0.1),
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? NewsPage.dark : NewsPage.muted,
                                ),
                                side: BorderSide(color: isSel ? NewsPage.dark : Colors.black12),
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Article List View
                Expanded(
                  child: _isLoading && _allArticles.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: NewsPage.green),
                              SizedBox(height: 14),
                              Text('Fetching live Southern African agri news...'),
                            ],
                          ),
                        )
                      : _filteredArticles.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.newspaper, size: 54, color: Colors.black26),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No articles found for selected filter.',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _selectedCategory = 'All News';
                                        _selectedRegion = 'All Regions';
                                        _applyFilters();
                                      });
                                    },
                                    child: const Text('Reset Filters'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredArticles.length,
                              itemBuilder: (context, index) {
                                final article = _filteredArticles[index];
                                return _buildNewsCard(article);
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    final timeStr = _formatTimeAgo(article.publishedAt);
    final fullDateStr = DateFormat('MMM d, yyyy • hh:mm a').format(article.publishedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  article.publisher,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: NewsPage.dark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NewsPage.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  article.category,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: NewsPage.green,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timeStr,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: NewsPage.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            article.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: NewsPage.dark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),

          // Snippet
          if (article.snippet.isNotEmpty)
            Text(
              article.snippet,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: NewsPage.muted,
                height: 1.45,
              ),
            ),
          const SizedBox(height: 12),

          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fullDateStr,
                style: GoogleFonts.inter(fontSize: 10.5, color: NewsPage.muted),
              ),
              ElevatedButton.icon(
                onPressed: () => _openArticleUrl(article.link),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: Text(
                  'Read Full Story on ${article.publisher} ↗',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NewsPage.dark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
