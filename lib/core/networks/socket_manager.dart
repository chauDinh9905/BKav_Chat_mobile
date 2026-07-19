import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../configs/app_configs.dart';

class SocketManager {
  SocketManager._();

  static final SocketManager instance = SocketManager._();

  WebSocketChannel? _channel;

  /// stream phát khi socket kết nối thành công
  final StreamController<void> _connectedController =
  StreamController<void>.broadcast();

  Stream<void> get onConnected => _connectedController.stream;

  /// stream phát khi có message mới
  final StreamController<String> _messageController =
  StreamController<String>.broadcast();

  Stream<String> get onMessage => _messageController.stream;

  bool get isConnected => _channel != null;

  Future<void> connectToServer() async {
    if (_channel != null) return;

    final url = Uri.parse(AppConfig.socketUrl);

    _channel = WebSocketChannel.connect(url);
    await _channel!.ready;
    print("SOCKET ready");
    _connectedController.add(null);

    _channel!.stream.listen(
          (data) {
            print("[Socket] Dữ liệu thô nhận được từ server: $data");
        _messageController.add(data.toString());
      },
      onError: (error) {
        print("[Socket] Error: $error");
        _channel = null;
      },
      onDone: () {
        print("[Socket] Closed");
        _channel = null;
      },
    );
  }

  void sendMessage({
    required int from,
    required int to,
    required String content,
  }) {
    if (_channel == null) return;

    final json = {
      "from": from,
      "to": to,
      "content": content,
    };

    _channel!.sink.add(jsonEncode(json));
  }

  void registerUser(int userId) {
    if (_channel == null) return;

    final json = {
      "type": "register",
      "userId": userId,
    };

    _channel!.sink.add(jsonEncode(json));
  }

  void unregisterUser(int userId) {
    if (_channel == null) return;

    final json = {
      "type": "unregister",
      "userId": userId,
    };

    _channel!.sink.add(jsonEncode(json));

    disconnect();
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _connectedController.close();
    _messageController.close();
  }

  void markSeen({required int userId, required int friendId}) {
    if (_channel == null) return;
    final json = {
      "type": "mark_seen",
      "userId": userId,
      "friendId": friendId,
    };
    _channel!.sink.add(jsonEncode(json));
  }
}