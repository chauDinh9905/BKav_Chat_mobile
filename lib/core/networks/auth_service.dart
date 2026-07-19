import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../configs/app_configs.dart';
import '../../auth/models/log_in.dart';
import '../../chat/models/dashboard.dart';
import 'dio_client.dart';

class AuthService {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();
  AuthService(DioClient dioClient) : _dio = dioClient.dio;

  Future<UserModel> login(String username, String password) async {
    try {
      // Gửi request tới server
      print("BASE URL: ${AppConfig.baseUrl}");
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      //  Kiểm tra status trả về từ Server
      // status 1 là thành công
      if (response.data['status'] == 1) {
        print("login successfull");
        return UserModel.fromJson(response.data);
      } else {
        // Nếu server báo lỗi (status 0), ném ra ngoại lệ với message từ server
        print("login failed");
        throw Exception(response.data['message'] ?? 'Đăng nhập thất bại');
      }
    } on DioException catch (e) {
      // Xử lý lỗi từ Dio (mất mạng, server timeout, 404, 500...)
      throw Exception('Kết nối máy chủ thất bại: ${e.message}');
      // về sau điều hướng để hiện ra view lost connection to internet
    } catch (e) {
      // Bắt các lỗi không xác định
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> register(String displayName, String username, String passwordHash) async{
    try{
      final response = await _dio.post(
        '/auth/register',
        data: {
          'display_name': displayName,
          'username': username,
          'password': passwordHash,
        },
      );
      if(response.data['status'] == 1){
        print('sign up successful');
        //return UserRegisterModel.fromJson(response.data);
        return response.data['data'];
      }else{
        print('sign up failed');
        throw Exception(response.data['message'] ?? 'Đăng ký thất bại');
      }
    }on DioException catch(e){
      throw Exception('Kết nối máy chủ thất bại: ${e.message}');
    }catch (e){
      throw Exception(e.toString());
    }
  }
  Future<List<Friend>> getFriendList() async{
    //final response = await _dio.get('/user/list');
    final response = await _dio.get('/message/list-friend');
    if(response.data['status'] == 1){
      print('Lấy danh sách bạn bè thành công');
      return (response.data['data'] as List).map((e) => Friend.fromJson(e)).toList();
    }
    print('Lấy danh sách bạn bè thất bại');
    return [];
  }
  Future<Map<dynamic, dynamic>> getCurrentUserProfile() async{
    try{
      print("Đang gọi API tới: ${_dio.options.baseUrl}/user/info");
      final response = await _dio.get('/user/info');
      if(response.statusCode == 200){
        print('Load dữ liệu người dùng thành công');
        return response.data;
      }
      return {};
    }catch(e){
      throw Exception('Failed to load user profile: $e');
    }
  }
  Future<void> saveLastUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_user_id', userId);
  }

  Future<int?> getLastUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_user_id');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token'); // sửa key + nguồn lưu trữ cho đúng
  }
  Future<Map<String, dynamic>> updateAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });
      final response = await _dio.post(
        '/user/update',
        data: formData,
      );
      if (response.data['status'] == 1) {
        print('Cập nhật ảnh đại diện thành công');
        return response.data;
      }
      print('Cập nhật ảnh đại diện thất bại');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Kết nối máy chủ thất bại: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}