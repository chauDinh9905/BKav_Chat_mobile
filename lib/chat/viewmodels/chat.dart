import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/networks/chat_service.dart';
import '../models/chat.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

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

  Future<void> sendMessage(String friendId, String content, {List<File>? attachments}) async {
    await _chatService.sendMessage(friendId: friendId, content: content, attachments: attachments);
    await loadMessages(friendId); // Cập nhật lại list sau khi gửi
  }
}