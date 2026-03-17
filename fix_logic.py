import os

filepath = r'c:\Users\PCUSER\Desktop\Sudoku\sudoku_game\lib\views\sudoku_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update _createProjectile
old_projectile = '''  void _createProjectile(int row, int col, int damageDealt) {
    final RenderBox? monsterBox =
        _monsterKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? gridBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;

    if (monsterBox == null || gridBox == null || !mounted) return;

    final monsterPos = monsterBox.localToGlobal(
      Offset(monsterBox.size.width / 2, monsterBox.size.height / 2),
    );
    double cellSize = gridBox.size.width / 9;
    Offset startOffset = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
    final startPos = gridBox.localToGlobal(startOffset);

    final RenderBox screenBox = context.findRenderObject() as RenderBox;
    final relativeStart = screenBox.globalToLocal(startPos);
    final relativeEnd = screenBox.globalToLocal(monsterPos);

    late Widget projectile;
    projectile = ProjectileAnimation(
      key: UniqueKey(),
      startPos: relativeStart,
      endPos: relativeEnd,
      onHit: () {
        if (!mounted) return;
        setState(() {
          _projectiles.remove(projectile);

          _currentMonster = _currentMonster.copyWith(
            currentHp: (_currentMonster.currentHp - damageDealt).clamp(
              0,
              _currentMonster.maxHp,
            ),
          );
          _addCombatLog("${_currentMonster.name}에게 ${damageDealt}의 타격!");

          _createFloatingDamage(monsterPos, damageDealt);
          _screenShakeController.forward(from: 0.0);
          SoundManager.instance.playHitSound();

          if (_currentMonster.isDefeated()) {
            _addCombatLog("${_currentMonster.name}을(를) 처치했습니다!");
            _applyMonsterDefeatRewards();

            if (!_getCurrentSudokuBoard().isSolved()) {
              _loadNextMonster();
            }
          }

          if (!_isMemoMode && _getCurrentSudokuBoard().isSolved()) {
            _timer?.cancel();
            _triggerSuccessSequence();
          }
        });
      },
    );

    setState(() {
      _projectiles.add(projectile);
    });
  }'''

new_projectile = '''  void _createProjectile(int row, int col, int damageDealt) {
    void onHitLogic() {
      if (!mounted) return;
      setState(() {
        _currentMonster = _currentMonster.copyWith(
          currentHp: (_currentMonster.currentHp - damageDealt).clamp(
            0,
            _currentMonster.maxHp,
          ),
        );
        _addCombatLog("${_currentMonster.name}에게 ${damageDealt}의 타격!");

        _screenShakeController.forward(from: 0.0);
        SoundManager.instance.playHitSound();

        if (_currentMonster.isDefeated()) {
          _addCombatLog("${_currentMonster.name}을(를) 처치했습니다!");
          _applyMonsterDefeatRewards();

          if (!_getCurrentSudokuBoard().isSolved()) {
            _loadNextMonster();
          }
        }

        if (!_isMemoMode && _getCurrentSudokuBoard().isSolved()) {
          _timer?.cancel();
          _triggerSuccessSequence();
        }
      });
    }

    final RenderBox? monsterBox =
        _monsterKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? gridBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;

    if (monsterBox == null || gridBox == null || !mounted) {
      onHitLogic();
      return;
    }

    final monsterPos = monsterBox.localToGlobal(
      Offset(monsterBox.size.width / 2, monsterBox.size.height / 2),
    );
    double cellSize = gridBox.size.width / 9;
    Offset startOffset = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
    final startPos = gridBox.localToGlobal(startOffset);

    final RenderBox screenBox = context.findRenderObject() as RenderBox;
    final relativeStart = screenBox.globalToLocal(startPos);
    final relativeEnd = screenBox.globalToLocal(monsterPos);

    late Widget projectile;
    projectile = ProjectileAnimation(
      key: UniqueKey(),
      startPos: relativeStart,
      endPos: relativeEnd,
      onHit: () {
        if (!mounted) return;
        setState(() {
          _projectiles.remove(projectile);
          _createFloatingDamage(monsterPos, damageDealt);
        });
        onHitLogic();
      },
    );

    setState(() {
      _projectiles.add(projectile);
    });
  }'''

if old_projectile in content:
    content = content.replace(old_projectile, new_projectile)
else:
    print('Failed to replace _createProjectile')

old_load_monster = '''  void _loadNextMonster() {
    setState(() {
      _currentMonster = MonsterTemplates.getMonsterForRoom(
        _dungeonMap.currentRoom.type,
      );
      _addCombatLog("야생의 ${_currentMonster.name}이(가) 나타났다!");
    });
  }'''
new_load_monster = '''  void _loadNextMonster() {
    setState(() {
      var nextMonster = MonsterTemplates.getMonsterForRoom(
        _dungeonMap.currentRoom.type,
      );
      if (nextMonster.name == "없음" || nextMonster.maxHp <= 0) {
        nextMonster = MonsterTemplates.numberSlime();
      }
      _currentMonster = nextMonster;
      _addCombatLog("야생의 ${_currentMonster.name}이(가) 나타났다!");
    });
  }'''
if old_load_monster in content:
    content = content.replace(old_load_monster, new_load_monster)
else:
    print('Failed to replace _loadNextMonster')

# Fix _createNewGame where it overrides _currentMonster
old_new_game = '''      _currentMonster = MonsterTemplates.getMonsterForRoom(
        _dungeonMap.currentRoom.type,
      );'''

new_new_game = '''      var initialMonster = MonsterTemplates.getMonsterForRoom(
        _dungeonMap.currentRoom.type,
      );
      if (initialMonster.name == "없음" || initialMonster.maxHp <= 0) {
        initialMonster = MonsterTemplates.numberSlime();
      }
      _currentMonster = initialMonster;'''

# This replacement might apply to multiple places, we want it for _createNewGame.
if old_new_game in content:
    content = content.replace(old_new_game, new_new_game)
else:
    print('Failed to replace _createNewGame')


with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done')
