import 'package:flutter/material.dart';
import 'package:player_ahs_ir/models/music_provider.dart';
import 'package:player_ahs_ir/services/audio_player_service.dart';
import 'package:provider/provider.dart';

class DrivingModeScreen extends StatelessWidget {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('حالت رانندگی')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: musicProvider.musicList.length,
              itemBuilder: (context, index) {
                final musicPath = musicProvider.musicList[index];
                return ListTile(
                  title: Text(
                    musicPath.split('/').last,
                    style: TextStyle(fontSize: 24),
                  ),
                  onTap: () => _audioPlayerService.play(musicPath),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
