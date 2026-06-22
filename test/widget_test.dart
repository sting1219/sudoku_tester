// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// main.dart에서 정의한 SudokuApp을 임포트합니다.
import 'package:sudoku_game/main.dart'; 
import 'package:sudoku_game/models/user_data.dart';

void main() {
  testWidgets('Sudoku App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(SudokuApp(initialUserData: UserData.initial()));

    // 2. 화면에 스도쿠 앱의 주요 요소들이 정상적으로 로드되었는지 확인합니다.
    
    // AppBar의 제목이 '월드 맵'인지 확인
    expect(find.text('월드 맵'), findsOneWidget); 

    // '고요한 시작의 숲' 스테이지 탭하여 스도쿠 화면으로 진입
    final stageFinder = find.text('고요한 시작의 숲');
    expect(stageFinder, findsOneWidget);
    await tester.tap(stageFinder);
    await tester.pumpAndSettle();

    // 3. 스도쿠 보드가 화면에 나타났는지 확인 (예: Container)
    expect(find.byType(Container), findsWidgets); 
    
    // 4. 키패드에서 1을 입력하는 버튼(텍스트 '1')이 있는지 확인합니다.
    expect(find.text('1'), findsWidgets); 

    // 4. 앱이 성공적으로 로드된 후 에러가 발생하지 않았는지 확인합니다.
    // (추가적인 상호작용 테스트는 나중에 필요에 따라 구현할 수 있습니다.)
  });
}