import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/chat.dart';


class ChatScreen extends StatefulWidget {
  final int friendId;
  final String friendName;
  final String avatarUrl;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.avatarUrl,
    required this.isOnline,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load tin nhắn khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadMessages(widget.friendId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(widget.avatarUrl)),
                Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: widget.isOnline ? Colors.green : Colors.grey, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              ],
            ),
            SizedBox(width: 10),
            Text(widget.friendName),
          ],
        ),
      ),
      body: Column(
        children: [
          // Danh sách tin nhắn
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, vm, child) {
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    final msg = vm.messages[index];
                    bool isMe = msg.messageType == 1;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Khung nhập tin nhắn
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.emoji_emotions, color: Colors.grey), onPressed: () {}),
          Expanded(
            child: Container(decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(25)),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(hintText: "Nhập tin nhắn ", contentPadding: EdgeInsets.symmetric(horizontal: 15), border: InputBorder.none),
                )),
                IconButton(onPressed: (){
                  if(_messageController.text.trim().isNotEmpty){
                    context.read<ChatViewModel>().sendMessage(widget.friendId.toString(), _messageController.text);
                    _messageController.clear();
                  }
                }, icon: Icon(Icons.send, color: Colors.blue),)
              ],
            ))
          ),
          IconButton(icon: Icon(Icons.attach_file, color: Colors.grey), onPressed: () {}),
          IconButton(icon: Icon(Icons.image, color: Colors.grey), onPressed: () {}),
        ],
      ),
    );
  }
}