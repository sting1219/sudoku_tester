// lib/views/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;
import '../models/ranking_model.dart';
import 'package:intl/intl.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<RankingEntry> _rankings = [];

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  void _loadRankings() {
    final String? jsonStr = web.window.localStorage.getItem('local_rankings');
    setState(() {
      _rankings = RankingManager.parseRankings(jsonStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "리더보드",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: _rankings.isEmpty
          ? const Center(
              child: Text("기록이 없습니다.", style: TextStyle(color: Colors.white54)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _rankings.length,
              itemBuilder: (context, index) {
                final entry = _rankings[index];
                return _buildRankingCard(index + 1, entry);
              },
            ),
    );
  }

  Widget _buildRankingCard(int rank, RankingEntry entry) {
    Color rankColor = Colors.white70;
    if (rank == 1) rankColor = Colors.amber;
    if (rank == 2) rankColor = Colors.grey[300]!;
    if (rank == 3) rankColor = Colors.brown[300]!;

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rankColor,
          child: Text(
            "$rank",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          entry.playerName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "${entry.stageName} - ${DateFormat('yyyy-MM-dd').format(entry.date)}",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${entry.score} PT",
              style: GoogleFonts.cinzel(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${entry.timeInSeconds}초",
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
