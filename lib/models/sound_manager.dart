import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class SoundManager {
  static final SoundManager instance = SoundManager._internal();
  SoundManager._internal();

  final AudioPlayer _player = AudioPlayer();

  // 콤보에 따른 음계 피치 비율 (도, 레, 미, 파, 솔, 라, 시, 높은 도)
  final List<double> _pitches = [
    1.0, // 도
    1.122, // 레
    1.260, // 미
    1.335, // 파
    1.498, // 솔
    1.682, // 라
    1.888, // 시
    2.0, // 높은 도
  ];

  Future<void> playComboSound(int combo) async {
    // 콤보가 1부터 시작한다고 가정 (0이면 무시)
    if (combo <= 0) return;

    int index = (combo - 1) % _pitches.length;
    double pitch = _pitches[index];

    // 8콤보 이상일 경우 (옥타브 순환 혹은 추가 효과)
    if (combo >= 8) {
      // 8콤보 이상일 때는 항상 가장 높은 피치나 특별한 연출 가능
      pitch = 2.0;
    }

    await playAnswerSound(pitch);
  }

  Future<void> playWrongSound() async {
    try {
      await _player.setPlaybackRate(1.0);
      await _player.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      print("Sound play error: $e");
    }
  }

  void dispose() {
    _player.dispose();
  }

  Future<void> playAnswerSound(double pitch) async {
    try {
      // 1. 매번 새로운 플레이어 생성 (독립적 재생)
      final temporaryPlayer = AudioPlayer();

      // int randomNumber = Random().nextInt(5) + 1;
      // String fileName = 'sounds/hit_wall_$randomNumber.wav';
      // 2. 소스 설정 및 피치 조절
      await temporaryPlayer.setSource(AssetSource('sounds/answer.mp3'));
      await temporaryPlayer.setPlaybackRate(1.0); // 일단 정상 재생으로.

      // 3. 재생
      await temporaryPlayer.resume();

      // 4. (선택 사항) 재생이 끝나면 메모리 해제
      temporaryPlayer.onPlayerComplete.listen((_) {
        temporaryPlayer.dispose();
      });
    } catch (e) {
      print("Sound play error: $e");
    }
  }

  Future<void> playHitSound() async {
    try {
      // 1. 매번 새로운 플레이어 생성 (독립적 재생)
      final temporaryPlayer = AudioPlayer();

      int randomNumber = Random().nextInt(5) + 1;
      String fileName = 'sounds/hit_wall_$randomNumber.wav';
      // 2. 소스 설정 및 피치 조절
      await temporaryPlayer.setSource(AssetSource(fileName));
      await temporaryPlayer.setPlaybackRate(1.0); // 일단 정상 재생으로.

      // 3. 재생
      await temporaryPlayer.resume();

      // 4. (선택 사항) 재생이 끝나면 메모리 해제
      temporaryPlayer.onPlayerComplete.listen((_) {
        temporaryPlayer.dispose();
      });
    } catch (e) {
      print("Sound play error: $e");
    }
  }

  Future<void> playVictorySound() async {
    try {
      await _player.setPlaybackRate(1.0);
      await _player.play(AssetSource('sounds/victory.mp3'));
    } catch (e) {
      print("Sound play error: $e");
    }
  }
}
