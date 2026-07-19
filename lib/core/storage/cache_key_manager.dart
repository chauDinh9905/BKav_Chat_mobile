import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CacheKeyManager {
  static const _storage = FlutterSecureStorage();

  static String _keyName(int userId) => 'cache_key_$userId';

  /// Lấy key mã hóa của user, tự tạo mới nếu chưa có (không phụ thuộc token/password)
  static Future<List<int>> getOrCreateKey(int userId) async {
    final keyName = _keyName(userId);
    final existing = await _storage.read(key: keyName);
    if (existing != null) {
      return base64Decode(existing);
    }
    final newKey = _generateRandomKey(32); // AES-256
    await _storage.write(key: keyName, value: base64Encode(newKey));
    return newKey;
  }

  static List<int> _generateRandomKey(int length) {
    final rand = Random.secure();
    return List<int>.generate(length, (_) => rand.nextInt(256));
  }

  /// Gọi khi logout / muốn xóa cache của 1 user (ví dụ máy dùng chung)
  static Future<void> deleteKey(int userId) async {
    await _storage.delete(key: _keyName(userId));
  }
}