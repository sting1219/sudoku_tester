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

class _MonsterStatusState extends State<MonsterStatus> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  int _lastKnownHp = 0; // To track HP changes

  @override
  void initState() {
    super.initState();
    _lastKnownHp = widget.monster.currentHp;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _colorAnimation = ColorTween(
      begin: Colors.red.withAlpha((255 * 0.0).round()), // Start transparent
      end: Colors.red.withAlpha((255 * 0.5).round()),   // Briefly flash red
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {}); // Rebuild to apply color change
      });
  }

  @override
  void didUpdateWidget(covariant MonsterStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.monster.currentHp < _lastKnownHp) {
      // Monster took damage, trigger hit animation
      _controller.forward(from: 0.0); // Start animation from beginning
    }
    _lastKnownHp = widget.monster.currentHp; // Update last known HP
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 몬스터의 이름이 없거나 최대 체력이 0이면(전투 없는 방) 아무것도 표시하지 않음
    if (widget.monster.name.isEmpty || widget.monster.maxHp <= 0) {
      return const SizedBox(height: 140); // 다른 위젯과의 높이를 맞추기 위한 빈 공간
    }

    double hpPercentage = 0.0;
    if (widget.monster.maxHp > 0) {
      hpPercentage = widget.monster.currentHp / widget.monster.maxHp;
    }
    if (hpPercentage < 0) hpPercentage = 0;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration( 
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            widget.monster.name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 80,
            height: 80,
            color: Colors.blueGrey[100],
            foregroundDecoration: BoxDecoration(
              color: _colorAnimation.value,
            ),
            child: const Center(
              child: Icon(Icons.psychology_alt, color: Colors.black, size: 50),
            ),
          ),
          const SizedBox(height: 5),
          LayoutBuilder(
            builder: (context, constraints) {
              final double barWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: barWidth,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: barWidth * hpPercentage,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Text(
                    '${widget.monster.currentHp}/${widget.monster.maxHp}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 1.0)],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}