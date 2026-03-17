import 'package:flutter/material.dart';

class DungeonTheme {
  final String name;
  final int minLevel;
  final int maxLevel;
  final Color primaryColor;
  final IconData icon;
  final String description;

  const DungeonTheme({
    required this.name,
    required this.minLevel,
    required this.maxLevel,
    required this.primaryColor,
    required this.icon,
    required this.description,
  });

  static const List<DungeonTheme> allThemes = [
    DungeonTheme(
      name: "고요한 시작의 숲",
      minLevel: 1,
      maxLevel: 10,
      primaryColor: Color(0xFF2D5A27),
      icon: Icons.forest,
      description:
          "정화가 시작되는 평화로운 숲입니다. 약한 숫자 슬라임들이 주로 서식하며, 정화의 기초를 배우기에 적합한 장소입니다.",
    ),
    DungeonTheme(
      name: "타오르는 심연의 굴",
      minLevel: 11,
      maxLevel: 25,
      primaryColor: Color(0xFF8B0000),
      icon: Icons.local_fire_department,
      description:
          "뜨거운 열기로 가득 찬 동굴입니다. 불꽃의 숫괴물들이 침입자의 정신을 혼미하게 만들며, 빠른 정화 속도가 요구됩니다.",
    ),
    DungeonTheme(
      name: "꽁꽁 얼어붙은 성벽",
      minLevel: 26,
      maxLevel: 45,
      primaryColor: Color(0xFF0047AB),
      icon: Icons.ac_unit,
      description:
          "모든 것이 멈춰버린 얼음 요새입니다. 숫자들이 얼어붙어 판별하기 어렵고, 틀릴 경우 생명력이 더 크게 감소합니다.",
    ),
    DungeonTheme(
      name: "공허의 마법 도서관",
      minLevel: 46,
      maxLevel: 70,
      primaryColor: Color(0xFF4B0082),
      icon: Icons.auto_stories,
      description:
          "잊혀진 지식들이 떠다니는 곳입니다. 환영 숫자들이 나타나 시야를 방해하며, 높은 집중력이 필요한 고난도 구간입니다.",
    ),
    DungeonTheme(
      name: "황금빛 신들의 성전",
      minLevel: 71,
      maxLevel: 99,
      primaryColor: Color(0xFFD4AF37),
      icon: Icons.account_balance,
      description:
          "정화의 마지막 단계인 성전입니다. 가장 강력한 숫자 정령들이 등장하며, 정화 완료 시 엄청난 보상을 얻을 수 있습니다.",
    ),
  ];
}
