import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('spacenews.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel pengguna
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL
      )
    ''');

    // Tabel bookmark
    await db.execute('''
      CREATE TABLE bookmarks (
        article_id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        image_url TEXT,
        news_site TEXT,
        summary TEXT,
        published_at TEXT,
        authors_json TEXT
      )
    ''');
  }

  // =========================
  // USER DATABASE
  // =========================

  Future<int> registerUser(
    String username,
    String passwordHash,
    String salt,
  ) async {
    final db = await database;

    return await db.insert('users', {
      'username': username,
      'password_hash': passwordHash,
      'salt': salt,
    });
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // =========================
  // BOOKMARK DATABASE
  // =========================

  Future<void> addBookmark(Map<String, dynamic> article) async {
    final db = await database;

    await db.insert('bookmarks', {
      'article_id': article['articleId'],
      'title': article['title'],
      'url': article['url'],
      'image_url': article['imageUrl'],
      'news_site': article['newsSite'],
      'summary': article['summary'],
      'published_at': article['publishedAt'],
      'authors_json': jsonEncode(article['authors'] ?? []),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;

    final result = await db.query('bookmarks', orderBy: 'published_at DESC');

    return result.map((item) {
      final article = Map<String, dynamic>.from(item);

      article['articleId'] = article['article_id'];
      article['imageUrl'] = article['image_url'];
      article['newsSite'] = article['news_site'];
      article['publishedAt'] = article['published_at'];

      article['authors'] = jsonDecode(article['authors_json'] ?? '[]');

      return article;
    }).toList();
  }

  Future<bool> isBookmarked(int articleId) async {
    final db = await database;

    final result = await db.query(
      'bookmarks',
      where: 'article_id = ?',
      whereArgs: [articleId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<int> removeBookmark(int articleId) async {
    final db = await database;

    return await db.delete(
      'bookmarks',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
  }
}
