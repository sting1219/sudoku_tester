import 'package:flutter/material.dart';
import '../models/dungeon_theme.dart';
import '../models/user_data.dart';
import 'currency_service.dart';

class StageManager extends ChangeNotifier {
  static final StageManager _instance = StageManager._internal();
  factory StageManager() => _instance;
  StageManager._internal();

  void init(UserData userData) {
    // userData는 CurrencyService를 통해 접근합니다.
  }

  // 누적 클리어한 방 개수 + 1
  int get currentRoomNumber => (CurrencyService().userData.stats.totalRoomsCleared) + 1;
  
  // 10개 방마다 월드가 바뀐다고 가정 (1~10: World 1, 11~20: World 2 ...)
  int get currentWorldIndex => (currentRoomNumber - 1) ~/ 10;
  
  DungeonTheme get currentWorldTheme {
    int index = currentWorldIndex;
    if (index >= DungeonTheme.allThemes.length) {
      index = DungeonTheme.allThemes.length - 1;
    }
    return DungeonTheme.allThemes[index];
  }

  // 10의 배수 방에서 보스 등장
  bool get isBossStage => currentRoomNumber % 10 == 0;

  String get stageName => "Stage $currentRoomNumber";
  String get worldName => currentWorldTheme.name;
  
  String get fullStageText => "$worldName - ${((currentRoomNumber - 1) % 10) + 1}";
}
