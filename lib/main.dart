import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'views/world_map_screen.dart';
import 'views/inventory_screen.dart';
import 'views/sudoku_screen.dart';
import 'views/dev_log_view.dart';
import 'src/ui/screens/wiki_screen.dart'; // 새로운 위키 스크린 임포트
import 'src/ui/screens/achievement_screen.dart'; // 업적 화면 임포트
import 'services/currency_service.dart';
import 'models/user_data.dart';
import 'services/achievement_service.dart';
import 'widgets/achievement_toast.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku RPG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isGameStarted = false;
  bool _isDailyChallenge = false;
  UserData _userData = UserData.initial();
  StreamSubscription? _achievementSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupAchievementListener();
  }

  void _setupAchievementListener() {
    _achievementSubscription = AchievementService().onAchievementUnlocked
        .listen((achievement) {
          if (mounted) {
            AchievementToast.show(context, achievement);
          }
        });
  }

  @override
  void dispose() {
    _achievementSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await LocalStorageService.loadUserData();
    setState(() {
      _userData = data;
    });
    CurrencyService().init(_userData); // 초기화
  }

  void _startGame(int stage) {
    setState(() {
      _isGameStarted = true;
      _isDailyChallenge = false;
      _currentIndex = 0; // 게임 탭으로 전환
    });
  }

  void _startDailyChallenge() {
    setState(() {
      _isGameStarted = true;
      _isDailyChallenge = true;
      _currentIndex = 0; // 게임 탭으로 전환
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      _isGameStarted
          ? SudokuScreen(
              isGameStarted: true,
              isDailyChallenge: _isDailyChallenge,
            )
          : WorldMapScreen(
              userData: _userData,
              onStageSelect: _startGame,
              onDailyChallenge: _startDailyChallenge,
            ),
      InventoryScreen(userData: _userData, onUpdate: () => setState(() {})),
      WikiScreen(userData: _userData),
      AchievementScreen(userData: _userData), // 기존 리더보드 대신 업적 화면
      const DevLogView(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ListenableBuilder(
          listenable: CurrencyService(),
          builder: (context, child) {
            return AppBar(
              backgroundColor: const Color(0xFF1E293B),
              elevation: 4,
              title: Row(
                children: [
                  _buildTopStat(
                    Icons.stars,
                    "Lv.${CurrencyService().level}",
                    Colors.amber,
                  ),
                  const SizedBox(width: 16),
                  _buildTopStat(
                    Icons.monetization_on,
                    "${CurrencyService().gold} G",
                    Colors.amberAccent,
                  ),
                  const SizedBox(width: 16),
                  _buildTopStat(
                    Icons.diamond,
                    "${CurrencyService().gems}",
                    Colors.cyanAccent,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: _currentIndex, children: views),
          ),
          const SizedBox(height: 70), // Ad Space reserve
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // 탭 전환 시 중복 로딩 제거 (CurrencyService를 통해 최신 전역 상태 유지)
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.blueGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "World"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: '가방'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '도감'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '업적'),
          BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: '개발기'),
        ],
      ),
    );
  }

  Widget _buildTopStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
