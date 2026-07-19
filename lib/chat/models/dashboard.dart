import 'package:first_flutter/core/configs/app_configs.dart';
import 'package:hive/hive.dart';
part 'dashboard.g.dart';

@HiveType(typeId: 0)
class Friend{
  @HiveField(0)
 final int user_id;
  @HiveField(1)
 final String display_name;
  @HiveField(2)
 final String avatar_path;
  @HiveField(3)
 bool isOnline;
  @HiveField(4)
 int unreadCount;
  @HiveField(5)
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
@HiveType(typeId: 1)
class DashboardModel{
  @HiveField(0)
  final int user_id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String display_name;
  @HiveField(3)
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