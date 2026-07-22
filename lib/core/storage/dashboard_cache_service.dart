import 'package:hive_flutter/hive_flutter.dart';
import '../../chat/models/dashboard.dart';
import 'cache_key_manager.dart';

class DashboardCacheService {
  // Tăng số này mỗi khi đổi field/kiểu trong Friend hoặc DashboardModel
  // (thêm/xoá field, đổi nullable <-> non-nullable, đổi kiểu dữ liệu...)
  static const _schemaVersion = 'v2';

  static const _friendBoxPrefix = 'friends_box_${_schemaVersion}_';
  static const _userBoxPrefix = 'user_box_${_schemaVersion}_';

  // Các prefix đời cũ cần dọn rác khi phát hiện - thêm dần mỗi lần tăng version
  static const _oldFriendBoxPrefixes = ['friends_box_'];
  static const _oldUserBoxPrefixes = ['user_box_'];

  Box<Friend>? _friendBox;
  Box<DashboardModel>? _userBox;

  /// Mở box đã mã hóa, scope riêng theo userId (multi-account an toàn)
  Future<void> open(int userId) async {
    final key = await CacheKeyManager.getOrCreateKey(userId);
    final cipher = HiveAesCipher(key);

    await _cleanupOldBoxes(userId);

    _friendBox = await _openSafe<Friend>(
      '$_friendBoxPrefix$userId',
      cipher,
    );
    _userBox = await _openSafe<DashboardModel>(
      '$_userBoxPrefix$userId',
      cipher,
    );
  }

  /// Mở box, nếu đọc lỗi do data không khớp schema thì tự xoá và mở lại
  Future<Box<T>> _openSafe<T>(String boxName, HiveAesCipher cipher) async {
    try {
      return await Hive.openBox<T>(boxName, encryptionCipher: cipher);
    } catch (e) {
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<T>(boxName, encryptionCipher: cipher);
    }
  }

  /// Xoá các box phiên bản cũ (schema cũ) của đúng userId này
  Future<void> _cleanupOldBoxes(int userId) async {
    for (final prefix in _oldFriendBoxPrefixes) {
      final name = '$prefix$userId';
      if (await Hive.boxExists(name)) {
        try {
          await Hive.deleteBoxFromDisk(name);
        } catch (_) {}
      }
    }
    for (final prefix in _oldUserBoxPrefixes) {
      final name = '$prefix$userId';
      if (await Hive.boxExists(name)) {
        try {
          await Hive.deleteBoxFromDisk(name);
        } catch (_) {}
      }
    }
  }

  Future<void> saveFriends(List<Friend> friends) async {
    await _friendBox?.clear();
    await _friendBox?.addAll(friends);
  }

  List<Friend> loadFriends() {
    return _friendBox?.values.toList() ?? [];
  }

  Future<void> saveCurrentUser(DashboardModel user) async {
    await _userBox?.put('current', user);
  }

  DashboardModel? loadCurrentUser() {
    return _userBox?.get('current');
  }

  /// Gọi khi logout hoặc muốn xóa sạch cache local (không xóa key mã hóa)
  Future<void> clear() async {
    await _friendBox?.clear();
    await _userBox?.clear();
  }

  Future<void> close() async {
    await _friendBox?.close();
    await _userBox?.close();
  }
}