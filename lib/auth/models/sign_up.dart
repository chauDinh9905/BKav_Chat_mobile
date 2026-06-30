class UserRegisterModel{
  final String username;
  final String display_name;
  final String password_hash;

  UserRegisterModel({
    required this.username,
    required this.display_name,
    required this.password_hash,
  });
  factory UserRegisterModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UserRegisterModel(
      username: data['username'] ?? '',
      display_name: data['display_name'] ?? '',
      password_hash: data['password_hash'] ?? '',
    );
  }
}