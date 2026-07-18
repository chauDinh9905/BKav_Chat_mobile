import 'package:first_flutter/core/configs/app_configs.dart';

class Friend{
 final int user_id;
 final String display_name;
 final String avatar_path;
 bool isOnline;
 int unreadCount;
 DateTime lastMsgTime;

  Friend({
   required this.user_id,
   required this.display_name,
   required this.avatar_path,
    this.isOnline = false,
    this.unreadCount = 0,
    required this.lastMsgTime,
  });
  factory Friend.fromJson(Map<dynamic, dynamic> json){
    return Friend(
      user_id: json['FriendID'] ?? 0,
      display_name: json['FullName'] ?? '',
      avatar_path: json['Avatar'] ?? '',
      isOnline: json['isOnline'] ?? false,
      unreadCount: json['UnreadCount'] ?? 0,
      lastMsgTime: json['LastMsgTime'] != null
          ? DateTime.tryParse(json['LastMsgTime']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
  String get avatarUrl{
    if(avatar_path.isEmpty) return '';
    return '${AppConfig.baseUrl}/images$avatar_path';
  }
}
class DashboardModel{
  final int user_id;
  final String username;
  final String display_name;
  final String avatar_path;

  DashboardModel({
   required this.user_id,
   required this.username,
   required this.display_name,
   required this.avatar_path,
  });

  factory DashboardModel.fromJson(Map<dynamic, dynamic> json){
    final data = json['data'];
    return DashboardModel(
      user_id: data['Id'] ?? 0,
      username: data['Username'] ?? '',
      display_name: data['FullName'] ?? '',
      avatar_path: data['Avatar'] ?? '',
    );
  }
  String get avatarUrl {
    if (avatar_path.isEmpty) return '';
    return '${AppConfig.baseUrl}/images$avatar_path';

  }
}