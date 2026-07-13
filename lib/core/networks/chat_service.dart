import 'dart:io';

import 'package:dio/dio.dart';
import '../../chat/models/chat.dart';


class ChatService {
  final Dio _dio;
  ChatService(this._dio);

  Future<List<ChatMessage>> getMessages(String friendId) async {
    final response = await _dio.get('/message/get-message', queryParameters: {'FriendID': friendId});
    if (response.data['status'] == 1) {
      return (response.data['data'] as List).map((e) => ChatMessage.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> sendMessage({
    required String friendId,
    required String content,
    List<File>? attachments,
  }) async {
    // Tạo FormData
    Map<String, dynamic> data = {
      'FriendID': friendId,
      'Content': content,
    };

    if (attachments != null && attachments.isNotEmpty) {
      data['files'] = await Future.wait(
        attachments.map(
              (f) => MultipartFile.fromFile(
            f.path,
            filename: f.path.split('/').last,
          ),
        ),
      );
    }

    FormData formData = FormData.fromMap(data);

    await _dio.post('/message/send-message', data: formData);
  }
}