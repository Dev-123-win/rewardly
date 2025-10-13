import 'dart:async'; // Import for Timer
import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import for Provider
import '../../widgets/custom_button.dart';
import '../../ad_service.dart'; // Import AdService
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import for BannerAd
import 'package:lottie/lottie.dart'; // Import Lottie package
import '../../providers/user_data_provider.dart'; // Import UserDataProvider
import '../../logger_service.dart'; // Import LoggerService
// Removed direct import of UserService as it will be accessed via UserDataProvider

class MinesweeperGameScreen extends StatefulWidget {
  const MinesweeperGameScreen({super.key});

  @override
  State<MinesweeperGameScreen> createState() => _MinesweeperGameScreenState();
}

class _MinesweeperGameScreenState extends State<MinesweeperGameScreen>
    with TickerProviderStateMixin {
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
  late AnimationController _dialogAnimationController;
  late Animation<double> _dialogScaleAnimation;
  // UserService will be obtained from Provider

  // Custom difficulty settings
  int _selectedRows = 5; // Set to lowest available
  int _selectedCols = 5; // Set to lowest available
  int _selectedMines = 3; // Set to lowest available

  @override
  void initState() {
    super.initState();
    _random = Random(); // Initialize Random
    _timer = Timer(Duration.zero, () {}); // Initialize with a dummy timer
    _adService = AdService(); // Initialize AdService
    _adService.loadBannerAd(); // Load banner ad
    _adService.loadRewardedInterstitialAd(); // Load rewarded interstitial ad

    _dialogAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _dialogScaleAnimation = CurvedAnimation(
      parent: _dialogAnimationController,
      curve: Curves.elasticOut,
    );

    _initializeGame(_selectedRows, _selectedCols, _selectedMines);
  }

  @override
  void dispose() {
    _timer.cancel();
    _dialogAnimationController.dispose();
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
    _adService.loadRewardedInterstitialAd(); // Load rewarded interstitial ad
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


  void _showDifficultySettingsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        int tempRows = _selectedRows;
        int tempCols = _selectedCols;
        int tempMines = _selectedMines;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Custom Difficulty',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Board Size:'),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          value: tempRows, // Assuming rows and cols are always equal for board size
                          items: const [
                            DropdownMenuItem(value: 3, child: Text('3x3')),
                            DropdownMenuItem(value: 4, child: Text('4x4')),
                            DropdownMenuItem(value: 5, child: Text('5x5')),
                            DropdownMenuItem(value: 6, child: Text('6x6')),
                          ],
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                tempRows = newValue;
                                tempCols = newValue;
                                // Adjust mines if current selection is too high for new board size
                                if (tempMines > (newValue * newValue) ~/ 3) {
                                  tempMines = (newValue * newValue) ~/ 3;
                                }
                                if (tempMines > 9) { // Ensure mines don't exceed 9
                                  tempMines = 9;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Mines:'),
                        Expanded(
                          child: Slider(
                            value: tempMines.toDouble(),
                            min: 1, // Minimum 1 mine
                            max: min(9, (tempRows * tempCols) - 1).toDouble(), // Max 9 mines or (rows*cols - 1)
                            divisions: min(9, (tempRows * tempCols) - 1) - 1, // Divisions based on max mines
                            label: tempMines.toInt().toString(),
                            onChanged: (double value) {
                              setState(() {
                                tempMines = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text(tempMines.toInt().toString()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomButton(
                          text: 'Cancel',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        CustomButton(
                          text: 'Apply',
                          onPressed: () {
                            Navigator.of(context).pop(); // Dismiss the bottom sheet first
                            // Update the main state to apply new settings
                            setState(() {
                              _selectedRows = tempRows;
                              _selectedCols = tempCols;
                              _selectedMines = tempMines;
                            });
                            _initializeGame(_selectedRows, _selectedCols, _selectedMines);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

    // Ensure rewarded interstitial ad is loaded before showing
    _adService.loadRewardedInterstitialAd();

    // Show rewarded interstitial ad for cash out
    _adService.showRewardedInterstitialAd(
      onRewardEarned: (int rewardAmount) {
        LoggerService.info('Rewarded Interstitial Ad: User earned $rewardAmount for cashing out.');
        setState(() {
          gameOver = true;
          _timer.cancel();
        });
        _showGameResultDialog(true, coinsEarned, isCashOut: true);
      },
      onAdDismissed: () {
        LoggerService.info('Rewarded Interstitial Ad for cash out dismissed.');
        // If ad is dismissed without earning reward, still cash out but without extra reward
        setState(() {
          gameOver = true;
          _timer.cancel();
        });
        _showGameResultDialog(true, coinsEarned, isCashOut: true);
      },
      onAdFailedToShow: () {
        LoggerService.error('Rewarded Interstitial Ad for cash out failed to show.');
        // If ad fails to show, proceed with cash out without ad reward
        setState(() {
          gameOver = true;
          _timer.cancel();
        });
        _showGameResultDialog(true, coinsEarned, isCashOut: true);
      },
    );
  }

  void _showGameResultDialog(bool win, int coinsEarned, {bool isCashOut = false}) {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    if (coinsEarned > 0) {
      userDataProvider.updateUserCoins(coinsEarned);
    }

    _dialogAnimationController.forward(from: 0); // Start animation

    String lottieAsset;
    String title;
    String content;

    if (isCashOut) {
      lottieAsset = 'assets/lottie/cash out.json'; // Use cash out animation
      title = 'CASHED OUT!';
      content = 'You cashed out and earned $coinsEarned coins!';
    } else if (win) {
      lottieAsset = 'assets/lottie/win animation.json';
      title = 'YOU WON!';
      content = 'Congratulations! You earned $coinsEarned coins!';
    } else {
      lottieAsset = 'assets/lottie/Game Over.json'; // Use Game Over animation for game over
      title = 'GAME OVER!';
      content = 'Better luck next time!';
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true, // Allow the bottom sheet to be full height
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.7, // Make it cover 70% of the screen height
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Use theme card color
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), // Slightly larger radius
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0), // Increased padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                mainAxisSize: MainAxisSize.max, // Take max available height
                children: [
                  ScaleTransition(
                    scale: _dialogScaleAnimation,
                    child: Lottie.asset(
                      lottieAsset,
                      width: 150, // Adjust size as needed
                      height: 150, // Adjust size as needed
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 25), // Increased spacing
                  ScaleTransition(
                    scale: _dialogScaleAnimation,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark), // Enhanced text style
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700), // Enhanced text style
                  ),
                  const SizedBox(height: 40), // Increased spacing

                  if (win && !isCashOut) ...[
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Claim $coinsEarned Coins (Watch Ad)',
                        onPressed: () {
                          Navigator.of(context).pop();
                          _adService.loadRewardedInterstitialAd(); // Ensure ad is loaded
                          _adService.showRewardedInterstitialAd(
                            onRewardEarned: (int rewardAmount) {
                              LoggerService.info('Rewarded Interstitial Ad: User claimed $coinsEarned coins.');
                              // Coins are already added in _showGameResultDialog, no need to add again
                            },
                            onAdDismissed: () {
                              LoggerService.info('Rewarded Interstitial Ad for claiming dismissed.');
                            },
                            onAdFailedToShow: () {
                              LoggerService.error('Rewarded Interstitial Ad for claiming failed to show.');
                            },
                          );
                          _initializeGame(_selectedRows, _selectedCols, _selectedMines);
                        },
                        startColor: Colors.green,
                        endColor: Colors.green.withAlpha((255 * 0.7).round()),
                        textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Double $coinsEarned Coins (Watch Ad)',
                        onPressed: () {
                          Navigator.of(context).pop();
                          _adService.loadRewardedInterstitialAd(); // Ensure ad is loaded
                          _adService.showRewardedInterstitialAd(
                            onRewardEarned: (int rewardAmount) {
                              LoggerService.info('Rewarded Interstitial Ad: User doubled $coinsEarned coins.');
                              userDataProvider.updateUserCoins(coinsEarned); // Add coins again to double
                            },
                            onAdDismissed: () {
                              LoggerService.info('Rewarded Interstitial Ad for doubling dismissed.');
                            },
                            onAdFailedToShow: () {
                              LoggerService.error('Rewarded Interstitial Ad for doubling failed to show.');
                            },
                          );
                          _initializeGame(_selectedRows, _selectedCols, _selectedMines);
                        },
                        startColor: Colors.blueAccent,
                        endColor: Colors.blueAccent.withOpacity(0.7),
                        textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  SizedBox(
                    width: double.infinity, // Full width button
                    child: CustomButton(
                      text: 'Play Again',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _initializeGame(_selectedRows, _selectedCols, _selectedMines);
                        _showInterstitialAd();
                      },
                      startColor: Theme.of(context).primaryColor,
                      endColor: Theme.of(context).primaryColor.withOpacity(0.7),
                      textStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
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
        body: Stack(
          children: [
            Column(
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300), // Subtle animation duration
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child); // Fade transition
                    },
                    child: GridView.builder(
                      key: ValueKey('minesweeper_board_$_rows\_$_cols'), // Key to trigger animation on size change
                      padding: const EdgeInsets.all(4.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _cols,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 4.0, // Keep for thin dark lines
                        mainAxisSpacing: 4.0, // Keep for thin dark lines
                      ),
                      itemCount: _rows * _cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ _cols;
                        int c = index % _cols;
                        MinesweeperCell cell = board[r][c];

                        Color baseColor = Colors.grey[300]!; // Lighter base for unrevealed
                        Color revealedColor = Colors.grey[200]!; // Color for revealed cells
                        Widget? cellContent;
                        Color textColor = Colors.black;

                        List<BoxShadow> shadows;
                        BorderRadius borderRadius = BorderRadius.circular(8.0); // Slightly rounded edges

                        if (cell.isRevealed) {
                          if (cell.hasMine) {
                            baseColor = Colors.redAccent;
                            cellContent = Lottie.asset(
                              'assets/lottie/bomb.json',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            );
                          } else if (cell.adjacentMines > 0) {
                            baseColor = revealedColor;
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
                            baseColor = revealedColor;
                          }
                          // For revealed cells, make them look "pressed in" or flat
                          shadows = [
                            BoxShadow(
                              color: Colors.grey.shade500,
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                              spreadRadius: 0.5,
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(-1, -1),
                              blurRadius: 3,
                              spreadRadius: 0.5,
                            ),
                          ];
                        } else if (cell.isFlagged) {
                          baseColor = Colors.orange[200]!;
                          cellContent = const Icon(Icons.flag, size: 24, color: Colors.red);
                          // For flagged cells, keep a slightly raised look
                          shadows = [
                            BoxShadow(
                              color: Colors.grey.shade600,
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                            const BoxShadow(
                              color: Colors.white,
                              offset: Offset(-2, -2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ];
                        } else {
                          // For unrevealed cells, create a 3D effect with soft outer shadows and highlights
                          shadows = [
                            BoxShadow(
                              color: Colors.grey.shade500, // Darker shadow for depth
                              offset: const Offset(3, 3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                            const BoxShadow(
                              color: Colors.white, // Lighter shadow for highlight
                              offset: Offset(-3, -3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ];
                        }

                        return GestureDetector(
                          onTap: () => _revealCell(r, c),
                          onLongPress: () => _toggleFlag(r, c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: borderRadius,
                              boxShadow: shadows,
                            ),
                            alignment: Alignment.center,
                            child: cellContent,
                          ),
                        );
                      },
                    ),
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
          ],
        ),
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
