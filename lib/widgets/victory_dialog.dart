import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/currency_service.dart';

class VictoryDialog extends StatefulWidget {
  final int earnedGold;
  final int earnedXp;
  final VoidCallback onConfirm;

  const VictoryDialog({
    super.key,
    required this.earnedGold,
    required this.earnedXp,
    required this.onConfirm,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _goldAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _goldAnimation = IntTween(begin: 0, end: widget.earnedGold).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "VICTORY",
                style: GoogleFonts.cinzel(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 4,
                  shadows: [
                    const Shadow(
                      color: Colors.orange,
                      blurRadius: 15,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 2,
                width: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.amber.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildRewardItem(
                icon: Icons.monetization_on,
                color: Colors.amberAccent,
                label: "GOLD EARNED",
                animation: _goldAnimation,
                suffix: " G",
              ),
              const SizedBox(height: 20),
              _buildRewardItemStatic(
                icon: Icons.auto_awesome,
                color: Colors.cyanAccent,
                label: "XP GAINED",
                value: widget.earnedXp,
                suffix: " XP",
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                  ),
                  onPressed: () {
                    // 확인 버튼 클릭 시 데이터 최종 저장 및 동기화
                    CurrencyService().saveCurrentData();
                    widget.onConfirm();
                  },
                  child: Text(
                    "CONFIRM",
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required Color color,
    required String label,
    required Animation<int> animation,
    required String suffix,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cinzel(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 10),
                Text(
                  "${animation.value}$suffix",
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRewardItemStatic({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
    required String suffix,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cinzel(
            color: Colors.white70,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Text(
              "$value$suffix",
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
