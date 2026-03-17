import 'dart:math';
import 'package:flutter/material.dart';

class ParticleOverlay {
  static void show(BuildContext context, Offset position) {
    final OverlayState overlayState = Overlay.of(context);
    final OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => _ParticleEffect(position: position),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 800), () {
      overlayEntry.remove();
    });
  }
}

class _ParticleEffect extends StatefulWidget {
  final Offset position;
  const _ParticleEffect({required this.position});

  @override
  State<_ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<_ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    for (int i = 0; i < 5; i++) {
      _particles.add(
        _Particle(
          angle: _random.nextDouble() * 2 * pi,
          distance: 20.0 + _random.nextDouble() * 30.0,
          size: 4.0 + _random.nextDouble() * 4.0,
          color: Colors.amberAccent.withValues(alpha: 0.8),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RepaintBoundary(
          child: Stack(
            children: _particles.map((p) {
              final double progress = _controller.value;
              final double currentDistance = p.distance * progress;
              final double opacity = (1.0 - progress).clamp(0.0, 1.0);

              return Positioned(
                left:
                    widget.position.dx +
                    cos(p.angle) * currentDistance -
                    p.size / 2,
                top:
                    widget.position.dy +
                    sin(p.angle) * currentDistance -
                    p.size / 2,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });
}
