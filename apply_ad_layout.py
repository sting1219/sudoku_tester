import os
import re

filepath = r'c:\Users\PCUSER\Desktop\Sudoku\sudoku_game\lib\views\sudoku_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Wrap the return value of _buildSudokuBoardWidget in a Column + Expanded + CombatLog
old_board_start = '''  Widget _buildSudokuBoardWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.zero,
        child: _showMoveButtons
            ? Stack('''
new_board_start = '''  Widget _buildSudokuBoardWidget() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.zero,
              child: _showMoveButtons
                  ? Stack('''
content = content.replace(old_board_start, new_board_start)

# We need to find the end of `_buildSudokuBoardWidget` which is followed by `_buildResponsiveLayout`
old_board_end = '''              ),
      ),
    );
  }

  Widget _buildResponsiveLayout() {'''

new_board_end = '''              ),
            ),
          ),
        ),
        CombatLog(logMessages: _combatLogMessages),
      ],
    );
  }

  Widget _buildResponsiveLayout() {'''
content = content.replace(old_board_end, new_board_end)

# 2. Remove CombatLog from _buildResponsiveLayout (Desktop and Mobile)
content = content.replace('                          CombatLog(logMessages: _combatLogMessages),\n                          const SizedBox(height: 10),\n', '')
content = content.replace('                CombatLog(logMessages: _combatLogMessages),\n                const SizedBox(height: 10),\n', '')

# 3. Increase Board flex to maximize: flex 6 -> 7, flex 4 -> 3
content = content.replace('Expanded(\n                  flex: 6,', 'Expanded(\n                  flex: 75,')
content = content.replace('Expanded(\n                  flex: 4,', 'Expanded(\n                  flex: 25,')

# 4. Scale down Quick Inventory
content = content.replace('                          _buildQuickSlots(),\n', '                          Transform.scale(scale: 0.8, child: _buildQuickSlots()),\n')
content = content.replace('                _buildQuickSlots(),\n', '                Transform.scale(scale: 0.8, child: _buildQuickSlots()),\n')

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated sudoku_screen.dart")
