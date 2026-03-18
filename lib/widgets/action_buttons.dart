import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onMemoToggle;
  final VoidCallback? onHint;
  final bool isMemoOn;
  final int hintCount;

  const ActionButtons({
    super.key,
    this.onDelete,
    this.onMemoToggle,
    required this.isMemoOn,
    required this.hintCount,
    this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.auto_fix_normal, "지우기", onDelete),
          _buildActionButton(
            isMemoOn ? Icons.edit : Icons.edit_off,
            "메모",
            onMemoToggle,
            statusText: isMemoOn ? "ON" : "OFF",
          ),
          _buildActionButton(
            Icons.lightbulb_outline,
            "힌트",
            onHint,
            badgeCount: hintCount,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback? onTap, {
    String? statusText,
    int? badgeCount,
  }) {
    final bool isEnabled = onTap != null;
    final Color mainColor = isEnabled
        ? AppColors.indigoAccent
        : Colors.grey[600]!;

    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 28, color: mainColor),
                if (statusText != null)
                  Positioned(
                    top: -5,
                    right: -15,
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isEnabled && statusText == "ON"
                            ? AppColors.accentColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                if (badgeCount != null)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: isEnabled ? Colors.blue : Colors.grey,
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppStyles.bodyLarge.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isEnabled ? AppColors.textBody : Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
