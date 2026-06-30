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
    File? file, // Truyền file nếu có
  }) async {
    // Tạo FormData
    Map<String, dynamic> data = {
      'FriendID': friendId,
      'Content': content,
    };

    // Nếu có file, thêm vào FormData
    if (file != null) {
      data['files'] = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );
    }

    FormData formData = FormData.fromMap(data);

    await _dio.post('/message/send-message', data: formData);
  }
}