import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'views/home_view.dart';
import 'views/guide_view.dart';
import 'views/wiki_view.dart';
import 'views/dev_log_view.dart';

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

  void _startGame() {
    setState(() {
      _isGameStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> views = [
      HomeView(isStarted: _isGameStarted, onStart: _startGame),
      const SudokuGuideView(),
      const RPGWikiView(),
      const DevLogView(),
    ];

    return Scaffold(
      body: views[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: "Game",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: "Guide",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: "Wiki",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: "Logs"),
        ],
      ),
    );
  }
}
