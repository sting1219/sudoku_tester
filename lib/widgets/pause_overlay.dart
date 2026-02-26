import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const PauseOverlay({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow,
                size: 80,
                color: AppColors.accentColor,
              ),
              const SizedBox(height: 16),
              Text("일시정지됨", style: AppStyles.headlineMedium),
              const SizedBox(height: 8),
              Text("화면을 터치하여 재개", style: AppStyles.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
