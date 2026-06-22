import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'views/lobby_screen.dart';
import 'services/currency_service.dart';
import 'models/user_data.dart';
import 'services/achievement_service.dart';
import 'widgets/achievement_toast.dart';
import 'services/localization_service.dart';
import 'services/stage_manager.dart';
import 'services/sync_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase init error: $e");
  }

  L10n.init();

  // 앱 시작 시 데이터 동기화
  final UserData localData = await LocalStorageService.loadUserData();
  final UserData syncedData = await SyncManager().syncOnStartup(localData);

  // Android
  // If your Flutter app is targeting Android 16 (API 36) or later and you are using a device with a display width >= 600 dp, then you cannot set the device orientation via [SystemChrome.setPreferredOrientations]. For more details see Android 16 docs here.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(SudokuApp(initialUserData: syncedData));
}

class SudokuApp extends StatelessWidget {
  final UserData initialUserData;
  const SudokuApp({super.key, required this.initialUserData});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CurrencyService()..init(initialUserData),
        ),
        ChangeNotifierProvider(
          create: (_) => AchievementService()..init(initialUserData),
        ),
        ChangeNotifierProvider(
          create: (_) => StageManager()..init(initialUserData),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
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
    CurrencyService().init(_userData);
  }

  @override
  Widget build(BuildContext context) {
    return LobbyScreen(userData: _userData);
  }
}
