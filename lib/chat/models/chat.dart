class ChatMessage{
  final String id;
  final String content;
  final List<dynamic> files;
  final List<dynamic> images;
  final int isSend;
  final DateTime createAt;
  final int messageType;

  ChatMessage({
    required this.id,
    required this.content,
    required this.files,
    required this.images,
    required this.isSend,
    required this.createAt,
    required this.messageType
  });

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json){
    return ChatMessage(
      // 'id' trong server là ObjectId, khi trả về json nó là chuỗi _id
        id: json['id']?.toString() ?? '',
        content: json['Content'] ?? '',
        files: (json['Files'] as List?) ?? [],
        images: (json['Images'] as List?) ?? [],
        // isSend: Server trả về number 0 hoặc 1
        isSend: json['isSend'] ?? 0,
        createAt: json['CreatedAt'] != null
            ? DateTime.parse(json['CreatedAt'].toString())
            : DateTime.now(),
        messageType: json['MessageType'] ?? 0,
    );
  }

}