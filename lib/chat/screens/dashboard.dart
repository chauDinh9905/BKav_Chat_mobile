import 'package:first_flutter/chat/viewmodels/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat.dart';

class Dashboard extends StatefulWidget{
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard>{
  final TextEditingController _timBanController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().init();
    });
  }
  @override
  Widget build(BuildContext context){
    final dashboardViewModel = context.watch<DashboardViewModel>();
    final listFriend = dashboardViewModel.friends;
    final currentUser = dashboardViewModel.currentUser;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false ,title: Text('BKav Chat', style: TextStyle(color: Colors.blue)),
                     actions:[
                       PopupMenuButton(
                         child: Padding(
                           padding: EdgeInsets.all(8.0),
                           child: CircleAvatar(
                               backgroundImage: currentUser != null && currentUser.avatar_path.isNotEmpty?
                               NetworkImage(currentUser.avatarUrl) : null,
                               child: currentUser == null || currentUser.avatar_path.isEmpty ?
                               Icon(Icons.person) : null),
                         ),
                         onSelected: (value){
                           if(value == 'log_out'){}
                           else if(value == 'change_avatar'){}
                         },
                         itemBuilder: (context) => [
                           PopupMenuItem(value: 'change_avatar', child: Text('Thay ảnh đại diện')),
                           PopupMenuItem(value: 'log_out', child: Text('Đăng xuất')),
                         ],
                       ),
                     ],
      ),
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(controller: _timBanController, onChanged: (value) => dashboardViewModel.search(value), decoration: InputDecoration(hintText: 'Tìm kiếm', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),),
          ),
          Expanded(
          child: dashboardViewModel.isLoading
          ? const Center(child: CircularProgressIndicator()):
            ListView.builder(
              itemCount: dashboardViewModel.friends.length,
              itemBuilder: (context, index){
                return ListTile(
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                    CircleAvatar(backgroundImage: listFriend[index].avatarUrl.isNotEmpty ? NetworkImage(listFriend[index].avatarUrl) : null,
                                        child: listFriend[index].avatarUrl.isEmpty ? Text(listFriend[index].display_name[0].toUpperCase()) : null),
                    if(listFriend[index].isOnline)
                      Positioned( right: 0, bottom: 0,child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),),)
                    else
                      Positioned( right: 0, bottom: 0,child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),),),

                    if(listFriend[index].unreadCount > 0)
                      Positioned( right: -5, bottom: -5,child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: BoxConstraints(minHeight: 18, minWidth: 18), child: Text('${listFriend[index].unreadCount}', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center,),),)
                    ],
                  ),
                  title: Text(listFriend[index].display_name),
                  onTap: (){
                    //return;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(friendId: listFriend[index].user_id, friendName: listFriend[index].display_name, avatarUrl: listFriend[index].avatarUrl, isOnline: listFriend[index].isOnline,)));
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}