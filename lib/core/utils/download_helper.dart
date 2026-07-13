import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadHelper {
  static const _prefsKeyPrefix = 'download_task_';

  /// Lưu taskId gắn với url, để lần sau biết file này đã tải chưa
  static Future<void> _saveTaskId(String url, String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyPrefix + url, taskId);
  }

  static Future<String?> _getTaskId(String url) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyPrefix + url);
  }
  static Future<void> _clearTaskId(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKeyPrefix + url);
  }

  /// Tra cứu task hiện tại (nếu có) và trạng thái + đường dẫn file thật
  static Future<DownloadTask?> _getExistingTask(String url) async {
    final taskId = await _getTaskId(url);
    if (taskId == null) return null;

    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE task_id='$taskId'",
    );
    if (tasks == null || tasks.isEmpty) return null;
    return tasks.first;
  }

  static Future<void> downloadFile(
      BuildContext context, {
        required String url,
        required String fileName,
      }) async {
    // Kiểm tra đã có task cho url này chưa
    final existing = await _getExistingTask(url);

    if (existing != null && existing.status == DownloadTaskStatus.complete) {
      // Đã tải xong trước đó, mở luôn
      final opened = await FlutterDownloader.open(taskId: existing.taskId);
      if (!opened) {
        // File thật sự không còn tồn tại (bị xoá thủ công) -> xoá taskId cũ, cho tải lại
        await _clearTaskId(url);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File không còn tồn tại, đang tải lại...')),
          );
        }
        await downloadFile(context, url: url, fileName: fileName);
      }
      return;
    }

    if (existing != null &&
        (existing.status == DownloadTaskStatus.running ||
            existing.status == DownloadTaskStatus.enqueued)) {
      // Đang tải dở, báo cho user biết, khỏi tải lại
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File đang được tải...')),
        );
      }
      return;
    }
    if (existing != null && existing.status == DownloadTaskStatus.failed) {
      // Task cũ lỗi, xoá và tải lại từ đầu
      await FlutterDownloader.remove(taskId: existing.taskId);
      await _clearTaskId(url);
    }
    // Chưa từng tải, bắt đầu tải mới
    final dir = await getExternalStorageDirectory();
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: dir!.path, // fallback dir, bị bỏ qua khi saveInPublicStorage=true
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );

    if (taskId != null) {
      await _saveTaskId(url, taskId);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đang tải $fileName...')),
      );
    }
  }
}