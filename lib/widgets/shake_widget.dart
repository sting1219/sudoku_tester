import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  final Duration duration;
  final double offset;

  const ShakeWidget({
    super.key,
    required this.child,
    this.shake = false,
    this.duration = const Duration(milliseconds: 500),
    this.offset = 8.0,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.shake) {
      _startShake();
    }
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _startShake();
    }
  }

  void _startShake() {
    _controller.forward(from: 0.0);
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
        final double progress = _controller.value;

        // 간단한 쉐이크 로직 (4번 왕복)
        double shakeX = 0;
        if (progress > 0 && progress < 1.0) {
          double count = 4;
          shakeX =
              math.sin(progress * count * 2 * math.pi) *
              widget.offset *
              (1.0 - progress);
        }

        return Transform.translate(offset: Offset(shakeX, 0), child: child);
      },
      child: widget.child,
    );
  }
}
