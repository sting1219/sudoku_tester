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

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AchievementCategory.values.length + 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getCategoryName(AchievementCategory? category) {
    if (category == null) return "전체";
    switch (category) {
      case AchievementCategory.combat:
        return "전투";
      case AchievementCategory.puzzle:
        return "퍼즐";
      case AchievementCategory.growth:
        return "성장";
      case AchievementCategory.collection:
        return "수집";
      case AchievementCategory.special:
        return "특별";
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAchievements = AchievementTemplates.allAchievements;
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: "전체"),
            ...AchievementCategory.values.map(
              (cat) => Tab(text: _getCategoryName(cat)),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: CurrencyService(),
        builder: (context, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _AchievementList(
                list: allAchievements,
                unlocked: unlocked,
                claimed: claimed,
                onClaim: () => setState(() {}),
              ),
              ...AchievementCategory.values.map((cat) {
                final filtered = allAchievements
                    .where((a) => a.category == cat)
                    .toList();
                return _AchievementList(
                  list: filtered,
                  unlocked: unlocked,
                  claimed: claimed,
                  onClaim: () => setState(() {}),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementList extends StatefulWidget {
  final List<Achievement> list;
  final Set<String> unlocked;
  final Set<String> claimed;
  final VoidCallback onClaim;

  const _AchievementList({
    required this.list,
    required this.unlocked,
    required this.claimed,
    required this.onClaim,
  });

  @override
  State<_AchievementList> createState() => _AchievementListState();
}

class _AchievementListState extends State<_AchievementList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.list.isEmpty) {
      return const Center(
        child: Text(
          "해당 카테고리의 업적이 없습니다.",
          style: TextStyle(color: Colors.white24),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        final achievement = widget.list[index];
        final isUnlocked = widget.unlocked.contains(achievement.id);
        final isClaimed = widget.claimed.contains(achievement.id);
        return _AchievementCard(
          achievement: achievement,
          isUnlocked: isUnlocked,
          isClaimed: isClaimed,
          onClaim: widget.onClaim,
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final bool isClaimed;
  final VoidCallback onClaim;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    required this.isClaimed,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildActionButton(context),
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

  Widget _buildActionButton(BuildContext context) {
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
          onClaim();
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
