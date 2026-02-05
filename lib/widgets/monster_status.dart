import 'package:flutter/material.dart';
import '../models/combat_data.dart';

class MonsterStatus extends StatefulWidget {
  final Monster monster;

  const MonsterStatus({
    super.key,
    required this.monster,
  });

  @override
  State<MonsterStatus> createState() => _MonsterStatusState();
}

class _MonsterStatusState extends State<MonsterStatus> with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _shakeController;
  late AnimationController _shudderController;
  
  late Animation<Color?> _colorAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _shudderAnimation;

  int _lastKnownHp = 0;

  @override
  void initState() {
    super.initState();
    _lastKnownHp = widget.monster.currentHp;

    // 1. 레드 플래시 컨트롤러
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.withOpacity(0.5),
    ).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeInOut));

    // 2. 몬스터 셰이크 컨트롤러 (0.2초)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));

    // 3. HP 바 진동(Shudder) 컨트롤러
    _shudderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shudderAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: -2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shudderController, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(covariant MonsterStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.monster.currentHp < _lastKnownHp) {
      // 데미지 입었을 때 모든 애니메이션 동시 실행
      _flashController.forward(from: 0.0).then((_) => _flashController.reverse());
      _shakeController.forward(from: 0.0);
      _shudderController.forward(from: 0.0);
    }
    _lastKnownHp = widget.monster.currentHp;
  }

  @override
  void dispose() {
    _flashController.dispose();
    _shakeController.dispose();
    _shudderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.monster.name.isEmpty || widget.monster.maxHp <= 0) {
      return const SizedBox(height: 80);
    }

    double hpPercentage = (widget.monster.maxHp > 0) 
        ? (widget.monster.currentHp / widget.monster.maxHp).clamp(0.0, 1.0) 
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration( 
        color: const Color(0xFF1E293B).withOpacity(0.9), // 메인 배경과 통일감 있는 다크 컬러
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.monster.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          
          // 몬스터 이미지 및 셰이크/플래시 효과
          AnimatedBuilder(
            animation: Listenable.merge([_shakeController, _flashController]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.indigoAccent.withOpacity(0.3), width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.psychology_alt, color: Colors.white70, size: 45),
                      // 레드 플래시 오버레이
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _colorAnimation.value,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // HP 바 및 진동 효과
          AnimatedBuilder(
            animation: _shudderController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _shudderAnimation.value),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double barWidth = constraints.maxWidth;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: barWidth,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.red[900]?.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: barWidth * hpPercentage,
                                height: 14,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green[700]!, Colors.green[400]!],
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: [
                                    BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 4)
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              '${widget.monster.currentHp} / ${widget.monster.maxHp}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.black,
                                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}