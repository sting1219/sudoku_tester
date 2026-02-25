import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_data.dart';
import '../models/dungeon.dart';
import '../data/lore_data.dart';
import 'mini_sudoku_grid.dart';

class ArchiveView extends StatelessWidget {
  final UserStats stats;

  const ArchiveView({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13221C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "GARDEN ARCHIVE",
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: stats.archive.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white24,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "아카이브가 비어 있습니다.\n던전을 탐험하여 유물을 수집하세요.",
                    style: GoogleFonts.cinzel(color: Colors.white38),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: stats.archive.length,
              itemBuilder: (context, index) {
                final room = stats.archive[index];
                return _buildArchiveCard(context, room);
              },
            ),
    );
  }

  Widget _buildArchiveCard(BuildContext context, ClearedRoom room) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2E26),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF3D522B), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: MiniSudokuGrid(snapshot: room.boardSnapshot),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "No. ${room.artifactNumber}",
                        style: GoogleFonts.cinzel(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        room.clearedDate,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.artifactName,
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoomTypeColor(room.type).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getRoomTypeColor(room.type).withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      room.type.name.toUpperCase(),
                      style: TextStyle(
                        color: _getRoomTypeColor(room.type),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LoreData.getRoomDesc(room.type),
                    style: const TextStyle(color: Colors.white54, fontSize: 9),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
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
}
