import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProjectileAnimation extends StatefulWidget {
  final Offset startPos;
  final Offset endPos;
  final VoidCallback onHit;

  const ProjectileAnimation({
    super.key,
    required this.startPos,
    required this.endPos,
    required this.onHit,
  });

  @override
  State<ProjectileAnimation> createState() => _ProjectileAnimationState();
}

class _ProjectileAnimationState extends State<ProjectileAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Offset _controlPoint;
  final List<_Particle> _particles = [];
  bool _isHit = false;

  @override
  void initState() {
    super.initState();
    // 베지어 곡선을 위한 제어점 계산 (궤적에 곡선미 부여)
    final midX = (widget.startPos.dx + widget.endPos.dx) / 2;
    final midY = (widget.startPos.dy + widget.endPos.dy) / 2;
    // 무작위성을 주어 매번 다른 궤적 생성
    _controlPoint = Offset(
      midX + (math.Random().nextDouble() - 0.5) * 300,
      midY - 150 - math.Random().nextDouble() * 100,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward();
    _controller.addListener(_updateParticles);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isHit = true);
        Future.delayed(const Duration(milliseconds: 200), widget.onHit);
      }
    });
  }

  void _updateParticles() {
    if (_isHit) return;
    final t = _animation.value;
    final currentPos = _calculateBezierPoint(t);

    // 파티클 생성
    setState(() {
      _particles.add(
        _Particle(
          position: currentPos,
          color: Colors.amberAccent.withValues(alpha: 0.8),
          size: math.Random().nextDouble() * 4 + 2,
          life: 1.0,
        ),
      );

      // 파티클 업데이트 및 수명 다한 것 제거
      for (var p in _particles) {
        p.life -= 0.05;
        p.position += Offset((math.Random().nextDouble() - 0.5) * 2, 1.0);
      }
      _particles.removeWhere((p) => p.life <= 0);
    });
  }

  Offset _calculateBezierPoint(double t) {
    // 2차 베지어 공식: (1-t)^2*P0 + 2(1-t)t*P1 + t^2*P2
    final double u = 1 - t;
    final double tt = t * t;
    final double uu = u * u;

    return widget.startPos * uu +
        _controlPoint * (2 * u * t) +
        widget.endPos * tt;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isHit) {
      // 타격 시 폭발 이펙트 (Burst)
      return _buildBurstEffect();
    }

    final t = _animation.value;
    final pos = _calculateBezierPoint(t);

    // 다음 지점을 미리 계산하여 회전 각도 결정 (진행 방향)
    final nextT = (t + 0.01).clamp(0.0, 1.0);
    final nextPos = _calculateBezierPoint(nextT);
    final angle = math.atan2(nextPos.dy - pos.dy, nextPos.dx - pos.dx);

    return Stack(
      children: [
        // 파티클 레이어
        ..._particles.map(
          (p) => Positioned(
            left: p.position.dx,
            top: p.position.dy,
            child: Opacity(
              opacity: p.life.clamp(0.0, 1.0),
              child: Container(
                width: p.size,
                height: p.size,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.orange, blurRadius: 4)],
                ),
              ),
            ),
          ),
        ),
        // 발사체 본체 (마법 화살)
        Positioned(
          left: pos.dx,
          top: pos.dy,
          child: Transform.translate(
            offset: const Offset(-15, -15),
            child: Transform.rotate(
              angle: angle,
              child: CustomPaint(
                size: const Size(60, 30),
                painter: _ArrowPainter(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBurstEffect() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Positioned(
          left: widget.endPos.dx - (50 * value),
          top: widget.endPos.dy - (50 * value),
          child: Opacity(
            opacity: 1.0 - value,
            child: Container(
              width: 100 * value,
              height: 100 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.yellowAccent,
                    Colors.orangeAccent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  Offset position;
  final Color color;
  final double size;
  double life;

  _Particle({
    required this.position,
    required this.color,
    required this.size,
    required this.life,
  });
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.orange.withValues(alpha: 0.0),
          Colors.amberAccent,
          Colors.white,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    // 혜성 같은 꼬리가 긴 화살 모양
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.8,
      0,
      size.height / 2,
    );
    path.close();

    canvas.drawPath(path, paint);

    // 머리 부분의 강렬한 빛
    final glowPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(size.width, size.height / 2), 4, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
