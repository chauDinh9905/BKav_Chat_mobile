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
      _displayFriends = _allaFriends;

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
    if(keyword.isEmpty) {
      _displayFriends = _allaFriends;
    } else{
      _displayFriends = _allaFriends.where((f) => (f.display_name.toLowerCase()).contains(keyword.toLowerCase())).toList();
    }
    notifyListeners();
  }
  String get currentUserAvatarUrl {
    if (_currentUser == null || _currentUser!.avatar_path.isEmpty) return '';
    return '${AppConfig.baseUrl}/images${_currentUser!.avatar_path}';
  }
  void _handleSocketMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      String type = data['type'];
      if(type == 'presence'){
        int userId = (data['userId'] as num).toInt();
        bool isOnline = data['isOnline'] as bool;
        final index = _allaFriends.indexWhere((f) => f.user_id == userId);

        if (index != -1) {
          _allaFriends[index].isOnline = isOnline;
          print("DEBUG: Cập nhật status user $userId thành $isOnline");
          notifyListeners();
        } else {
          print("DEBUG: Bỏ qua user $userId vì không có trong list bạn bè");
        }
      }
      else if (data.containsKey('from') && data.containsKey('content')) {
        _processNewMessage(data);
      }
      else if (data.containsKey('userId') && data.containsKey('isOnline')) {
        _processStatusChange(data);
      }
      else if (data.containsKey('type')) {
        print("System event: ${data['type']}");
      }

    } catch (e) {
      print("Lỗi parse dữ liệu: $e");
    }
  }

  void _processNewMessage(Map<String, dynamic> data) {
    int fromId = data['from'];
    // Cập nhật unreadCount
    for (var f in _allaFriends) {
      if (f.user_id == fromId) {
        f.unreadCount += 1;
        break;
      }
    }
    notifyListeners(); // Cập nhật UI
  }

  void _processStatusChange(Map<String, dynamic> data) {
    int userId = data['userId'];
    bool status = data['isOnline'];
    // Cập nhật isOnline
    for (var f in _allaFriends) {
      if (f.user_id == userId) {
        f.isOnline = status;
        break;
      }
    }
    notifyListeners(); // Cập nhật UI
  }

  @override
  void dispose() {
    if (_currentUser != null) {
      SocketManager.instance.unregisterUser(_currentUser!.user_id);
    }
    super.dispose();
  }
}