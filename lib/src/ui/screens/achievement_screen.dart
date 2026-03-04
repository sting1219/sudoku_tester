import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/achievement_model.dart';
import '../../../models/user_data.dart';
import '../../../services/currency_service.dart';

class AchievementScreen extends StatefulWidget {
  final UserData userData;

  const AchievementScreen({super.key, required this.userData});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  Widget build(BuildContext context) {
    final achievements = AchievementTemplates.allAchievements;
    final unlocked = widget.userData.stats.unlockedAchievementIds;
    final claimed = widget.userData.stats.claimedAchievementIds;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "업적 및 보상",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: ListenableBuilder(
        listenable: CurrencyService(),
        builder: (context, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final isUnlocked = unlocked.contains(achievement.id);
              final isClaimed = claimed.contains(achievement.id);

              return _buildAchievementCard(achievement, isUnlocked, isClaimed);
            },
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement,
    bool isUnlocked,
    bool isClaimed,
  ) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnlocked && !isClaimed
            ? const BorderSide(color: Colors.amberAccent, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.amber.withValues(alpha: 0.1)
                    : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                color: isUnlocked ? Colors.amberAccent : Colors.white24,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.white24,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white70 : Colors.white12,
                      fontSize: 12,
                    ),
                  ),
                  if (isUnlocked) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (achievement.rewardGold > 0)
                          _buildRewardBadge(
                            Icons.monetization_on,
                            "${achievement.rewardGold}G",
                            Colors.amber,
                          ),
                        if (achievement.rewardGems > 0) ...[
                          const SizedBox(width: 8),
                          _buildRewardBadge(
                            Icons.diamond,
                            "${achievement.rewardGems}",
                            Colors.cyanAccent,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            _buildActionButton(achievement, isUnlocked, isClaimed),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    Achievement achievement,
    bool isUnlocked,
    bool isClaimed,
  ) {
    if (isClaimed) {
      return const Column(
        children: [
          Icon(Icons.check_circle, color: Colors.greenAccent),
          Text("완료", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
        ],
      );
    }

    if (isUnlocked) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () {
          CurrencyService().claimAchievementReward(achievement);
          setState(() {}); // 로컬 상태 업데이트
        },
        child: const Text("받기", style: TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return const Text(
      "진행 중",
      style: TextStyle(color: Colors.white24, fontSize: 12),
    );
  }
}
