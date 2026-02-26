import 'dart:math';
import 'package:flutter/material.dart';

class FireflyBackground extends StatefulWidget {
  final Widget child;
  const FireflyBackground({super.key, required this.child});

  @override
  State<FireflyBackground> createState() => _FireflyBackgroundState();
}

class _FireflyBackgroundState extends State<FireflyBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Firefly> _fireflies = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < 25; i++) {
      _fireflies.add(
        _Firefly(
          position: Offset(_random.nextDouble(), _random.nextDouble()),
          size: 1.0 + _random.nextDouble() * 2.0,
          speed: 0.02 + _random.nextDouble() * 0.03,
          angle: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _FireflyPainter(_fireflies, _controller.value),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Firefly {
  Offset position;
  final double size;
  final double speed;
  double angle;

  _Firefly({
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

class _FireflyPainter extends CustomPainter {
  final List<_Firefly> fireflies;
  final double animationValue;

  _FireflyPainter(this.fireflies, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (var firefly in fireflies) {
      // 시간의 흐름에 따라 미세하게 이동 (Swaying 효과)
      double dx =
          firefly.position.dx * size.width +
          sin(animationValue * 2 * pi + firefly.angle) * 15;
      double dy =
          firefly.position.dy * size.height +
          cos(animationValue * 2 * pi + firefly.angle) * 15;

      // 화면 밖으로 나가지 않도록 조정 (미세하게 처리)
      canvas.drawCircle(Offset(dx, dy), firefly.size, paint);

      // 더 밝은 중심점
      final centerPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.6);
      canvas.drawCircle(Offset(dx, dy), firefly.size * 0.5, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
