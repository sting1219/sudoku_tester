import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'particle_overlay.dart';

class PurificationGauge extends StatefulWidget {
  final double progress;

  const PurificationGauge({super.key, required this.progress});

  @override
  State<PurificationGauge> createState() => _PurificationGaugeState();
}

class _PurificationGaugeState extends State<PurificationGauge> {
  final GlobalKey _gaugeKey = GlobalKey();

  @override
  void didUpdateWidget(covariant PurificationGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 진행도가 유의미하게 상승했을 때 파티클 효과 발생 (예: 1% 이상)
    if (widget.progress > oldWidget.progress + 0.009 && widget.progress < 1.0) {
      _triggerSparkleEffect();
    }
  }

  void _triggerSparkleEffect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderBox? box =
          _gaugeKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final position = box.localToGlobal(
          Offset(box.size.width * widget.progress, box.size.height / 2),
        );
        ParticleOverlay.show(context, position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isComplete = widget.progress >= 1.0;

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
                isComplete ? "✨ 던전의 축복 ✨" : "방 정화도",
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
                "${(widget.progress * 100).toInt()}%",
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
                  key: _gaugeKey,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  height: 12,
                  width: MediaQuery.of(context).size.width * widget.progress,
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
