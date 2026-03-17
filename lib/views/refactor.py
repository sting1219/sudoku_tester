import os
import re

filepath = r'c:\Users\PCUSER\Desktop\Sudoku\sudoku_game\lib\views\sudoku_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Insert new methods above _buildGameScreen
insert_code = '''
  void _handleHint() {
    if (_isCellLocked() || _hintsRemaining <= 0 || _isPaused || _selectedRow == null) return;
    setState(() {
      _history.add(
        GameState(
          dungeonMap: _dungeonMap.clone(),
          currentMonster: _currentMonster,
          playerCombatStats: _playerCombatStats,
          combatLogMessages: List<String>.from(_combatLogMessages),
          comboCount: _comboCount,
          lastCorrectEntryTime: _lastCorrectEntryTime,
          hintsRemaining: _hintsRemaining,
          undoUses: _undoUses,
        ),
      );
      if (_history.length > 20) {
        _history.removeAt(0);
      }
      _getCurrentSudokuBoard().giveHint(_selectedRow!, _selectedCol!);
      _hintsRemaining--;
    });
  }

  Widget _buildTopControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameStatus(
          difficulty:
              "${_getCurrentSudokuBoard().difficulty.label} [${_getCurrentSudokuBoard().difficulty.rpgGrade}]",
          mistakes: _getCurrentSudokuBoard().mistakes,
          maxMistakes: _getCurrentSudokuBoard().maxMistakes,
          time: _formatTime(_secondsElapsed),
          onPauseTap: _togglePause,
          playerLevel: _userData.level,
          playerCurrentHp: _playerCombatStats.currentHp,
          playerMaxHp: _playerCombatStats.maxHp,
          playerCurrentXp: _userData.currentXp,
          playerTotalXpNeeded: _userData.totalXpNeeded,
          playerGold: _userData.gold,
          hintsRemaining: _hintsRemaining,
          undoCount: _undoUses,
          maxUndoCount: _maxUndoUses,
        ),
        PurificationGauge(progress: _roomPurificationRate),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.settings, size: 18, color: Colors.white70),
              label: const Text("설정", style: TextStyle(color: Colors.white70)),
              onPressed: _showSettingsDialog,
            ),
            const SizedBox(width: 10),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildBottomControls() {
    bool isLocked = _isCellLocked();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CombatLog(logMessages: _combatLogMessages),
        ActionButtons(
          onUndo:
              (_history.isEmpty || _undoUses >= _maxUndoUses)
                  ? null
                  : () {
                      _undoUses++;
                      _handleUndo();
                    },
          onDelete:
              (isLocked || _isPaused) ? null : () => _handleNumberInput(0),
          onMemoToggle:
              isLocked
                  ? null
                  : () => setState(() => _isMemoMode = !_isMemoMode),
          isMemoOn: _isMemoMode,
          hintCount: _hintsRemaining,
          onHint:
              (isLocked ||
                      _hintsRemaining <= 0 ||
                      _isPaused ||
                      _selectedRow == null)
                  ? null
                  : _handleHint,
          undoCount: _undoUses,
          maxUndoCount: _maxUndoUses,
        ),
        NumberKeypad(
          board: _getCurrentSudokuBoard(),
          onNumberTap:
              (_isPaused || isLocked) ? null : (n) => _handleNumberInput(n),
        ),
        _buildQuickSlots(),
        const AdSenseWidget(),
      ],
    );
  }

  Widget _buildSudokuBoardWidget() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Center(
        child: Padding(
          padding: EdgeInsets.zero,
          child:
              _showMoveButtons
                  ? Stack(
                      children: [
                        SudokuGrid(
                          key: _gridKey,
                          board: _getCurrentSudokuBoard(),
                          onCellTap: _onCellTapped,
                          onCellLongPress: _handleCellLongPress,
                          selectedRow: _selectedRow,
                          selectedCol: _selectedCol,
                          errorMap: _getCurrentSudokuBoard().errorMap,
                          isSuccess: _isSuccessAnimation,
                          flashingRow: _flashingRow,
                          flashingCol: _flashingCol,
                          conflicts: _currentConflicts,
                          errorRow: _errorRow,
                          errorCol: _errorCol,
                          conflictAnimationValue: _conflictAnimationValue,
                        ),
                        if (_errorExplanation != null)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerColor.withValues(
                                    alpha: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _errorExplanation!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_dungeonMap.currentRoom.isCleared)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "이미 정복한 지역입니다!",
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineMedium!.copyWith(
                                          color: Colors.white,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildMoveButtons(),
                                ],
                              ),
                            ),
                          )
                        else
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: _buildMoveButtons(),
                            ),
                          ),
                      ],
                    )
                  : Stack(
                      children: [
                        SudokuGrid(
                          key: _gridKey,
                          board: _getCurrentSudokuBoard(),
                          onCellTap: _onCellTapped,
                          onCellLongPress: _handleCellLongPress,
                          selectedRow: _selectedRow,
                          selectedCol: _selectedCol,
                          errorMap: _getCurrentSudokuBoard().errorMap,
                          isSuccess: _isSuccessAnimation,
                          flashingRow: _flashingRow,
                          flashingCol: _flashingCol,
                          conflicts: _currentConflicts,
                          errorRow: _errorRow,
                          errorCol: _errorCol,
                          conflictAnimationValue: _conflictAnimationValue,
                        ),
                        if (_errorExplanation != null)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _errorExplanation!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout() {'''

content = content.replace('  Widget _buildGameScreen() {', insert_code)

layout_code = '''      child: LayoutBuilder(
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

match = re.search(r'      child: Column\(.*?      \),\n    \);\n  }', content, re.DOTALL)
if match:
    content = content[:match.start()] + layout_code + content[match.end():]
else:
    print("Could not find _buildResponsiveLayout body to replace.")

build_str_to_replace = '''                MonsterStatus(key: _monsterKey, monster: _currentMonster),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Expanded(child: _buildGameScreen()),
                          ],
                        ),
                      ),
                      if (MediaQuery.of(context).size.width > 600)
                        MiniMap(dungeonMap: _dungeonMap),'''

new_build_code = '''                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildResponsiveLayout()),
                      if (MediaQuery.of(context).size.width > 600)
                        MiniMap(dungeonMap: _dungeonMap),'''

if build_str_to_replace in content:
    content = content.replace(build_str_to_replace, new_build_code)
else:
    print(f"Could not find the target build pattern using string replacement.")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
