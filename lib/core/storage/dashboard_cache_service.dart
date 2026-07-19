import 'package:hive_flutter/hive_flutter.dart';
import '../../chat/models/dashboard.dart';
import 'cache_key_manager.dart';

class DashboardCacheService {
  static const _friendBoxPrefix = 'friends_box_';
  static const _userBoxPrefix = 'user_box_';

  Box<Friend>? _friendBox;
  Box<DashboardModel>? _userBox;

  /// Mở box đã mã hóa, scope riêng theo userId (multi-account an toàn)
  Future<void> open(int userId) async {
    final key = await CacheKeyManager.getOrCreateKey(userId);
    final cipher = HiveAesCipher(key);

    _friendBox = await Hive.openBox<Friend>(
      '$_friendBoxPrefix$userId',
      encryptionCipher: cipher,
    );
    _userBox = await Hive.openBox<DashboardModel>(
      '$_userBoxPrefix$userId',
      encryptionCipher: cipher,
    );
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