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
      begin: Colors.red.withOpacity(0.0), // Start transparent
      end: Colors.red.withOpacity(0.5),   // Briefly flash red
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
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            widget.monster.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // Monster Image
          Container(
            width: 80,
            height: 80,
            color: Colors.green[700], // Base color
            foregroundDecoration: BoxDecoration(
              color: _colorAnimation.value, // Apply animation color overlay
            ),
            child: const Center(
              child: Icon(Icons.psychology_alt, color: Colors.white, size: 50), // Placeholder icon
            ),
          ),
          const SizedBox(height: 5),
          // HP Bar
          Stack(
            children: [
              Container(
                width: 100,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: hpPercentage,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'HP: ${widget.monster.currentHp}/${widget.monster.maxHp}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}