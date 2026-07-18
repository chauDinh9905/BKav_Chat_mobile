import 'package:first_flutter/core/networks/auth_service.dart';
import 'package:flutter/widgets.dart';
import '../../core/configs/app_configs.dart';
import '../models/dashboard.dart';
import 'dart:convert';
import '../../core/networks/socket_manager.dart';


class DashboardViewModel extends ChangeNotifier{
  final AuthService _authService;
  DashboardModel? _currentUser;
  DashboardModel? get currentUser => _currentUser;
  List<Friend> _allaFriends = [];
  List<Friend> _displayFriends = [];
  List<Friend> get friends => _displayFriends;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Friend> get displayFriends => _displayFriends;
  String _currentKeyword = '';
  DashboardViewModel(this._authService);

  Future<void> init() async{
    print("DEBUG: Đang gọi hàm init trong DashboardViewModel");
    _isLoading = true;
    notifyListeners();
    try {
      // Gọi API lấy thông tin user
      final profileResponse = await _authService.getCurrentUserProfile();
      if (profileResponse['status'] == 1) {
        print("Dữ liệu nhận được: ${profileResponse['data']}");
        _currentUser = DashboardModel.fromJson(profileResponse);
      }
      // Gọi API lấy danh sách bạn bè
      _allaFriends = await _authService.getFriendList();
      _resortFriends();

      await SocketManager.instance.connectToServer();
      if(_currentUser != null){
        SocketManager.instance.registerUser(_currentUser!.user_id);
      }
      SocketManager.instance.onMessage.listen((message) {
        print("DEBUG: Socket nhận được message: $message");
        _handleSocketMessage(message);
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
      print('$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String keyword){
    _currentKeyword = keyword;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_currentKeyword.isEmpty) {
      _displayFriends = List.from(_allaFriends);
    } else {
      _displayFriends = _allaFriends
          .where((f) => f.display_name.toLowerCase().contains(_currentKeyword.toLowerCase()))
          .toList();
    }
  }

  void _resortFriends() {
    _allaFriends.sort((a, b) {
      final aHasMsg = a.lastMsgTime.millisecondsSinceEpoch != 0;
      final bHasMsg = b.lastMsgTime.millisecondsSinceEpoch != 0;

      if (!aHasMsg && !bHasMsg) return 0; // giữ nguyên thứ tự gốc (stable sort của Dart)
      if (!aHasMsg) return 1;
      if (!bHasMsg) return -1;

      return b.lastMsgTime.compareTo(a.lastMsgTime);
    });
    _applyFilter();
  }
  String get currentUserAvatarUrl {
    if (_currentUser == null || _currentUser!.avatar_path.isEmpty) return '';
    return '${AppConfig.baseUrl}/images${_currentUser!.avatar_path}';
  }
  void _handleSocketMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final String? type = data['type'];

      if (type == 'presence') {
        _processStatusChange(data);
      } else if (data.containsKey('from') && data.containsKey('content')) {
        _processNewMessage(data);
      } else if (type != null) {
        print("System event: $type");
      }
    } catch (e) {
      print("Lỗi parse dữ liệu: $e");
    }
  }

  void _processNewMessage(Map<String, dynamic> data) {
    final int fromId = (data['from'] as num).toInt();
    final DateTime msgTime = DateTime.now();

    final index = _allaFriends.indexWhere((f) => f.user_id == fromId);
    if (index != -1) {
      _allaFriends[index].unreadCount += 1;
      _allaFriends[index].lastMsgTime = msgTime;
      _resortFriends(); // đẩy bạn vừa nhắn lên đầu danh sách
      notifyListeners();
    } else {
      print("DEBUG: Bỏ qua tin nhắn từ user $fromId vì không có trong list bạn bè");
    }
  }

  void _processStatusChange(Map<String, dynamic> data) {
    final int userId = (data['userId'] as num).toInt();
    final bool isOnline = data['isOnline'] as bool;
    final index = _allaFriends.indexWhere((f) => f.user_id == userId);
    if (index != -1) {
      _allaFriends[index].isOnline = isOnline;
      notifyListeners();
    } else {
      print("DEBUG: Bỏ qua user $userId vì không có trong list bạn bè");
    }
  }

  void resetUnreadCount(int friendId) {
    final index = _allaFriends.indexWhere((f) => f.user_id == friendId);
    if (index != -1 && _allaFriends[index].unreadCount != 0) {
      _allaFriends[index].unreadCount = 0;
      _applyFilter();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_currentUser != null) {
      SocketManager.instance.unregisterUser(_currentUser!.user_id);
    }
    super.dispose();
  }
}