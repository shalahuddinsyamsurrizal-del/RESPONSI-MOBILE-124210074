import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../database/database_helper.dart';

class DetailScreen extends StatefulWidget {
  final Article article;

  const DetailScreen({super.key, required this.article});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isBookmarked = false;
  bool _isCheckingBookmark = true;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final result = await DatabaseHelper.instance.isBookmarked(
      widget.article.id,
    );

    if (!mounted) return;

    setState(() {
      _isBookmarked = result;
      _isCheckingBookmark = false;
    });
  }

  Future<void> _toggleBookmark() async {
    final db = DatabaseHelper.instance;

    if (_isBookmarked) {
      await db.removeBookmark(widget.article.id);

      if (!mounted) return;

      setState(() {
        _isBookmarked = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookmark berhasil dihapus'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      await db.addBookmark(widget.article.toMap());

      if (!mounted) return;

      setState(() {
        _isBookmarked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berita berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _openArticle() async {
    final uri = Uri.tryParse(widget.article.url.trim());

    if (uri == null ||
        !uri.hasAuthority ||
        !(uri.scheme == 'https' || uri.scheme == 'http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL artikel tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka artikel di browser'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      backgroundColor: const Color(0xFF080D1B),
      appBar: AppBar(
        title: const Text('News Detail'),
        backgroundColor: const Color(0xFF080D1B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Bookmark',
            onPressed: _isCheckingBookmark ? null : _toggleBookmark,
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: const Color(0xFF151D30),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Source: ${article.newsSite}',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Published: ${_formatDate(article.publishedAt)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Author: ${article.authors.isEmpty ? 'Unknown' : article.authors.join(', ')}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.summary,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openArticle,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Read Full Article'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
