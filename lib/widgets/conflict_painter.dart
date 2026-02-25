import 'package:flutter/material.dart';

class ConflictPainter extends CustomPainter {
  final List<Map<String, int>> conflicts; // {'row': int, 'col': int}
  final int targetRow;
  final int targetCol;
  final double animationValue;

  ConflictPainter({
    required this.conflicts,
    required this.targetRow,
    required this.targetCol,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (conflicts.isEmpty || animationValue == 0) return;

    final cellWidth = size.width / 9;
    final cellHeight = size.height / 9;

    final paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.6 * (1.0 - animationValue))
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = Colors.redAccent.withOpacity(0.3 * (1.0 - animationValue))
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final Offset startCenter = Offset(
      (targetCol + 0.5) * cellWidth,
      (targetRow + 0.5) * cellHeight,
    );

    for (var conflict in conflicts) {
      final Offset endCenter = Offset(
        (conflict['col']! + 0.5) * cellWidth,
        (conflict['row']! + 0.5) * cellHeight,
      );

      // 레이저 광선 효과 (메인 선 + 글로우)
      canvas.drawLine(startCenter, endCenter, glowPaint);
      canvas.drawLine(startCenter, endCenter, paint);

      // 대상 칸에 작은 원 표시
      canvas.drawCircle(endCenter, 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConflictPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.conflicts != conflicts;
  }
}
