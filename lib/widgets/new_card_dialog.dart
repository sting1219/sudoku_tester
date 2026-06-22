import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/monster_data.dart';

class NewCardDialog extends StatefulWidget {
  final MonsterEntry monster;

  const NewCardDialog({super.key, required this.monster});

  static void show(BuildContext context, MonsterEntry monster) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NewCardDialog(monster: monster),
    );
  }

  @override
  State<NewCardDialog> createState() => _NewCardDialogState();
}

class _NewCardDialogState extends State<NewCardDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.5 && !_isFlipped) {
        setState(() {
          _isFlipped = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating || _isFlipped) return;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: _flipCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle);

            // 0.5 (pi/2) 지점을 넘어가면 위젯 뒷면(원래 카드의 앞면)을 보여주기 위해 Y축을 다시 180도 뒤집어줍니다.
            if (_isFlipped) {
              transform.rotateY(pi);
            }

            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: _isFlipped ? _buildFront(context) : _buildBack(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amberAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amberAccent.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline, color: Colors.amberAccent, size: 80),
            const SizedBox(height: 20),
            Text(
              "NEW CARD",
              style: GoogleFonts.cinzel(
                color: Colors.amberAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "탭하여 확인하세요",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 5,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "카드 획득!",
              style: GoogleFonts.cinzel(
                color: Colors.cyanAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.adb, color: Colors.cyanAccent, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              widget.monster.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "속성: ${widget.monster.element}",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
                foregroundColor: Colors.cyanAccent,
                side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.5)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("도감에 보관하기"),
            ),
          ],
        ),
      ),
    );
  }
}
