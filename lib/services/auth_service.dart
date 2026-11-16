import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';

class AuthService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  String _generateSalt() {
    final random = Random.secure();

    final bytes = List<int>.generate(32, (_) => random.nextInt(256));

    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  Future<void> register(String username, String password) async {
    final existingUser = await _db.getUserByUsername(username);

    if (existingUser != null) {
      throw Exception('Username sudah digunakan');
    }

    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);

    await _db.registerUser(username, passwordHash, salt);
  }

  Future<bool> login(String username, String password) async {
    final user = await _db.getUserByUsername(username);

    if (user == null) {
      return false;
    }

    final salt = user['salt'] as String;
    final storedHash = user['password_hash'] as String;

    final inputHash = _hashPassword(password, salt);

    if (inputHash != storedHash) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);

    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}
