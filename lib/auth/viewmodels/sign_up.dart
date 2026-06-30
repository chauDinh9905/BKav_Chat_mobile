import 'dart:convert';
import 'package:crypto/crypto.dart'; // Thư viện để băm SHA256
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/networks/auth_service.dart';

class SignUpViewModel extends ChangeNotifier{
  final AuthService _authService;
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
  }
  SignUpViewModel(this._authService);

  String _hashPassword(String password){
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> signup(String displayName, String username, String password) async{
    _isLoading = true;
    notifyListeners();

    try{
      final passwordHash = _hashPassword(password);
      final response = await _authService.register(displayName, username, passwordHash);
      String token = response['token'];
      print('Token cua tai khoan vua dang ky: $token');
      await _storage.write(key: 'jwt_token', value: token);
      _isLoading = false;
      notifyListeners();
      return true;
    }catch (e){
      _isLoading = false;
      notifyListeners();
      print("Lỗi đăng ký: $e");
      return false;
    }
  }
}