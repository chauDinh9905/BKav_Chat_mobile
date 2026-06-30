import 'package:dio/dio.dart';
import '../configs/app_configs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  late final Dio dio;
  final _storage = const FlutterSecureStorage();
  DioClient() {
    dio = Dio(
      BaseOptions(
        // Gọi trực tiếp từ AppConfig
        baseUrl: AppConfig.baseUrl,

        // Sử dụng timeout từ AppConfig
        connectTimeout: Duration(seconds: AppConfig.timeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.timeoutSeconds),

        // Cấu hình header mặc định
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm Interceptor để tự động đính kèm Token (nếu có)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'jwt_token');
        print("TOKEN ĐANG GỬI: $token");
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        //Khi server không tìm thấy token này (TH người dùng đăng nhập trên thiết bị mới)
        if (e.response?.statusCode == 401) {
          _storage.delete(key: 'jwt_token');
          // thêm code điều hướng tới LoginScreen ở đây
        }
        return handler.next(e);
      },
    ));
  }
  String getAvatarUrl(String filename){
    return '${AppConfig.baseUrl}/images/avatar/$filename';
  }
}