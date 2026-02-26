import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class DungeonClearOverlay extends StatelessWidget {
  final VoidCallback onLeave;

  const DungeonClearOverlay({super.key, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 100),
              const SizedBox(height: 30),
              Text(
                "DUNGEON CLEAR",
                style: AppStyles.headlineMedium.copyWith(
                  fontSize: 50,
                  letterSpacing: 4,
                  shadows: [
                    const Shadow(
                      color: Colors.amber,
                      blurRadius: 20,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "모든 어둠이 정화되었습니다.",
                style: AppStyles.bodyLarge.copyWith(color: Colors.blueGrey),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: onLeave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "전장 떠나기",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
