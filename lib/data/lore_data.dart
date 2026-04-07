import '../models/dungeon.dart';
import 'lore_content.dart';

class LoreData {
  static Map<String, String> get monsterDescription => LoreContent.monsterDescription;
  static Map<int, String> get numberLore => LoreContent.numberLore;
  static Map<RoomType, String> get roomTypeDescription => LoreContent.roomTypeDescription;

  static String getLore(int number) =>
      numberLore[number] ?? "정원의 익숙한 향기가 배어있는 파편입니다.";

  static String getRoomDesc(RoomType type) =>
      roomTypeDescription[type] ?? "설명할 수 없는 신비로운 공간입니다.";

  static String getMonsterDescription(String name) {
    if (monsterDescription.containsKey(name)) {
      return monsterDescription[name]!;
    }

    for (var key in monsterDescription.keys) {
      if (name.contains(key)) return monsterDescription[key]!;
    }

    return "이 존재는 아직 정체의 많은 부분이 베일에 싸여 있습니다. 누구도 그 기원을 정확히 알지 못하며, 오직 정원의 가장 깊숙한 곳에서만 그 기운을 느낄 수 있다고 합니다. 더 많은 연구와 탐험이 필요합니다.";
  }
}
