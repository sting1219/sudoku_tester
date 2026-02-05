import 'package:flutter/material.dart';

class FloatingDamage extends StatefulWidget {
  final Offset position;
  final int damage;
  final VoidCallback onComplete;

  const FloatingDamage({
    super.key,
    required this.position,
    required this.damage,
    required this.onComplete,
  });

  @override
  State<FloatingDamage> createState() => _FloatingDamageState();
}

class _FloatingDamageState extends State<FloatingDamage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _upwardAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeIn)),
    );

    _upwardAnimation = Tween<double>(begin: 0.0, end: -80.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 20,
      top: widget.position.dy + _upwardAnimation.value,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Text(
          '-${widget.damage}',
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 28,
            fontWeight: FontWeight.black,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
            ],
          ),
        ),
      ),
    );
  }
}
