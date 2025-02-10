import 'package:flutter/material.dart';

class MusicProvider with ChangeNotifier {
  List<String> musicList = [];

  void addMusic(String musicPath) {
    musicList.add(musicPath);
    notifyListeners();
  }
}
