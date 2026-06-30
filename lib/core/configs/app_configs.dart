import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Lấy dữ liệu từ file .env, nếu không có thì dùng giá trị mặc định

  static String get ip => dotenv.env['IP'] ?? '10.0.2.2';
  static String get port => dotenv.env['PORT'] ?? '8888';

  // Đây là các thuộc tính "thông minh" mà App sẽ sử dụng
  static String get baseUrl => 'http://$ip:$port/api';
  static String get socketUrl => 'ws://$ip:$port';

  // Bạn có thể thêm các config khác vào đây
  static const int timeoutSeconds = 30;
}