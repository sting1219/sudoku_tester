import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';
import '../services/currency_service.dart';
import 'world_map_screen.dart';
import '../src/ui/screens/collection_screen.dart';
import 'shop_screen.dart';
import 'sudoku_screen.dart';
import 'dev_log_view.dart';
import '../src/ui/screens/achievement_screen.dart';

class LobbyScreen extends StatefulWidget {
  final UserData userData;

  const LobbyScreen({super.key, required this.userData});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  int _currentIndex = 0;

  void _onStageSelect(int stageIndex) {
    // 스테이지 선택 시 게임 화면으로 전환
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SudokuScreen(
          isGameStarted: true,
          isDailyChallenge: false,
        ),
      ),
    );
  }

  void _onDailyChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SudokuScreen(
          isGameStarted: true,
          isDailyChallenge: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      WorldMapScreen(
        userData: widget.userData,
        onStageSelect: _onStageSelect,
        onDailyChallenge: _onDailyChallenge,
      ),
      CollectionScreen(userData: widget.userData),
      const ShopScreen(),
      AchievementScreen(userData: widget.userData),
      const DevLogView(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Consumer<CurrencyService>(
          builder: (context, currency, child) {
            return AppBar(
              backgroundColor: const Color(0xFF1E293B),
              elevation: 8,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A).withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTopStat(
                    context,
                    Icons.stars,
                    "LV.${currency.level}",
                    Colors.amber,
                  ),
                  _buildTopStat(
                    context,
                    Icons.monetization_on,
                    "${currency.gold} G",
                    Colors.amberAccent,
                  ),
                  _buildTopStat(
                    context,
                    Icons.diamond,
                    "${currency.gems}",
                    Colors.cyanAccent,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: Colors.indigoAccent,
          unselectedItemColor: Colors.blueGrey,
          selectedLabelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.notoSans(),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "Adventure",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Collection",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Shop",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: "Achievement",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_edu),
              label: "DevLog",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStat(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
