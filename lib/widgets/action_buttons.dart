import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback? onDelete;     // ✅ null 허용
  final VoidCallback? onMemoToggle; // ✅ null 허용
  final VoidCallback? onHint;       // ✅ null 허용
  final bool isMemoOn;
  final int hintCount;

  const ActionButtons({
    super.key,
    required this.onUndo,
    this.onDelete,     // ✅ required 제거
    this.onMemoToggle, // ✅ required 제거
    required this.isMemoOn,
    required this.hintCount,
    this.onHint,       // ✅ required 제거
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.undo, "실행 취소", onUndo),
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

  // ⭐️ 중요: onTap의 타입을 VoidCallback? 로 변경
  Widget _buildActionButton(IconData icon, String label, VoidCallback? onTap, {String? statusText, int? badgeCount}) {
    // 버튼이 비활성화되었을 때 색상을 흐리게 설정
    final bool isEnabled = onTap != null;
    final Color mainColor = isEnabled ? Colors.blueGrey[700]! : Colors.grey[300]!;

    return InkWell(
      onTap: onTap, // 이제 null이 들어오면 터치가 작동하지 않습니다.
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5, // ⭐️ 비활성화 시 반투명 효과
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