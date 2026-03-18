import 'dart:math';
import 'package:sudoku_game/services/currency_service.dart';
import '../data/artifact_data.dart';

class CollectionService {
  static final CollectionService _instance = CollectionService._internal();
  factory CollectionService() => _instance;
  CollectionService._internal();

  final Random _random = Random();

  /// 1. 금지된 숫자의 서 해금 로직 (정답 입력 시 호출)
  /// 특정 숫자로 타격/정답 시 카운트를 올리고 20회 달성 시 해금
  void recordNumberUsage(int number, {void Function(String)? onUnlock}) {
    if (number < 1 || number > 9) return;

    final userData = CurrencyService().userData;

    // 이미 해금된 경우 패스
    if (userData.stats.unlockedForbiddenBooks[number] == true) return;

    // 카운트 증분
    int currentCount = userData.stats.killCountsByNumber[number] ?? 0;
    currentCount++;
    userData.stats.killCountsByNumber[number] = currentCount;

    // 20번이면 해금 (테스트를 위해 허들 낮춤)
    if (currentCount == 20) {
      userData.stats.unlockedForbiddenBooks[number] = true;
      if (onUnlock != null) {
        onUnlock("📖 「금지된 숫자의 서」 $number번째 페이지가 해금되었습니다!");
      }
    }

    // [NEW] 조각난 일지 극악 드롭 (0.5% 확률)
    if (_random.nextDouble() <= 0.005) {
      List<LostJournal> availableJournals = CollectionTemplates.lostJournals
          .where((j) => !userData.stats.unlockedLostJournals.contains(j.id))
          .toList();

      if (availableJournals.isNotEmpty) {
        LostJournal journal =
            availableJournals[_random.nextInt(availableJournals.length)];
        userData.stats.unlockedLostJournals.add(journal.id);
        if (onUnlock != null) {
          onUnlock("📜 바닥에 떨어져 있던 [${journal.title}]을(를) 주웠습니다!");
        }
      }
    }

    // 글로벌 세이브
    CurrencyService().saveCurrentData();
  }

  /// 2. 차원의 낱장 조각 드롭 (몬스터 처치 시 호출, 5% 확률)
  void tryDropIllustrationPiece({void Function(String)? onUnlock}) {
    final userData = CurrencyService().userData;

    // 이미 9조각 모두 모았으면 종료
    if (userData.stats.collectedIllustrationPieces.length >= 9) return;

    // 5% 확률 (체감 향상을 위해 5% -> 0.05)
    if (_random.nextDouble() <= 0.05) {
      List<int> available = [];
      for (int i = 1; i <= 9; i++) {
        if (!userData.stats.collectedIllustrationPieces.contains(i)) {
          available.add(i);
        }
      }

      if (available.isNotEmpty) {
        int piece = available[_random.nextInt(available.length)];
        userData.stats.collectedIllustrationPieces.add(piece);
        CurrencyService().saveCurrentData();

        if (onUnlock != null) {
          if (userData.stats.collectedIllustrationPieces.length == 9) {
            onUnlock("🌌 마지막 「차원의 낱장」을 획득했습니다! 감춰진 진실이 개방됩니다.");
          } else {
            onUnlock("🌌 「차원의 낱장」 조각 $piece번을 획득했습니다!");
          }
        }
      }
    }
  }

  /// 3. 정화가의 박물관 방 클리어 시 골동품 획득 (10% 확률)
  void tryDropArtifact({void Function(String, Artifact)? onUnlock}) {
    final userData = CurrencyService().userData;

    // 10% 확률로 획득
    if (_random.nextDouble() <= 0.10) {
      List<Artifact> available = CollectionTemplates.artifacts
          .where((a) => !userData.stats.unlockedArtifacts.contains(a.id))
          .toList();

      if (available.isNotEmpty) {
        Artifact artifact = available[_random.nextInt(available.length)];
        userData.stats.unlockedArtifacts.add(artifact.id);
        CurrencyService().saveCurrentData();

        if (onUnlock != null) {
          onUnlock("🏺 잃어버린 유물 [${artifact.name}]을(를) 발견했습니다!", artifact);
        }
      }
    }
  }

  /// 4. 몬스터 처치 기록 (도감 해금용)
  void recordMonsterKill(String monsterName) {
    final userData = CurrencyService().userData;
    int killCount = userData.stats.monsterKillCounts[monsterName] ?? 0;

    // 처치 횟수 증가
    userData.stats.monsterKillCounts[monsterName] = killCount + 1;

    // 도감 발견 기록에도 자동 추가
    userData.stats.discoveredMonsterNames.add(monsterName);

    CurrencyService().saveCurrentData();
  }
}
