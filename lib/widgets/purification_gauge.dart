import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurificationGauge extends StatelessWidget {
  final double progress;

  const PurificationGauge({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final bool isComplete = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border(
          bottom: BorderSide(
            color: isComplete
                ? Colors.amber.withValues(alpha: 0.3)
                : Colors.white10,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete ? "✨ 던전의 축복 ✨" : "던전 정화도",
                style: GoogleFonts.cinzel(
                  color: isComplete ? Colors.amber : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: isComplete
                      ? [const Shadow(color: Colors.amber, blurRadius: 10)]
                      : [],
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: GoogleFonts.cinzel(
                  color: isComplete ? Colors.amber : Colors.cyanAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.white10,
                ),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  height: 12,
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isComplete
                          ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                          : [const Color(0xFF2D5A4C), const Color(0xFF00E5FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isComplete ? Colors.amber : Colors.cyanAccent)
                            .withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
