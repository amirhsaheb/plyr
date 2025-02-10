import 'dart:io';

import 'package:flutter/material.dart';
import 'package:player_ahs_ir/models/music_provider.dart';
import 'package:player_ahs_ir/screens/driving_mode_screen.dart';
import 'package:player_ahs_ir/services/audio_player_service.dart';
import 'package:player_ahs_ir/services/download_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final _linkController = TextEditingController();
  final DownloadService _downloadService = DownloadService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  final uploadService = UploadService();
  final uploadUrl = 'https://example.com/upload.php'; // آدرس اسکریپت آپلود

  Future<void> _downloadMusic(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفاً لینک را وارد کنید.')),
      );
      return;
    }

    final fileName = 'music.mp3'; // نام پیش‌فرض فایل
    try {
      final path = await _downloadService.downloadFile(url, fileName);
      final newName = await showRenameDialog(context, fileName);
      if (newName != null) {
        final newPath = await _renameFile(path, newName);
        Provider.of<MusicProvider>(context, listen: false).addMusic(newPath);
        await uploadService.uploadFile(newPath, uploadUrl); // آپلود فایل
      }
    } catch (e) {
      print('خطا: $e');
    }
  }

  Future<String> _renameFile(String oldPath, String newName) async {
    final dir = File(oldPath).parent;
    final newPath = '${dir.path}/$newName';

    try {
      await File(oldPath).rename(newPath);
      return newPath;
    } catch (e) {
      throw Exception('خطا در تغییر نام فایل: $e');
    }
  }

  Future<String?> showRenameDialog(BuildContext context, String oldName) async {
    final newNameController = TextEditingController(text: oldName);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تغییر نام فایل'),
          content: TextField(controller: newNameController),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, newNameController.text),
              child: Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setSleepTimer(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      final now = DateTime.now();
      final duration = Duration(
        hours: time.hour - now.hour,
        minutes: time.minute - now.minute,
      );
      Future.delayed(duration, () {
        _audioPlayerService.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('پخش موسیقی متوقف شد.')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final _linkController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('آرشیو موسیقی')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _downloadMusic(context, _linkController.text),
            child: Text('دانلود موسیقی'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: musicProvider.musicList.length,
              itemBuilder: (context, index) {
                final musicPath = musicProvider.musicList[index];
                return ListTile(
                  title: Text(musicPath.split('/').last),
                  trailing: IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () => _audioPlayerService.play(musicPath),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DrivingModeScreen()),
              );
            },
            child: Text('حالت رانندگی'),
          ),
          IconButton(
            icon: Icon(Icons.timer),
            onPressed: () => _setSleepTimer(context),
          ),

// در بخش body از HomeScreen:
          TextField(
            controller: _linkController,
            decoration: InputDecoration(
              labelText: 'لینک دانلود موسیقی',
              hintText: 'لینک را اینجا وارد کنید',
            ),
          ),
          ElevatedButton(
            onPressed: () => _downloadMusic(context, _linkController.text),
            child: Text('دانلود و آپلود موسیقی'),
          ),
        ],
      ),
    );
  }
}
