import 'dart:async'; // Import for Timer
import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
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
  int _rows = 3; // Default to 3x3
  int _cols = 3; // Default to 3x3
  int _numMines = 1; // Default to 1 mine
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
  int _selectedRows = 3; // Default to 3x3
  int _selectedCols = 3; // Default to 3x3
  int _selectedMines = 1; // Default to 1 mine


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
    _assignCellCoins(); // New method to assign random coins
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

  // New method to assign random coin values to non-mine cells
  void _assignCellCoins() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (!board[r][c].hasMine) {
          // Assign a random number between 1 and 8 (inclusive) as coins
          board[r][c].adjacentMines = _random.nextInt(8) + 1;
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
      } else {
        // No auto-reveal, just check for win
        _checkGameWin();
      }
    });
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

      int coinsFromRevealedCells = 0;
      for (int r = 0; r < _rows; r++) {
        for (int c = 0; c < _cols; c++) {
          if (board[r][c].isRevealed && !board[r][c].hasMine) {
            coinsFromRevealedCells += board[r][c].adjacentMines; // Sum up coin values
          }
        }
      }

      int baseWinningAmount = _calculateBaseWinningAmount(revealedCount); // New method for base winning amount
      int totalCoinsEarned = baseWinningAmount + coinsFromRevealedCells;
      _showGameResultDialog(true, totalCoinsEarned);
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
        int tempMines = _selectedMines; // Now adjustable

        // Define available board sizes for custom mode (3x3 to 6x6)
        final List<int> availableBoardSizes = [3, 4, 5, 6];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Helper to update custom mine count based on new board size
            void updateMinesForBoardSize(int newRows, int newCols) {
              int maxMines = (newRows * newCols) - 1; // Max mines is total cells - 1
              if (tempMines > maxMines) {
                tempMines = maxMines;
              }
              // Ensure a minimum of 1 mine
              if (tempMines < 1) {
                tempMines = 1;
              }
            }

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
                      'Game Settings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Board Size Selection
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Board Size:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: availableBoardSizes.map((size) {
                        bool isSelected = tempRows == size;
                        return CustomButton(
                          text: '${size}x$size',
                          onPressed: () {
                            setState(() {
                              tempRows = size;
                              tempCols = size;
                              updateMinesForBoardSize(tempRows, tempCols); // Update mines based on new board size
                            });
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          startColor: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                          endColor: isSelected ? Theme.of(context).primaryColor.withAlpha((255 * 0.7).round()) : Theme.of(context).cardColor,
                          textStyle: TextStyle(
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withAlpha((255 * 0.4).round()),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.grey.shade500,
                                    offset: const Offset(3, 3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                  const BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-3, -3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Mines Slider (reintroduced)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mines: $tempMines',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Theme.of(context).primaryColor,
                        inactiveTrackColor: Theme.of(context).primaryColor.withAlpha((255 * 0.3).round()),
                        thumbColor: Theme.of(context).primaryColorDark,
                        overlayColor: Theme.of(context).primaryColor.withAlpha((255 * 0.2).round()),
                        valueIndicatorColor: Theme.of(context).primaryColor,
                        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                      ),
                      child: Slider(
                        value: tempMines.toDouble(),
                        min: 1,
                        max: (tempRows * tempCols - 1).toDouble(), // Max mines is total cells - 1
                        divisions: ((tempRows * tempCols - 1) - 1).clamp(1, 98).toInt(), // Ensure at least 1 division if max > min
                        label: tempMines.toInt().toString(),
                        onChanged: (double value) {
                          setState(() {
                            tempMines = value.toInt();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomButton(
                          text: 'Cancel',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          startColor: Colors.grey.shade400,
                          endColor: Colors.grey.shade600,
                          textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        CustomButton(
                          text: 'Apply',
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedRows = tempRows;
                              _selectedCols = tempCols;
                              _selectedMines = tempMines; // Now uses tempMines
                              // _currentDifficultyPreset is no longer needed
                            });
                            _initializeGame(_selectedRows, _selectedCols, _selectedMines);
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          startColor: Theme.of(context).primaryColor,
                          endColor: Theme.of(context).primaryColor.withAlpha((255 * 0.7).round()),
                          textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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


  // Calculates the base winning amount, separate from individual cell coins
  int _calculateBaseWinningAmount(int revealedSafeTiles) {
    // This can be a fixed amount or scaled based on difficulty/tiles
    // For now, let's use a simple scaling based on revealed safe tiles and mine count
    double baseRewardPerTile = 1.0;
    double mineMultiplier = _numMines / 10.0; // Scale by mine count

    int baseCoins = (revealedSafeTiles * baseRewardPerTile * mineMultiplier).round();

    // Ensure coins per tile does not exceed 50 for the base amount
    if (baseCoins > revealedSafeTiles * 50) {
      baseCoins = revealedSafeTiles * 50;
    }
    return baseCoins;
  }

  // This method is now primarily for cash out, or can be adapted if needed elsewhere
  // For winning, the coins are calculated directly in _checkGameWin
  int _calculateCoinsEarned(int revealedSafeTiles) {
    // For cash out, we only consider the base reward for revealed tiles
    return _calculateBaseWinningAmount(revealedSafeTiles);
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
                    color: Colors.black.withAlpha((255 * 0.15).round()),
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
                        text: 'Claim $coinsEarned Coins', // Simplified text
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
                        endColor: Colors.blueAccent.withAlpha((255 * 0.7).round()),
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
                      endColor: Theme.of(context).primaryColor.withAlpha((255 * 0.7).round()),
                      textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        backgroundColor: const Color(0xFF1A1A1A), // Dark background color
        body: Stack(
          children: [
            // Background grid pattern (optional, can be added with a CustomPainter or image)
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),
            Column(
              children: [
                // Custom App Bar
                _buildCustomAppBar(context),
                // Top Info Bar (Mine Counter, Timer, Cash Out)
                _buildTopInfoBar(context),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300), // Subtle animation duration
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child); // Fade transition
                    },
                    child: GridView.builder(
                      key: ValueKey('minesweeper_board_${_rows}_$_cols'), // Key to trigger animation on size change
                      padding: const EdgeInsets.all(8.0), // Increased padding for the board
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _cols,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 8.0, // Increased spacing
                        mainAxisSpacing: 8.0, // Increased spacing
                      ),
                      itemCount: _rows * _cols,
                      itemBuilder: (context, index) {
                        int r = index ~/ _cols;
                        int c = index % _cols;
                        MinesweeperCell cell = board[r][c];

                        Widget? cellContent;
                        Color textColor = Colors.white; // Default text color for dark theme

                        List<BoxShadow> shadows;
                        BorderRadius borderRadius = BorderRadius.circular(12.0); // More rounded edges

                        if (cell.isRevealed) {
                          if (cell.hasMine) {
                            // Revealed mine
                            cellContent = Image.asset(
                              'assets/bomb.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            );
                            shadows = _getPressedInShadows();
                          } else {
                            // Revealed non-mine cell, display coin value
                            textColor = _getAdjacentMineColor(cell.adjacentMines); // Use existing color logic for coin numbers
                            cellContent = Text(
                              '${cell.adjacentMines}', // adjacentMines now holds coin value
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20, // Slightly larger font
                                color: textColor,
                              ),
                            );
                            shadows = _getPressedInShadows();
                          }
                        } else if (cell.isFlagged) {
                          // Flagged cell
                          cellContent = Image.asset(
                            'assets/minesweeper.png', // Using the provided image for flag
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                            color: Colors.redAccent, // Red flag
                          );
                          shadows = _getRaisedShadows();
                        } else {
                          // Unrevealed cell
                          shadows = _getRaisedShadows();
                        }

                        return GestureDetector(
                          onTap: () => _revealCell(r, c),
                          onLongPress: () => _toggleFlag(r, c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2C), // Darker cell background
                              borderRadius: borderRadius,
                              boxShadow: shadows,
                              border: Border.all(
                                color: Colors.blueGrey.shade700, // Subtle border
                                width: 1.0,
                              ),
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

  // Helper for pressed-in shadow effect
  List<BoxShadow> _getPressedInShadows() {
    return [
      BoxShadow(
        color: Colors.black.withAlpha((255 * 0.5).round()),
        offset: const Offset(2, 2),
        blurRadius: 5,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.white.withAlpha((255 * 0.1).round()),
        offset: const Offset(-2, -2),
        blurRadius: 5,
        spreadRadius: 1,
      ),
      // Removed 'inset: true' as it's not a standard BoxShadow property
    ];
  }

  // Helper for raised shadow effect
  List<BoxShadow> _getRaisedShadows() {
    return [
      BoxShadow(
        color: Colors.black.withAlpha((255 * 0.6).round()),
        offset: const Offset(4, 4),
        blurRadius: 10,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.white.withAlpha((255 * 0.15).round()),
        offset: const Offset(-4, -4),
        blurRadius: 10,
        spreadRadius: 1,
      ),
    ];
  }

  Color _getAdjacentMineColor(int count) {
    switch (count) {
      case 1: return Colors.blue.shade300;
      case 2: return Colors.green.shade300;
      case 3: return Colors.red.shade300;
      case 4: return Colors.deepPurple.shade300;
      case 5: return Colors.brown.shade300;
      case 6: return Colors.teal.shade300;
      case 7: return Colors.white;
      case 8: return Colors.grey.shade400;
      default: return Colors.white;
    }
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white, size: 28), // Replaced Icon with HugeIcon
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const Text(
            'MINESWEEPER',
            style: TextStyle(
              fontFamily: 'Calinastiya demo',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings01, color: Colors.white, size: 28), // Replaced Icon with HugeIcon
                onPressed: _showDifficultySettingsDialog,
              ),
              IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedRefresh, color: Colors.white, size: 28), // Replaced Icon with HugeIcon
                onPressed: () => _initializeGame(_selectedRows, _selectedCols, _selectedMines),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfoBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // Dark background for the info bar
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.5).round()),
            offset: const Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withAlpha((255 * 0.1).round()),
            offset: const Offset(-4, -4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mine Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A), // Slightly lighter dark for inner chip
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/bomb.png', // Using the provided image for bomb
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  color: Colors.redAccent, // Red bomb icon
                ),
                const SizedBox(width: 8),
                Text(
                  '${_numMines - minesFlagged}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent, // Red text for mine count
                  ),
                ),
              ],
            ),
          ),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A), // Slightly lighter dark for inner chip
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedTime01, size: 24, color: Colors.lightBlueAccent), // Replaced Icon with HugeIcon
                const SizedBox(width: 8),
                Text(
                  '$timerSeconds s',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent, // Blue text for timer
                  ),
                ),
              ],
            ),
          ),
          // Cash Out Button
          if (!gameOver)
            CustomButton(
              text: 'CASH OUT',
              onPressed: _cashOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              startColor: const Color(0xFFFBC02D), // Yellow color
              endColor: const Color(0xFFF9A825), // Slightly darker yellow
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.4).round()),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white.withAlpha((255 * 0.1).round()),
                  offset: const Offset(-3, -3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
        ],
      ),
    );
  }
} // End of _MinesweeperGameScreenState class

// CustomPainter for the subtle grid background (moved to top-level)
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.05).round()) // Very subtle white lines
      ..strokeWidth = 0.5;

    // Draw horizontal lines
    for (int i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
    // Draw vertical lines
    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
