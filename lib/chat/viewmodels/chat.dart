import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/networks/chat_service.dart';
import '../../core/networks/socket_manager.dart';
import '../models/chat.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int? _myId;
  int? _friendId;
  StreamSubscription<String>? _socketSub;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatViewModel(this._chatService);

  Future<void> loadMessages(String friendId) async {
    _isLoading = true;
    notifyListeners();
    _messages = await _chatService.getMessages(friendId);
    _isLoading = false;
    notifyListeners();
  }

  void listenSocket({required int myId, required int friendId}) {
    _myId = myId;
    _friendId = friendId;
    _socketSub?.cancel();
    _socketSub = SocketManager.instance.onMessage.listen(_handleSocketData);
    SocketManager.instance.markSeen(userId: myId, friendId: friendId);
  }

  void _handleSocketData(String raw) {
    final obj = jsonDecode(raw) as Map<String, dynamic>;
    final type = obj['type']?.toString();

    if (type == 'message_delivered') {
      updateMessageStatus(obj['messageId']?.toString() ?? '', 1);
      return;
    }
    if (type == 'message_seen') {
      final byId = int.tryParse(obj['by']?.toString() ?? '');
      if (byId != null && byId == _friendId) {
        markAllMineSeen();
      }
      return;
    }

    // tin nhắn mới từ đối phương
    final senderId = int.tryParse(obj['from']?.toString() ?? '');
    if (senderId == null || senderId != _friendId) return;

    final msg = ChatMessage(
      id: obj['id']?.toString() ?? '',
      content: obj['content']?.toString() ?? '',
      files: (obj['files'] as List?) ?? [],
      images: (obj['images'] as List?) ?? [],
      isSend: 1,
      createAt: obj['createdAt'] != null
          ? DateTime.tryParse(obj['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      messageType: 0,
    );
    _messages.add(msg);
    notifyListeners();

    if (_myId != null && _friendId != null) {
      SocketManager.instance.markSeen(userId: _myId!, friendId: _friendId!);
    }
  }

  Future<void> sendMessage(String friendId, String content, {List<File>? attachments}) async {
    final sentMsg = await _chatService.sendMessage(
      friendId: friendId,
      content: content,
      attachments: attachments,
    );
    if (sentMsg != null) {
      _messages.add(sentMsg);
      notifyListeners();
    }
  }
  void updateMessageStatus(String messageId, int status) {
    final idx = _messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    _messages[idx] = _messages[idx].copyWith(isSend: status);
    notifyListeners();
  }
  void markAllMineSeen() {
    bool changed = false;
    _messages = _messages.map((m) {
      if (m.messageType == 1 && m.isSend < 2) {
        changed = true;
        return m.copyWith(isSend: 2);
      }
      return m;
    }).toList();
    if (changed) notifyListeners();
  }
  void stopListening() {
    _socketSub?.cancel();
    _socketSub = null;
    _myId = null;
    _friendId = null;
  }
}