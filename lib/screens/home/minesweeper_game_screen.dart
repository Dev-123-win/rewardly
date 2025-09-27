import 'dart:async'; // Import for Timer
import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../ad_service.dart'; // Import AdService
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import for BannerAd

class MinesweeperGameScreen extends StatefulWidget {
  const MinesweeperGameScreen({super.key});

  @override
  State<MinesweeperGameScreen> createState() => _MinesweeperGameScreenState();
}

class _MinesweeperGameScreenState extends State<MinesweeperGameScreen> {
  // Game state variables
  int rows = 9;
  int cols = 9;
  int numMines = 10;
  List<List<MinesweeperCell>> board = [];
  bool gameOver = false;
  bool gameWon = false;
  int minesFlagged = 0;
  int timerSeconds = 0;
  late Timer _timer;
  late Random _random; // For better mine placement
  late AdService _adService; // AdService instance

  MinesweeperDifficulty _difficulty = MinesweeperDifficulty.easy;

  @override
  void initState() {
    super.initState();
    _random = Random(); // Initialize Random
    _timer = Timer(Duration.zero, () {}); // Initialize with a dummy timer
    _adService = AdService(); // Initialize AdService
    _adService.loadBannerAd(); // Load banner ad
    _initializeGame();
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

  void _initializeGame() {
    gameOver = false;
    gameWon = false;
    minesFlagged = 0;
    timerSeconds = 0;
    _timer.cancel(); // Cancel existing timer

    // Set board size and mine count based on difficulty
    switch (_difficulty) {
      case MinesweeperDifficulty.easy:
        rows = 9;
        cols = 9;
        numMines = 10;
        break;
      case MinesweeperDifficulty.medium:
        rows = 16;
        cols = 16;
        numMines = 40;
        break;
      case MinesweeperDifficulty.hard:
        rows = 16;
        cols = 30;
        numMines = 99;
        break;
    }

    board = List.generate(rows, (_) => List.generate(cols, (_) => MinesweeperCell()));
    _placeMines();
    _calculateAdjacentMines();
    _startTimer(); // Start the game timer

    _adService.loadInterstitialAd(); // Load interstitial ad
    _adService.loadRewardedAd(); // Load rewarded ad
  }

  void _placeMines() {
    int minesPlaced = 0;
    while (minesPlaced < numMines) {
      int r = _random.nextInt(rows);
      int c = _random.nextInt(cols);
      if (!board[r][c].hasMine) {
        board[r][c].hasMine = true;
        minesPlaced++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!board[r][c].hasMine) {
          int count = 0;
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              if (i == 0 && j == 0) continue;
              int nr = r + i;
              int nc = c + j;
              if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && board[nr][nc].hasMine) {
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
        // _timer?.cancel();
        _revealAllMines();
        // Show game over dialog
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
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols &&
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
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (board[r][c].hasMine) {
            board[r][c].isRevealed = true;
          }
        }
      }
    });
  }

  void _checkGameWin() {
    int revealedCount = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c].isRevealed && !board[r][c].hasMine) {
          revealedCount++;
        }
      }
    }
    if (revealedCount == (rows * cols) - numMines) {
      gameWon = true;
      gameOver = true;
      _timer.cancel();
      // Show win dialog
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
        // TODO: Implement hint logic here, e.g., reveal a safe cell
      },
      onAdFailedToLoad: () {
        // Rewarded Ad Failed to Load
      },
      onAdFailedToShow: () {
        // Rewarded Ad Failed to Show
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper'),
        actions: [
          DropdownButton<MinesweeperDifficulty>(
            value: _difficulty,
            onChanged: (MinesweeperDifficulty? newValue) {
              if (newValue != null) {
                setState(() {
                  _difficulty = newValue;
                  _initializeGame();
                });
              }
            },
            items: MinesweeperDifficulty.values.map((MinesweeperDifficulty classType) {
              return DropdownMenuItem<MinesweeperDifficulty>(
                value: classType,
                child: Text(classType.toString().split('.').last.toUpperCase()),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Mines: ${numMines - minesFlagged}'),
                Text('Time: $timerSeconds s'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: 1.0,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                int r = index ~/ cols;
                int c = index % cols;
                MinesweeperCell cell = board[r][c];

                Color cellColor = Colors.grey[300]!;
                Widget? cellContent;

                if (cell.isRevealed) {
                  if (cell.hasMine) {
                    cellColor = Colors.red;
                    cellContent = const Icon(Icons.close, size: 20);
                  } else if (cell.adjacentMines > 0) {
                    cellColor = Colors.grey[200]!;
                    cellContent = Text(
                      '${cell.adjacentMines}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getAdjacentMineColor(cell.adjacentMines),
                      ),
                    );
                  } else {
                    cellColor = Colors.grey[200]!;
                  }
                } else if (cell.isFlagged) {
                  cellContent = const Icon(Icons.flag, size: 20, color: Colors.red);
                }

                return GestureDetector(
                  onTap: () => _revealCell(r, c),
                  onLongPress: () => _toggleFlag(r, c),
                  child: Container(
                    color: cellColor,
                    alignment: Alignment.center,
                    child: cellContent,
                  ),
                );
              },
            ),
          ),
          if (gameOver)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    gameWon ? 'YOU WON!' : 'GAME OVER!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'Play Again',
                    onPressed: () {
                      _initializeGame();
                      _showInterstitialAd(); // Show ad after game
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'Get a Hint (Watch Ad)',
                    onPressed: _showRewardedAdForHint,
                  ),
                ],
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
    );
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

enum MinesweeperDifficulty {
  easy,
  medium,
  hard,
}
