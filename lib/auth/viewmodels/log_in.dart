import 'dart:convert';
import 'package:crypto/crypto.dart'; // Thư viện để băm SHA256
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/networks/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LoginViewModel(this._authService);

  // Hàm băm mật khẩu SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      //  Băm mật khẩu trước khi gửi lên server
      final hashedPassword = _hashPassword(password);

      //  Gọi API login
      final user = await _authService.login(username, hashedPassword);

      //  Lưu Token
      await _storage.write(key: 'jwt_token', value: user.token);

      _isLoading = false;
      notifyListeners();
      return true; // Login thành công
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Lỗi đăng nhập: $e");
      return false; // Login thất bại
    }
  }
}