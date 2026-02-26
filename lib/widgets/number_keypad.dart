import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';
import '../utils/app_styles.dart';

class NumberKeypad extends StatelessWidget {
  // ⭐️ void Function(int) 뒤에 ?를 붙여 null을 허용합니다.
  final void Function(int)? onNumberTap;
  final VoidCallback? onDeleteTap;
  final SudokuBoard board;

  const NumberKeypad({
    super.key,
    this.onNumberTap, // ⭐️ required 제거
    this.onDeleteTap, // ⭐️ required 제거
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => _buildNumberButton(index + 1)),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(4, (index) => _buildNumberButton(index + 6)),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    // ⭐️ 핵심 로직: 숫자가 9개 이상이면 비활성화
    final int count = board.getCountOfNumber(number);
    final bool isCompleted = count >= 9;

    // 이미 9개 채워졌거나, 외부에서 비활성화(null)가 들어왔다면 작동 안함
    final bool isActuallyEnabled = onNumberTap != null && !isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: isActuallyEnabled ? () => onNumberTap!(number) : null,
        child: Opacity(
          opacity: isActuallyEnabled ? 1.0 : 0.3, // 완료된 숫자는 더 흐리게 표시
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.scaffoldBackground
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActuallyEnabled
                    ? AppColors.indigoAccent.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    number.toString(),
                    style: AppStyles.bodyLarge.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActuallyEnabled ? Colors.white : Colors.white38,
                    ),
                  ),
                  // 선택사항: 숫자 아래에 작게 남은 개수를 표시해줄 수도 있습니다.
                  Text(
                    "${9 - count}",
                    style: TextStyle(
                      fontSize: 8,
                      color: isActuallyEnabled
                          ? AppColors.accentColor
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    final bool isEnabled = onDeleteTap != null; // ⭐️ 활성화 체크

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onDeleteTap,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.3,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.dangerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEnabled ? AppColors.dangerColor : Colors.transparent,
              ),
            ),
            child: Icon(
              Icons.backspace_outlined,
              color: isEnabled ? AppColors.dangerColor : Colors.white24,
            ),
          ),
        ),
      ),
    );
  }
}
