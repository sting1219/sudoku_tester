import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DamagePopupData {
  final int damage;
  final Offset position;
  final int combo;
  final DateTime timestamp;
  final Key key;

  DamagePopupData({
    required this.damage,
    required this.position,
    required this.combo,
    required this.timestamp,
    required this.key,
  });
}

class DamagePopup extends StatefulWidget {
  final DamagePopupData data;
  final VoidCallback onComplete;

  const DamagePopup({
    required this.data,
    required this.onComplete,
    super.key,
  });

  @override
  State<DamagePopup> createState() => _DamagePopupState();
}

class _DamagePopupState extends State<DamagePopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _offset = Tween<Offset>(
      begin: widget.data.position,
      end: widget.data.position + const Offset(0, -100),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor;
    double baseFontSize;

    if (widget.data.combo >= 10) {
      textColor = Colors.redAccent;
      baseFontSize = 32;
    } else if (widget.data.combo >= 5) {
      textColor = Colors.orangeAccent;
      baseFontSize = 26;
    } else {
      textColor = Colors.yellowAccent;
      baseFontSize = 20;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _offset.value.dx - 50, // Center roughly
          top: _offset.value.dy - 25,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    "-${widget.data.damage}",
                    style: GoogleFonts.cinzel(
                      fontSize: baseFontSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      shadows: [
                        const Shadow(
                          blurRadius: 4.0,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
