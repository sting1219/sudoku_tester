import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dungeon.dart';

class RoomInfoDialog extends StatelessWidget {
  final RoomData room;

  const RoomInfoDialog({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF13221C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3D522B), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 방 타입 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoomTypeColor(room.type),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getRoomTypeName(room.type),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 유물 아이콘 (숫자)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E5FF), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  room.artifactNumber.toString(),
                  style: GoogleFonts.cinzel(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 유물 이름
            Text(
              room.artifactName,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 설정 문구 (Lore)
            Text(
              room.artifactLore,
              style: GoogleFonts.cinzel(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // 닫기 버튼
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A4C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("닫기"),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoomTypeColor(RoomType type) {
    switch (type) {
      case RoomType.boss:
        return Colors.purpleAccent;
      case RoomType.elite:
        return Colors.orangeAccent;
      case RoomType.shop:
        return Colors.blueAccent;
      case RoomType.normal:
        return Colors.greenAccent;
    }
  }

  String _getRoomTypeName(RoomType type) {
    switch (type) {
      case RoomType.boss:
        return "BOSS ROOM";
      case RoomType.elite:
        return "ELITE ROOM";
      case RoomType.shop:
        return "GARDEN SHOP";
      case RoomType.normal:
        return "NORMAL ROOM";
    }
  }
}
