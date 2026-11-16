import 'package:material_ui/material_ui.dart';

import '../database/database_helper.dart';
import '../models/article.dart';
import 'detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final result = await DatabaseHelper.instance.getBookmarks();

    if (!mounted) return;

    setState(() {
      _bookmarks = result;
      _isLoading = false;
    });
  }

  Future<void> _deleteBookmark(int articleId) async {
    await DatabaseHelper.instance.removeBookmark(articleId);

    if (!mounted) return;

    await _loadBookmarks();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark berhasil dihapus'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Article _convertToArticle(Map<String, dynamic> data) {
    return Article(
      id: data['articleId'] ?? data['article_id'] ?? 0,
      title: data['title'] ?? 'No Title',
      url: data['url'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      newsSite: data['newsSite'] ?? 'Unknown',
      summary: data['summary'] ?? '',
      publishedAt: data['publishedAt'] ?? '',
      authors: List<String>.from(data['authors'] ?? []),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1B),
      appBar: AppBar(
        title: const Text('My Bookmarks'),
        backgroundColor: const Color(0xFF080D1B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : _bookmarks.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, color: Colors.white54, size: 60),
                  SizedBox(height: 12),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final data = _bookmarks[index];
                final article = _convertToArticle(data);

                return Dismissible(
                  key: ValueKey(article.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    _deleteBookmark(article.id);
                  },
                  child: Card(
                    color: const Color(0xFF151D30),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: Image.network(
                        article.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 80,
                            height: 80,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                      title: Text(
                        article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        article.newsSite,
                        style: const TextStyle(color: Colors.white60),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(article: article),
                          ),
                        );

                        _loadBookmarks();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
