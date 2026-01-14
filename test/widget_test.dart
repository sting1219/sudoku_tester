// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// main.dart에서 정의한 SudokuApp을 임포트합니다.
import 'package:sudoku_game/main.dart'; 

void main() {
  // 테스트 이름을 'Sudoku App Smoke Test'로 변경합니다.
  testWidgets('Sudoku App Smoke Test', (WidgetTester tester) async {
    
    // 1. 앱을 빌드하고 프레임을 그립니다.
    // MyApp 대신 우리가 정의한 SudokuApp을 사용합니다.
    await tester.pumpWidget(const SudokuApp());

    // 2. 화면에 스도쿠 앱의 주요 요소들이 정상적으로 로드되었는지 확인합니다.
    
    // AppBar의 제목이 '스도쿠 게임'인지 확인
    expect(find.text('스도쿠 게임'), findsOneWidget); 

    // 스도쿠 보드가 9x9 그리드이므로, 총 81개의 셀이 있어야 합니다.
    // 여기서는 가장 간단하게 빈 셀(0)을 나타내는 빈 텍스트('')가 있는지 확인해봅니다.
    // (완전한 테스트는 아니지만, 앱이 깨지지 않고 실행되었는지 확인하는 Smoke Test로는 충분합니다.)
    expect(find.byType(Container), findsWidgets); 
    
    // 3. 키패드에서 1을 입력하는 버튼(텍스트 '1')이 있는지 확인합니다.
    expect(find.text('1'), findsWidgets); 

    // 4. 앱이 성공적으로 로드된 후 에러가 발생하지 않았는지 확인합니다.
    // (추가적인 상호작용 테스트는 나중에 필요에 따라 구현할 수 있습니다.)
  });
}