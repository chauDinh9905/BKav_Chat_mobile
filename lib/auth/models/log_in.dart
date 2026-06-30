class UserModel {
  final String token;
  final int user_id;
  final String username;
  final String display_name;
  final String? avatar_path;

  UserModel({
    required this.user_id,
    required this.username,
    required this.display_name,
    required this.token,
    this.avatar_path,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return UserModel(
      token: data['token'] ?? '',
      user_id: (data['user_id'] as num?)?.toInt() ?? 0,
      username: data['username'] ?? '',
      display_name: data['display_name'] ?? '',
      avatar_path: data['avatar_path'],
    );
  }
}