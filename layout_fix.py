import os
import re

filepath = r'c:\Users\PCUSER\Desktop\Sudoku\sudoku_game\lib\views\sudoku_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update _buildStatSelectButton
old_btn = '''  Widget _buildStatSelectButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
      onPressed: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      MonsterStatus(key: _monsterKey, monster: _currentMonster),
                      const SizedBox(height: 10),
                      Expanded(child: _buildSudokuBoardWidget()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          _buildTopControls(),
                          _buildBottomControls(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      MonsterStatus(key: _monsterKey, monster: _currentMonster),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Column(
                          children: [
                            _buildTopControls(),
                            Expanded(child: _buildSudokuBoardWidget()),
                            _buildBottomControls(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }'''

new_btn = '''  Widget _buildStatSelectButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }'''

if old_btn in content:
    content = content.replace(old_btn, new_btn)
else:
    print('Failed to replace _buildStatSelectButton')

# 2. Update _moveToRoom fallback logic
old_move_room = '''  void _moveToRoom(int newX, int newY) {
    setState(() {
      _dungeonMap.move(newX, newY);
      final RoomData targetRoom = _dungeonMap.currentRoom;

      if (targetRoom.isCleared) {
        _addCombatLog("이미 정복한 지역입니다.");
        _showMoveButtons = true;
        _currentMonster = Monster.empty();
        _timer?.cancel();
      } else {
        _secondsElapsed = 0;
        _isPaused = false;
        _isSuccessAnimation = false;
        _showMoveButtons = false;
        _selectedRow = null;
        _selectedCol = null;
        _hintsRemaining = 0;
        _undoUses = 0;
        _history.clear();
        _combatLogMessages.clear();
        _currentMonster = MonsterTemplates.getMonsterForRoom(
          _dungeonMap.currentRoom.type,
        );
        _startTimer();'''

new_move_room = '''  void _moveToRoom(int newX, int newY) {
    setState(() {
      _dungeonMap.move(newX, newY);
      final RoomData targetRoom = _dungeonMap.currentRoom;

      if (targetRoom.isCleared) {
        _addCombatLog("이미 정복한 지역입니다.");
        _showMoveButtons = true;
        _currentMonster = Monster.empty();
        _timer?.cancel();
      } else {
        _secondsElapsed = 0;
        _isPaused = false;
        _isSuccessAnimation = false;
        _showMoveButtons = false;
        _selectedRow = null;
        _selectedCol = null;
        _hintsRemaining = 0;
        _undoUses = 0;
        _history.clear();
        _combatLogMessages.clear();
        var nextMonster = MonsterTemplates.getMonsterForRoom(
          _dungeonMap.currentRoom.type,
        );
        if (nextMonster.name == "없음" || nextMonster.maxHp <= 0) {
          nextMonster = MonsterTemplates.numberSlime();
        }
        _currentMonster = nextMonster;
        _startTimer();'''

if old_move_room in content:
    content = content.replace(old_move_room, new_move_room)
else:
    print('Failed to replace _moveToRoom logic')

# 3. Rewrite _buildResponsiveLayout completely
# Find the start of _buildResponsiveLayout and end just before Widget build(BuildContext context) -> WAIT, _buildQuickSlots and _usePotion are in between.
# Let's extract _buildResponsiveLayout by matching its signature up to _buildQuickSlots

responsive_pattern = re.compile(r'  Widget _buildResponsiveLayout\(\) \{.*?(?=  Widget _buildQuickSlots\(\) \{)', re.DOTALL)
match = responsive_pattern.search(content)

new_responsive = '''  Widget _buildResponsiveLayout() {
    bool isLocked = _isCellLocked();
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent && !_isPaused) {
          if (_showMoveButtons) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
                _moveToRoom(_dungeonMap.currentX, _dungeonMap.currentY - 1);
                break;
              case LogicalKeyboardKey.arrowDown:
                _moveToRoom(_dungeonMap.currentX, _dungeonMap.currentY + 1);
                break;
              case LogicalKeyboardKey.arrowLeft:
                _moveToRoom(_dungeonMap.currentX - 1, _dungeonMap.currentY);
                break;
              case LogicalKeyboardKey.arrowRight:
                _moveToRoom(_dungeonMap.currentX + 1, _dungeonMap.currentY);
                break;
            }
          }
          final label = event.logicalKey.keyLabel;
          if (RegExp(r'^[1-9]$').hasMatch(label)) {
            _handleNumberInput(int.parse(label));
          } else if (label == 'f' || label == 'F') {
            _fillOneEmptyCellWithAnswer();
          } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
              event.logicalKey == LogicalKeyboardKey.delete) {
            _handleNumberInput(0);
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            // == Desktop / Tablet Layout ==
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Panel: Monster + Sudoku Board Maxamized
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      MonsterStatus(key: _monsterKey, monster: _currentMonster),
                      const SizedBox(height: 10),
                      Expanded(child: _buildSudokuBoardWidget()),
                    ],
                  ),
                ),
                // Right Panel: Stats, Logs, Keypad, Quick Slots
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          _buildTopControls(),
                          ActionButtons(
                            onUndo: (_history.isEmpty || _undoUses >= _maxUndoUses) ? null : () {
                              _undoUses++;
                              _handleUndo();
                            },
                            onDelete: (isLocked || _isPaused) ? null : () => _handleNumberInput(0),
                            onMemoToggle: isLocked ? null : () => setState(() => _isMemoMode = !_isMemoMode),
                            isMemoOn: _isMemoMode,
                            hintCount: _hintsRemaining,
                            onHint: (isLocked || _hintsRemaining <= 0 || _isPaused || _selectedRow == null) ? null : _handleHint,
                            undoCount: _undoUses,
                            maxUndoCount: _maxUndoUses,
                          ),
                          NumberKeypad(
                            board: _getCurrentSudokuBoard(),
                            onNumberTap: (_isPaused || isLocked) ? null : (n) => _handleNumberInput(n),
                          ),
                          CombatLog(logMessages: _combatLogMessages),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                              style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                            ),
                          ),
                          _buildQuickSlots(),
                          const AdSenseWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // == Mobile Layout ==
            return Column(
              children: [
                _buildTopControls(),
                MonsterStatus(key: _monsterKey, monster: _currentMonster),
                Expanded(child: _buildSudokuBoardWidget()),
                ActionButtons(
                  onUndo: (_history.isEmpty || _undoUses >= _maxUndoUses) ? null : () {
                    _undoUses++;
                    _handleUndo();
                  },
                  onDelete: (isLocked || _isPaused) ? null : () => _handleNumberInput(0),
                  onMemoToggle: isLocked ? null : () => setState(() => _isMemoMode = !_isMemoMode),
                  isMemoOn: _isMemoMode,
                  hintCount: _hintsRemaining,
                  onHint: (isLocked || _hintsRemaining <= 0 || _isPaused || _selectedRow == null) ? null : _handleHint,
                  undoCount: _undoUses,
                  maxUndoCount: _maxUndoUses,
                ),
                NumberKeypad(
                  board: _getCurrentSudokuBoard(),
                  onNumberTap: (_isPaused || isLocked) ? null : (n) => _handleNumberInput(n),
                ),
                CombatLog(logMessages: _combatLogMessages),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                    style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                ),
                _buildQuickSlots(),
                const AdSenseWidget(),
              ],
            );
          }
        },
      ),
    );
  }

'''

if match:
    content = content[:match.start()] + new_responsive + content[match.end():]
    print('Replaced _buildResponsiveLayout')
else:
    print('Failed to find _buildResponsiveLayout using Regex')

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done sudoku_screen.dart modifications')
