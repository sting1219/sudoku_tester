import 'dart:async';
import '../models/user_data.dart';
import 'firebase_service.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final FirebaseService _firebase = FirebaseService();
  bool _isSyncing = false;

  /// 앱 시작 시 호출하여 로컬과 서버 데이터를 동기화합니다.
  Future<UserData> syncOnStartup(UserData localData) async {
    try {
      await _firebase.signInAnonymously();
      final remoteData = await _firebase.downloadUserData();

      if (remoteData == null) {
        // 서버에 데이터가 없으면 로컬 데이터를 업로드
        await _firebase.uploadUserData(localData);
        return localData;
      }

      // 타임스탬프 비교하여 최신 데이터 선택
      if (remoteData.lastUpdated > localData.lastUpdated) {
        // 서버 데이터가 더 최신인 경우 로컬에 저장
        await LocalStorageService.saveUserData(remoteData);
        return remoteData;
      } else if (localData.lastUpdated > remoteData.lastUpdated) {
        // 로컬 데이터가 더 최신인 경우 서버에 업로드
        await _firebase.uploadUserData(localData);
      }
    } catch (e) {
      print("Sync error: $e");
    }
    return localData;
  }

  /// 데이터 저장 시 호출하여 백그라운드에서 서버와 동기화합니다.
  void syncOnSave(UserData userData) {
    if (_isSyncing) return;
    _isSyncing = true;
    
    // 비동기로 서버 업로드 수행 (UI 블로킹 방지)
    _firebase.uploadUserData(userData).then((_) {
      _isSyncing = false;
    }).catchError((e) {
      _isSyncing = false;
      print("Background sync error: $e");
    });
  }
}
