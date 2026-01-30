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
    double hpPercentage = widget.monster.currentHp / widget.monster.maxHp;
    if (hpPercentage < 0) hpPercentage = 0; // Ensure it doesn't go below 0

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration( // Added back decoration for white background
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            widget.monster.name,
            style: const TextStyle(
              color: Colors.black, // Changed to black
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // Monster Image
          Container(
            width: 80,
            height: 80,
            color: Colors.blueGrey[100], // Changed to a lighter color
            foregroundDecoration: BoxDecoration(
              color: _colorAnimation.value, // Apply animation color overlay
            ),
            child: const Center(
              child: Icon(Icons.psychology_alt, color: Colors.black, size: 50), // Changed to black
            ),
          ),
          const SizedBox(height: 5),
          // HP Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final double barWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.center, // Center the text within the stack
                children: [
                  // Background (empty part of the bar)
                  Container(
                    width: barWidth,
                    height: 12, // Slightly thicker
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Foreground (filled part of the bar)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: barWidth * hpPercentage,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // HP Text
                  Text(
                    '${widget.monster.currentHp}/${widget.monster.maxHp}',
                    style: const TextStyle(
                      color: Colors.black, // Changed to black
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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