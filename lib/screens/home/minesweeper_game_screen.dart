import 'dart:async'; // Import for Timer
import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import for Provider
import '../../widgets/custom_button.dart';
import '../../ad_service.dart'; // Import AdService
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import for BannerAd
import '../../providers/user_data_provider.dart'; // Import UserDataProvider
import '../../logger_service.dart'; // Import LoggerService
// Removed direct import of UserService as it will be accessed via UserDataProvider

class MinesweeperGameScreen extends StatefulWidget {
  const MinesweeperGameScreen({super.key});

  @override
  State<MinesweeperGameScreen> createState() => _MinesweeperGameScreenState();
}

class _MinesweeperGameScreenState extends State<MinesweeperGameScreen> {
  // Game state variables
  int _rows = 9;
  int _cols = 9;
  int _numMines = 10;
  List<List<MinesweeperCell>> board = [];
  bool gameOver = false;
  bool gameWon = false;
  int minesFlagged = 0;
  int timerSeconds = 0;
  late Timer _timer;
  late Random _random; // For better mine placement
  late AdService _adService; // AdService instance
  // UserService will be obtained from Provider

  // Custom difficulty settings
  int _selectedRows = 9;
  int _selectedCols = 9;
  int _selectedMines = 10; // Default to 10 mines for initial easy level

  @override
  void initState() {
    super.initState();
    _random = Random(); // Initialize Random
    _timer = Timer(Duration.zero, () {}); // Initialize with a dummy timer
    _adService = AdService(); // Initialize AdService
    _adService.loadBannerAd(); // Load banner ad
    _initializeGame(_selectedRows, _selectedCols, _selectedMines);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer.cancel(); // Cancel any existing timer before starting a new one
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameOver) {
        setState(() {
          timerSeconds++;
        });
      } else {
        _timer.cancel();
      }
  });
}

  void _initializeGame(int newRows, int newCols, int newMines) {
    gameOver = false;
    gameWon = false;
    minesFlagged = 0;
    timerSeconds = 0;
    _timer.cancel(); // Cancel existing timer

    _rows = newRows;
    _cols = newCols;
    _numMines = newMines;

    board = List.generate(_rows, (_) => List.generate(_cols, (_) => MinesweeperCell()));
    _placeMines();
    _calculateAdjacentMines();
    _startTimer(); // Start the game timer

    _adService.loadInterstitialAd(); // Load interstitial ad
    _adService.loadRewardedAd(); // Load rewarded ad
  }

  void _placeMines() {
    int minesPlaced = 0;
    while (minesPlaced < _numMines) {
      int r = _random.nextInt(_rows);
      int c = _random.nextInt(_cols);
      if (!board[r][c].hasMine) {
        board[r][c].hasMine = true;
        minesPlaced++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (!board[r][c].hasMine) {
          int count = 0;
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              if (i == 0 && j == 0) continue;
              int nr = r + i;
              int nc = c + j;
              if (nr >= 0 && nr < _rows && nc >= 0 && nc < _cols && board[nr][nc].hasMine) {
                count++;
              }
            }
          }
          board[r][c].adjacentMines = count;
        }
      }
    }
  }

  void _revealCell(int r, int c) {
    if (gameOver || board[r][c].isRevealed || board[r][c].isFlagged) {
      return;
    }

    setState(() {
      board[r][c].isRevealed = true;

      if (board[r][c].hasMine) {
        gameOver = true;
        _timer.cancel();
        _revealAllMines();
        _showGameResultDialog(false, 0); // Game over, 0 coins earned
      } else if (board[r][c].adjacentMines == 0) {
        _revealEmptyCells(r, c);
      }
      _checkGameWin();
    });
  }

  void _revealEmptyCells(int r, int c) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int nr = r + i;
        int nc = c + j;
        if (nr >= 0 && nr < _rows && nc >= 0 && nc < _cols &&
            !board[nr][nc].isRevealed && !board[nr][nc].hasMine) {
          _revealCell(nr, nc);
        }
      }
    }
  }

  void _toggleFlag(int r, int c) {
    if (gameOver || board[r][c].isRevealed) {
      return;
    }
    setState(() {
      board[r][c].isFlagged = !board[r][c].isFlagged;
      if (board[r][c].isFlagged) {
        minesFlagged++;
      } else {
        minesFlagged--;
      }
      _checkGameWin();
    });
  }

  void _revealAllMines() {
    setState(() {
      for (int r = 0; r < _rows; r++) {
        for (int c = 0; c < _cols; c++) {
          if (board[r][c].hasMine) {
            board[r][c].isRevealed = true;
          }
        }
      }
    });
  }

  void _checkGameWin() {
    int revealedCount = 0;
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (board[r][c].isRevealed && !board[r][c].hasMine) {
          revealedCount++;
        }
      }
    }
    if (revealedCount == (_rows * _cols) - _numMines) {
      gameWon = true;
      gameOver = true;
      _timer.cancel();
      int coinsEarned = _calculateCoinsEarned(revealedCount);
      _showGameResultDialog(true, coinsEarned);
    }
  }

  void _showInterstitialAd() {
    _adService.showInterstitialAd(
      onAdDismissed: () {
        // Interstitial Ad Dismissed
      },
      onAdFailedToShow: () {
        // Interstitial Ad Failed to Show
      },
    );
  }

  void _showRewardedAdForHint() {
    _adService.showRewardedAd(
      onRewardEarned: (int rewardAmount) {
        // Rewarded Ad: User earned $rewardAmount coins for a hint!
        _revealRandomSafeCell(); // Reveal a safe cell as a hint
      },
      onAdFailedToLoad: () {
        // Rewarded Ad Failed to Load
      },
      onAdFailedToShow: () {
        // Rewarded Ad Failed to Show
      },
    );
  }

  void _showDifficultySettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempRows = _selectedRows;
        int tempCols = _selectedCols;
        int tempMines = _selectedMines;

        return AlertDialog(
          title: const Text('Custom Difficulty'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Rows: ${tempRows.toInt()}'),
                    Slider(
                      value: tempRows.toDouble(),
                      min: 5,
                      max: 9,
                      divisions: 4,
                      label: tempRows.toInt().toString(),
                      onChanged: (double value) {
                        setState(() {
                          tempRows = value.toInt();
                        });
                      },
                    ),
                    Text('Columns: ${tempCols.toInt()}'),
                    Slider(
                      value: tempCols.toDouble(),
                      min: 5,
                      max: 9,
                      divisions: 4,
                      label: tempCols.toInt().toString(),
                      onChanged: (double value) {
                        setState(() {
                          tempCols = value.toInt();
                        });
                      },
                    ),
                    Text('Mines: ${tempMines.toInt()}'),
                    Slider(
                      value: tempMines.toDouble(),
                      min: 3,
                      max: 15,
                      divisions: 12,
                      label: tempMines.toInt().toString(),
                      onChanged: (double value) {
                        setState(() {
                          tempMines = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                setState(() {
                  _selectedRows = tempRows;
                  _selectedCols = tempCols;
                  _selectedMines = tempMines;
                  _initializeGame(_selectedRows, _selectedCols, _selectedMines);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _revealRandomSafeCell() {
    if (gameOver) return;

    List<MinesweeperCell> unrevealedSafeCells = [];
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (!board[r][c].isRevealed && !board[r][c].hasMine) {
          unrevealedSafeCells.add(board[r][c]);
        }
      }
    }

    if (unrevealedSafeCells.isNotEmpty) {
      MinesweeperCell randomSafeCell = unrevealedSafeCells[_random.nextInt(unrevealedSafeCells.length)];
      // Find the coordinates of the randomSafeCell
      for (int r = 0; r < _rows; r++) {
        for (int c = 0; c < _cols; c++) {
          if (board[r][c] == randomSafeCell) {
            _revealCell(r, c);
            LoggerService.info('Hint provided: revealed safe cell at ($r, $c)');
            return;
          }
        }
      }
    } else {
      LoggerService.info('No unrevealed safe cells available for a hint.');
    }
  }

  int _calculateCoinsEarned(int revealedSafeTiles) {
    // Max coins per tile is 50.
    // The total potential reward increases with the number of mines.
    // Let's define a base reward per safe tile, and scale it by mine count.
    // Max possible coins for winning a game with 15 mines and 20x20 board (400 tiles)
    // (400 - 15) * 50 = 19250 coins. This seems reasonable.

    double baseRewardPerTile = 1.0; // Base coins for each revealed safe tile
    double mineMultiplier = _numMines / 10.0; // Scale reward by mine count (e.g., 10 mines = 1x, 15 mines = 1.5x)

    int totalCoins = (revealedSafeTiles * baseRewardPerTile * mineMultiplier).round();

    // Ensure coins per tile does not exceed 50
    if (totalCoins > revealedSafeTiles * 50) {
      totalCoins = revealedSafeTiles * 50;
    }

    return totalCoins;
  }

  void _cashOut() {
    if (gameOver) return;

    int revealedSafeTiles = 0;
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (board[r][c].isRevealed && !board[r][c].hasMine) {
          revealedSafeTiles++;
        }
      }
    }

    int coinsEarned = _calculateCoinsEarned(revealedSafeTiles);
    setState(() {
      gameOver = true;
      _timer.cancel();
    });
    _showGameResultDialog(true, coinsEarned, isCashOut: true);
  }

  void _showGameResultDialog(bool win, int coinsEarned, {bool isCashOut = false}) {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    if (coinsEarned > 0) {
      userDataProvider.updateUserCoins(coinsEarned);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCashOut ? 'CASHED OUT!' : (win ? 'YOU WON!' : 'GAME OVER!')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isCashOut
                  ? 'You cashed out and earned $coinsEarned coins!'
                  : (win
                      ? 'Congratulations! You earned $coinsEarned coins!'
                      : 'Better luck next time!')),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Play Again',
                onPressed: () {
                  Navigator.of(context).pop();
                  _initializeGame(_selectedRows, _selectedCols, _selectedMines);
                  _showInterstitialAd();
                },
              ),
              const SizedBox(height: 10),
              if (!win && !isCashOut) // Only show hint if lost and not cashed out
                CustomButton(
                  text: 'Get a Hint (Watch Ad)',
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showRewardedAdForHint();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Minesweeper'),
          actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showDifficultySettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _initializeGame(_selectedRows, _selectedCols, _selectedMines),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(context, Icons.flag, '${_numMines - minesFlagged}'),
                _buildInfoChip(context, Icons.timer, '$timerSeconds s'),
                if (!gameOver)
                  CustomButton(
                    text: 'Cash Out',
                    onPressed: _cashOut,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _cols,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _rows * _cols,
              itemBuilder: (context, index) {
                int r = index ~/ _cols;
                int c = index % _cols;
                MinesweeperCell cell = board[r][c];

                Color cellColor = Colors.grey[400]!; // Default unrevealed color
                Widget? cellContent;
                Color textColor = Colors.black;

                if (cell.isRevealed) {
                  if (cell.hasMine) {
                    cellColor = Colors.redAccent;
                    cellContent = const Icon(Icons.local_fire_department, size: 24, color: Colors.white);
                  } else if (cell.adjacentMines > 0) {
                    cellColor = Colors.grey[200]!;
                    textColor = _getAdjacentMineColor(cell.adjacentMines);
                    cellContent = Text(
                      '${cell.adjacentMines}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    );
                  } else {
                    cellColor = Colors.grey[200]!;
                  }
                } else if (cell.isFlagged) {
                  cellColor = Colors.orange[200]!;
                  cellContent = const Icon(Icons.flag, size: 24, color: Colors.red);
                }

                return GestureDetector(
                  onTap: () => _revealCell(r, c),
                  onLongPress: () => _toggleFlag(r, c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(6.0),
                      boxShadow: cell.isRevealed
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.grey.shade600,
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                                spreadRadius: 0.5,
                              ),
                            ],
                    ),
                    alignment: Alignment.center,
                    child: cellContent,
                  ),
                );
              },
            ),
          ),
          if (_adService.bannerAd != null)
            SizedBox(
              width: _adService.bannerAd!.size.width.toDouble(),
              height: _adService.bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _adService.bannerAd!),
            ),
        ],
      ),
    ));
  }

  Color _getAdjacentMineColor(int count) {
    switch (count) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.deepPurple;
      case 5: return Colors.brown;
      case 6: return Colors.teal;
      case 7: return Colors.black;
      case 8: return Colors.grey;
      default: return Colors.black;
    }
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MinesweeperCell {
  bool hasMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;

  MinesweeperCell({
    this.hasMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}
