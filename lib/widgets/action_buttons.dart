import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onDelete;
  final VoidCallback? onMemoToggle;
  final VoidCallback? onHint;
  final bool isMemoOn;
  final int hintCount;
  final int undoCount; // 실행 취소 횟수
  final int maxUndoCount; // 최대 실행 취소 횟수

  const ActionButtons({
    super.key,
    this.onUndo,
    this.onDelete,
    this.onMemoToggle,
    required this.isMemoOn,
    required this.hintCount,
    this.onHint,
    required this.undoCount,
    required this.maxUndoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.undo, "실행 취소 ($undoCount/$maxUndoCount)", onUndo),
          _buildActionButton(Icons.auto_fix_normal, "지우기", onDelete),
          _buildActionButton(
            isMemoOn ? Icons.edit : Icons.edit_off, 
            "메모", 
            onMemoToggle,
            statusText: isMemoOn ? "ON" : "OFF"
          ),
          _buildActionButton(Icons.lightbulb_outline, "힌트", onHint, badgeCount: hintCount),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback? onTap, {String? statusText, int? badgeCount}) {
    final bool isEnabled = onTap != null;
    final Color mainColor = isEnabled ? Colors.blueGrey[700]! : Colors.grey[300]!;

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
                        color: isEnabled && statusText == "ON" ? Colors.blue : Colors.grey,
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
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label, 
              style: TextStyle(
                fontSize: 12, 
                color: isEnabled ? Colors.black : Colors.grey
              )
            ),
          ],
        ),
      ),
    );
  }
}