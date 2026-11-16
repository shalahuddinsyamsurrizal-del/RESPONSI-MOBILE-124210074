import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/news_service.dart';
import '../services/auth_service.dart';
import 'detail_screen.dart';
import 'bookmark_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsService _newsService = NewsService();
  final AuthService _authService = AuthService();

  List<Article> _articles = [];
  bool _isLoading = true;
  String _username = 'User';
  String? _selectedNewsSite;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadNews();
  }

  Future<void> _loadUsername() async {
    final username = await _authService.getLoggedInUsername();

    if (!mounted) return;

    setState(() {
      _username = username ?? 'User';
    });
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final news = await _newsService.fetchNews();

      if (!mounted) return;

      setState(() {
        _articles = news;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<String> get _newsSites {
    final sites = _articles.map((article) => article.newsSite).toSet().toList();

    sites.sort();
    return sites;
  }

  List<Article> get _filteredArticles {
    if (_selectedNewsSite == null) {
      return _articles;
    }

    return _articles
        .where((article) => article.newsSite == _selectedNewsSite)
        .toList();
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();

      final day = parsedDate.day.toString().padLeft(2, '0');
      final month = parsedDate.month.toString().padLeft(2, '0');
      final year = parsedDate.year;

      return '$day/$month/$year';
    } catch (_) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1B),

      appBar: AppBar(
        backgroundColor: const Color(0xFF080D1B),
        foregroundColor: Colors.white,
        elevation: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SpaceNews Explorer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Welcome, $_username',
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Colors.white),
            tooltip: 'Bookmark',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Latest Space News',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Filter sumber berita
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: DropdownButtonFormField<String>(
              value: _selectedNewsSite,
              dropdownColor: const Color(0xFF151D30),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Filter News Source',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.filter_list,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: const Color(0xFF151D30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Sources'),
                ),
                ..._newsSites.map(
                  (site) =>
                      DropdownMenuItem<String>(value: site, child: Text(site)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedNewsSite = value;
                });
              },
            ),
          ),

          // Daftar berita
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  )
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 50,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load news',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white60),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadNews,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _filteredArticles.isEmpty
                ? const Center(
                    child: Text(
                      'No news available',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNews,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = _filteredArticles[index];

                        return Card(
                          color: const Color(0xFF151D30),
                          margin: const EdgeInsets.only(bottom: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(article: article),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  article.imageUrl,
                                  height: 190,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 190,
                                      color: Colors.black26,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white54,
                                          size: 45,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.public,
                                            color: Colors.blueAccent,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              article.newsSite,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            color: Colors.white54,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatDate(article.publishedAt),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
