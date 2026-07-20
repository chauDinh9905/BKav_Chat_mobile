import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:first_flutter/core/configs/app_configs.dart';
import '../viewmodels/chat.dart';
import '../models/chat.dart';
import '../../core/utils/download_helper.dart';
import '../viewmodels/dashboard.dart';

class ChatScreen extends StatefulWidget {
  final int myId;
  final int friendId;
  final String friendName;
  final String avatarUrl;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.myId,
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
  final FocusNode _textFieldFocus = FocusNode();
  late final ChatViewModel _chatViewModel;
  late final DashboardViewModel _dashboardViewModel;
  bool _viewModelsReady = false;

  // Danh sách file/ảnh đang chờ gửi (chưa submit)
  final List<File> _pendingImages = [];
  final List<File> _pendingFiles = [];

  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ChatViewModel>();
      vm.loadMessages(widget.friendId.toString());
      vm.listenSocket(myId: widget.myId, friendId: widget.friendId);
      context.read<ChatViewModel>().loadMessages(widget.friendId.toString());
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_viewModelsReady) {
      _chatViewModel = context.read<ChatViewModel>();
      _dashboardViewModel = context.read<DashboardViewModel>();
      _viewModelsReady = true;
    }
  }
  @override
  void dispose() {
    _chatViewModel.stopListening();
    _dashboardViewModel.resetUnreadCount(widget.friendId);
    _messageController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  bool get _canSend =>
      _messageController.text.trim().isNotEmpty ||
          _pendingImages.isNotEmpty ||
          _pendingFiles.isNotEmpty;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _pendingImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _pendingFiles.addAll(
          result.paths.whereType<String>().map((p) => File(p)),
        );
      });
    }
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      _textFieldFocus.requestFocus();
    } else {
      _textFieldFocus.unfocus();
    }
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final text = _messageController.text;
    final selection = _messageController.selection;
    final cursor = selection.start < 0 ? text.length : selection.start;
    final newText = text.replaceRange(cursor, cursor, emoji.emoji);
    _messageController.text = newText;
    _messageController.selection = TextSelection.collapsed(
      offset: cursor + emoji.emoji.length,
    );
    setState(() {});
  }

  void _handleSend() {
    if (!_canSend) return;
    final content = _messageController.text.trim();
    final attachments = [..._pendingImages, ..._pendingFiles];

    context.read<ChatViewModel>().sendMessage(
      widget.friendId.toString(),
      content,
      attachments: attachments.isEmpty ? null : attachments,
    );

    _messageController.clear();
    setState(() {
      _pendingImages.clear();
      _pendingFiles.clear();
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
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10),
            Text(widget.friendName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, vm, child) {
                ChatMessage? lastMine;
                for (final m in vm.messages) {
                  if (m.messageType == 1) lastMine = m;
                }
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(10),
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    final msg = vm.messages[vm.messages.length - 1 - index];
                    return _MessageBubble(msg: msg, showStatus: lastMine != null && msg.id == lastMine.id,);
                  },
                );
              },
            ),
          ),
          if (_pendingImages.isNotEmpty || _pendingFiles.isNotEmpty) _buildPendingPreview(),
          _buildInputArea(context),
          if (_showEmojiPicker)
            SizedBox(
              height: 280,
              child: EmojiPicker(onEmojiSelected: _onEmojiSelected),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingPreview() {
    return Container(
      height: 90,
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (int i = 0; i < _pendingImages.length; i++)
            _PendingThumb(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_pendingImages[i], width: 70, height: 70, fit: BoxFit.cover),
              ),
              onRemove: () => setState(() => _pendingImages.removeAt(i)),
            ),
          for (int i = 0; i < _pendingFiles.length; i++)
            _PendingThumb(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insert_drive_file, color: Colors.blueGrey),
                    SizedBox(height: 2),
                    Text(
                      _pendingFiles[i].path.split('/').last,
                      style: TextStyle(fontSize: 9),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              onRemove: () => setState(() => _pendingFiles.removeAt(i)),
            ),
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
          IconButton(
            icon: Icon(Icons.emoji_emotions, color: Colors.grey),
            onPressed: _toggleEmojiPicker,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _textFieldFocus,
                      onTap: () {
                        if (_showEmojiPicker) setState(() => _showEmojiPicker = false);
                      },
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Nhập tin nhắn",
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _canSend ? _handleSend : null,
                    icon: Icon(Icons.send, color: _canSend ? Colors.blue : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.attach_file, color: Colors.grey), onPressed: _pickFiles),
          IconButton(icon: Icon(Icons.image, color: Colors.grey), onPressed: _pickImages),
        ],
      ),
    );
  }
}

class _PendingThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  const _PendingThumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ImageViewerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ImageViewerButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool showStatus;
  const _MessageBubble({required this.msg, this.showStatus = false});

  @override
  Widget build(BuildContext context) {
    bool isMe = msg.messageType == 1;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe ? Colors.blueAccent : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (msg.images.isNotEmpty) _buildImageGrid(context),
                if (msg.files.isNotEmpty) _buildFileChips(context, isMe),
                if (msg.content.trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      top: (msg.images.isNotEmpty || msg.files.isNotEmpty) ? 6 : 0,
                      left: 4,
                      right: 4,
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
              ],
            ),
          ),
          if (showStatus)
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 4),
              child: Text(
                _statusText(msg.isSend),
                style: TextStyle(
                  fontSize: 11,
                  color: msg.isSend == 2 ? Colors.blueAccent : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _statusText(int status) {
    switch (status) {
      case 2:
        return 'Đã xem';
      case 1:
        return 'Đã nhận';
      default:
        return 'Đã gửi';
    }
  }
  Widget _buildImageGrid(BuildContext context) {
    final images = msg.images;
    final crossAxisCount = images.length >= 3 ? 3 : images.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: images.length,
      itemBuilder: (context, i) {
        final url = AppConfig.baseUrl + (images[i]['urlImage'] ?? '');
        final fileName = images[i]['FileName'] as String? ??
            url.split('/').last;
        return GestureDetector(
          onTap: () => _openImageViewer(context, url, fileName),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.grey, child: Icon(Icons.broken_image)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFileChips(BuildContext context, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: msg.files.map<Widget>((f) {
        final rawPath = f['urlFile'] as String?;
        final name = f['FileName'] ?? 'file';
        if (rawPath == null || rawPath.isEmpty) return const SizedBox.shrink();
        final url = Uri.parse(rawPath).hasScheme ? rawPath : '${AppConfig.baseUrl}$rawPath';
        return Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: GestureDetector(
            onTap: () {
              debugPrint('Opening file URL: $url');
              debugPrint('Downloading file: $url');
              DownloadHelper.downloadFile(context,url: url,fileName: name,);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.white24 : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insert_drive_file, size: 18, color: isMe ? Colors.white : Colors.blueGrey),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      name,
                      style: TextStyle(fontSize: 13, color: isMe ? Colors.white : Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _openImageViewer(BuildContext context, String url, String fileName) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: Center(
                  child: Image.network(
                    url,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  _ImageViewerButton(
                    icon: Icons.download,
                    onTap: () {
                      debugPrint('Downloading image: $url');
                      DownloadHelper.downloadFile(
                        context,
                        url: url,
                        fileName: fileName,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _ImageViewerButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}