import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
import 'package:provider/provider.dart';

import '../../ad_service.dart';
import '../../providers/user_data_provider.dart'; // Import UserDataProvider
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import for AdWidget
import 'dart:math';
import '../../widgets/animated_tap.dart'; // Import AnimatedTap
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

enum Player { x, o, none }
enum GameMode { easy, medium, hard }
enum GameResult { win, lose, draw, ongoing }

class TicTacToeGameScreen extends StatefulWidget {
  const TicTacToeGameScreen({super.key});

  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen>
    with TickerProviderStateMixin {
  final AdService _adService = AdService();
  late AnimationController _animationController;
  late AnimationController _backgroundAnimationController;
  late Animation<Color?> _gradientColor1;
  late Animation<Color?> _gradientColor2;
  late AnimationController _lineAnimationController;
  late ConfettiController _confettiController;
  late AnimationController _dialogAnimationController;
  late Animation<double> _dialogScaleAnimation;

  List<Player> board = List.filled(9, Player.none);
  Player currentPlayer = Player.x;
  GameMode selectedMode = GameMode.easy;
  GameResult gameResult = GameResult.ongoing;
  bool _isGameOver = false;
  bool _isLoadingAd = false;
  bool _isComputerThinking = false;
  List<int>? _winningLine;

  @override
  void initState() {
    super.initState();
    _adService.loadInterstitialAd();
    _adService.loadRewardedInterstitialAd(); // Load rewarded interstitial ad
    _adService.loadRewardedAd(); // Load rewarded ad
    _adService.loadBannerAd(); // Load banner ad
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // _animation = Tween<double>(begin: 1, end: 1.2).animate(
    //   CurvedAnimation(
    //     parent: _animationController,
    //     curve: Curves.easeInOut,
    //   ),
    // );
    // _animationController.repeat(reverse: true);

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _gradientColor1 = ColorTween(
      begin: const Color(0xFFE0F7FA), // Light Cyan
      end: const Color(0xFFB2EBF2), // Darker Cyan
    ).animate(_backgroundAnimationController);

    _gradientColor2 = ColorTween(
      begin: const Color(0xFFB2EBF2), // Darker Cyan
      end: const Color(0xFFE0F7FA), // Light Cyan
    ).animate(_backgroundAnimationController);

    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    _dialogAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _dialogScaleAnimation = CurvedAnimation(
      parent: _dialogAnimationController,
      curve: Curves.elasticOut,
    );

    _resetGame();
  }

  @override
  void dispose() {
    _adService.dispose(); // Dispose all ads
    _animationController.dispose();
    _backgroundAnimationController.dispose();
    _lineAnimationController.dispose();
    _confettiController.dispose();
    _dialogAnimationController.dispose();
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss any active snackbar
    super.dispose();
  }

  void _resetGame() {
    _lineAnimationController.reset();
    setState(() {
      board = List.filled(9, Player.none);
      currentPlayer = Player.x;
      gameResult = GameResult.ongoing;
      _isGameOver = false;
      _isLoadingAd = false;
      _winningLine = null;
    });
    if (currentPlayer == Player.o) {
      _makeComputerMove();
    }
  }

  void _onTap(int index) {
    if (board[index] == Player.none && !_isGameOver && currentPlayer == Player.x) {
      HapticFeedback.mediumImpact();
      setState(() {
        board[index] = Player.x;
        _checkGameEnd();
        if (gameResult == GameResult.ongoing) {
          currentPlayer = Player.o;
          _makeComputerMove();
        }
      });
    }
  }

  void _makeComputerMove() {
    if (_isGameOver) return;
    setState(() {
      _isComputerThinking = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      int? move;
      switch (selectedMode) {
        case GameMode.easy:
          move = _getEasyMove();
          break;
        case GameMode.medium:
          move = _getMediumMove();
          break;
        case GameMode.hard:
          move = _getHardMove();
          break;
      }

      if (move != null && mounted) {
        setState(() {
          board[move!] = Player.o;
          _checkGameEnd();
          if (gameResult == GameResult.ongoing) {
            currentPlayer = Player.x;
          }
          _isComputerThinking = false;
        });
      } else {
        setState(() {
          _isComputerThinking = false;
        });
      }
    });
  }

  int? _getEasyMove() {
    List<int> availableMoves = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == Player.none) {
        availableMoves.add(i);
      }
    }
    if (availableMoves.isNotEmpty) {
      return availableMoves[Random().nextInt(availableMoves.length)];
    }
    return null;
  }

  int? _getMediumMove() {
    // Check for winning move for O
    for (int i = 0; i < 9; i++) {
      if (board[i] == Player.none) {
        board[i] = Player.o;
        if (_checkWin(Player.o) != null) {
          board[i] = Player.none;
          return i;
        }
        board[i] = Player.none;
      }
    }

    // Check for blocking move for X
    for (int i = 0; i < 9; i++) {
      if (board[i] == Player.none) {
        board[i] = Player.x;
        if (_checkWin(Player.x) != null) {
          board[i] = Player.none;
          return i;
        }
        board[i] = Player.none;
      }
    }

    // Otherwise, make an easy move
    return _getEasyMove();
  }

  int? _getHardMove() {
    return _findBestMove(board, Player.o);
  }

  int? _findBestMove(List<Player> currentBoard, Player player) {
    int bestScore = (player == Player.o) ? -1000 : 1000;
    int? bestMove;

    for (int i = 0; i < 9; i++) {
      if (currentBoard[i] == Player.none) {
        currentBoard[i] = player;
        int score = _minimax(currentBoard, 0, false);
        currentBoard[i] = Player.none;

        if (player == Player.o) {
          if (score > bestScore) {
            bestScore = score;
            bestMove = i;
          }
        } else {
          if (score < bestScore) {
            bestScore = score;
            bestMove = i;
          }
        }
      }
    }
    return bestMove;
  }

  int _minimax(List<Player> currentBoard, int depth, bool isMaximizingPlayer) {
    if (_checkWin(Player.o) != null) return 10 - depth;
    if (_checkWin(Player.x) != null) return -10 + depth;
    if (_checkDraw(currentBoard)) return 0;

    if (isMaximizingPlayer) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (currentBoard[i] == Player.none) {
          currentBoard[i] = Player.o;
          int score = _minimax(currentBoard, depth + 1, false);
          currentBoard[i] = Player.none;
          bestScore = max(bestScore, score);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (currentBoard[i] == Player.none) {
          currentBoard[i] = Player.x;
          int score = _minimax(currentBoard, depth + 1, true);
          currentBoard[i] = Player.none;
          bestScore = min(bestScore, score);
        }
      }
      return bestScore;
    }
  }

  List<int>? _checkWin(Player player) {
    // Check rows
    for (int i = 0; i < 9; i += 3) {
      if (board[i] == player && board[i + 1] == player && board[i + 2] == player) {
        return [i, i + 2];
      }
    }
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[i] == player && board[i + 3] == player && board[i + 6] == player) {
        return [i, i + 6];
      }
    }
    // Check diagonals
    if (board[0] == player && board[4] == player && board[8] == player) {
      return [0, 8];
    }
    if (board[2] == player && board[4] == player && board[6] == player) {
      return [2, 6];
    }
    return null;
  }

  bool _checkDraw(List<Player> currentBoard) {
    for (int i = 0; i < 9; i++) {
      if (currentBoard[i] == Player.none) {
        return false;
      }
    }
    return true;
  }

  void _checkGameEnd() {
    List<int>? winningLine = _checkWin(Player.x);
    if (winningLine != null) {
      _lineAnimationController.forward();
      setState(() {
        _winningLine = winningLine;
      });
      gameResult = GameResult.win;
      _isGameOver = true;
      _confettiController.play();
      _showGameResultDialog();
    } else {
      winningLine = _checkWin(Player.o);
      if (winningLine != null) {
        _lineAnimationController.forward();
        setState(() {
          _winningLine = winningLine;
        });
        gameResult = GameResult.lose;
        _isGameOver = true;
        _showGameResultDialog();
      } else if (_checkDraw(board)) {
        gameResult = GameResult.draw;
        _isGameOver = true;
        _showGameResultDialog(); // Lottie animation will handle visual feedback
      }
    }
  }

  int _getRewardCoins() {
    if (gameResult == GameResult.win) {
      switch (selectedMode) {
        case GameMode.easy:
          return 20;
        case GameMode.medium:
          return 50;
        case GameMode.hard:
          return 100;
      }
    } else if (gameResult == GameResult.draw) {
      switch (selectedMode) {
        case GameMode.easy:
          return 5;
        case GameMode.medium:
          return 30;
        case GameMode.hard:
          return 50;
      }
    }
    return 0;
  }

  Future<void> _updateUserCoins(int coins) async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    if (coins > 0 && userDataProvider.userData?.id != null && userDataProvider.shardedUserService != null) {
      await userDataProvider.updateUserCoins(coins); // Use the provider's method
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You earned $coins coins!')),
      );
    } else {
      // Log a warning or show an error message if shardedUserService is not available
      // For now, we'll just show a snackbar.
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update coins. Please try again.')),
      );
    }
  }

  void _showGameResultDialog() {
    int rewardCoins = _getRewardCoins();
    if (gameResult == GameResult.win) {
      // For win, show dialog first, then handle ad/coins based on user choice
      _showResultDialogContent(rewardCoins);
    } else {
      // For lose/draw, update coins (if any) and then show dialog
      if (rewardCoins > 0) {
        _updateUserCoins(rewardCoins);
      }
      _showResultDialogContent(rewardCoins);
    }
  }

  void _showResultDialogContent(int rewardCoins) {
    if (!mounted) return;
    _dialogAnimationController.forward(from: 0);
    String title;
    String content;
    switch (gameResult) {
      case GameResult.win:
        title = 'You Win!';
        content = 'Congratulations! You earned $rewardCoins coins.';
        break;
      case GameResult.lose:
        title = 'You Lose!';
        content = 'Better luck next time.';
        break;
      case GameResult.draw:
        title = 'It\'s a Draw!';
        content = 'You earned $rewardCoins coins for a draw.';
        break;
      case GameResult.ongoing:
        return; // Should not happen
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
                      gameResult == GameResult.win
                          ? 'assets/lottie/win animation.json'
                          : 'assets/lottie/lose and draw.json',
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
                  if (gameResult == GameResult.win) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _adService.showRewardedInterstitialAd(
                            onAdDismissed: () {
                              _adService.loadRewardedInterstitialAd();
                              _resetGame();
                            },
                            onAdFailedToShow: () {
                              _adService.loadRewardedInterstitialAd();
                              // Do not give coins if ad failed to show
                              _resetGame();
                            },
                            onRewardEarned: (int rewardAmount) {
                              _updateUserCoins(rewardCoins); // Give coins only if reward is earned
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Claim Coins'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showRewardedAdForCoins(rewardCoins * 2);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text('Watch Ad for ${rewardCoins * 2} Coins'),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Play Again'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (gameResult == GameResult.draw)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showRewardedAdForCoins(rewardCoins * 2);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text('Watch Ad for ${rewardCoins * 2} Coins'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRewardedAdForCoins(int coinsToReward) {
    setState(() {
      _isLoadingAd = true;
    });
    _adService.showRewardedAd(
      onRewardEarned: (int rewardAmount) async {
        if(mounted) {
          setState(() {
            _isLoadingAd = false;
          });
        }
        await _updateUserCoins(coinsToReward); // Use the passed coinsToReward
        _resetGame();
      },
      onAdFailedToShow: () {
        if(mounted) {
          setState(() {
            _isLoadingAd = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to show rewarded ad. Try again.')),
          );
        }
        _resetGame();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).primaryColorDark, // Use theme's primary dark color
          elevation: 0,
          actions: [
            IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings05), // Replaced Icon with HugeIcon
              onPressed: _showDifficultySettingsDialog,
              color: Theme.of(context).primaryColorDark,
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _backgroundAnimationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_gradientColor1.value!, _gradientColor2.value!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildPlayerIndicator(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.15).round()),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20), // Add padding inside the card
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return AspectRatio(
                                      aspectRatio: 1,
                                      child: Stack(
                                        children: [
                                          GridView.count(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 8.0,
                                            mainAxisSpacing: 8.0,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            children: List.generate(9, (index) {
                                              return _buildGameCell(index, constraints);
                                            }),
                                          ),
                                          if (_winningLine != null)
                                            CustomPaint(
                                              size: Size(
                                                  constraints.maxWidth, constraints.maxHeight),
                                              painter: WinningLinePainter(
                                                winningLine: _winningLine!,
                                                animation: _lineAnimationController,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              AnimatedOpacity(
                                opacity: _isComputerThinking ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0, top: 20.0), // Added top padding
                                  child: Text(
                                    'Computer is thinking...',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColorDark),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _resetGame,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                                  ),
                                  child: const Text('START NEW GAME'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_adService.bannerAd != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: SizedBox(
                        width: _adService.bannerAd!.size.width.toDouble(),
                        height: _adService.bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _adService.bannerAd!),
                      ),
                    ),
                ],
              ),
              if (_isLoadingAd)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withAlpha((255 * 0.6).round()), // Darker overlay
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultySettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Select Difficulty',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: GameMode.values.map((mode) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMode = mode;
                        });
                        Navigator.of(context).pop();
                        _resetGame();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: selectedMode == mode
                              ? Theme.of(context).primaryColor.withAlpha((255 * 0.8).round())
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: selectedMode == mode
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: selectedMode == mode
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withAlpha((255 * 0.3).round()),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((255 * 0.05).round()),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            HugeIcon( // Replaced Icon with HugeIcon
                              icon: selectedMode == mode
                                  ? HugeIcons.strokeRoundedCheckmarkCircle01
                                  : HugeIcons.strokeRoundedCircle,
                              color: selectedMode == mode
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              mode.toString().split('.').last.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: selectedMode == mode
                                        ? Colors.white
                                        : Theme.of(context).primaryColorDark,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPlayerIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).round()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.1).round()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Player: ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentPlayer == Player.x
                  ? Colors.blue.shade700
                  : Colors.red.shade700,
              boxShadow: [
                BoxShadow(
                  color: (currentPlayer == Player.x
                          ? Colors.blue.shade700
                          : Colors.red.shade700)
                      .withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                currentPlayer == Player.x ? 'X' : 'O',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCell(int index, BoxConstraints constraints) {
    final isWinningCell = _winningLine != null &&
        (index == _winningLine![0] ||
            index == _winningLine![1] ||
            index == (_winningLine![0] + _winningLine![1]) ~/ 2 ||
            (_winningLine![0] % 3 == _winningLine![1] % 3 &&
                index % 3 == _winningLine![0] % 3 &&
                (index > _winningLine![0] && index < _winningLine![1] ||
                    index < _winningLine![0] && index > _winningLine![1])) ||
            (_winningLine![0] ~/ 3 == _winningLine![1] ~/ 3 &&
                index ~/ 3 == _winningLine![0] ~/ 3 &&
                (index > _winningLine![0] && index < _winningLine![1] ||
                    index < _winningLine![0] && index > _winningLine![1])));

    final cellSize = (constraints.maxWidth - 4.0) / 3;
    final responsiveFontSize = cellSize * 0.6;

    return AnimatedTap(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isWinningCell
              ? Colors.yellow.shade100
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: isWinningCell
                ? Colors.yellow.shade700
                : Colors.grey.shade200, // Lighter border color
            width: 2.0, // Slightly thinner border
          ),
          boxShadow: [
            BoxShadow(
              color: isWinningCell
                  ? Colors.yellow.shade400.withOpacity(0.4) // Softer yellow shadow
                  : Colors.black.withOpacity(0.05), // Softer general shadow
              blurRadius: isWinningCell ? 15 : 8, // Adjusted blur for winning/normal
              offset: isWinningCell
                  ? const Offset(0, 8) // Adjusted offset for winning
                  : const Offset(0, 4), // Adjusted offset for normal
            ),
          ],
        ),
        child: Center(
          child: AnimatedSymbol(
            player: board[index],
            isWinningCell: isWinningCell,
            fontSize: responsiveFontSize,
          ),
        ),
      ),
    );
  }
}

// Remove GridPainter as it's no longer needed
// class GridPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.deepPurple.shade200
//       ..strokeWidth = 5;

//     // Draw vertical lines
//     canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
//     canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);

//     // Draw horizontal lines
//     canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
//     canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class AnimatedSymbol extends StatefulWidget {
  final Player player;
  final bool isWinningCell;
  final double fontSize; // New parameter for responsive font size

  const AnimatedSymbol({
    super.key,
    required this.player,
    this.isWinningCell = false,
    required this.fontSize, // Make fontSize required
  });

  @override
  State<AnimatedSymbol> createState() => _AnimatedSymbolState();
}

class _AnimatedSymbolState extends State<AnimatedSymbol>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.5, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.player != Player.none) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSymbol oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != Player.none && oldWidget.player == Player.none) {
      _controller.forward(from: 0);
    } else if (widget.player == Player.none && oldWidget.player != Player.none) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(pi * _rotationAnimation.value),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Text(
              widget.player == Player.x
                  ? 'X'
                  : widget.player == Player.o
                      ? 'O'
                      : '',
              style: TextStyle(
                fontSize: widget.fontSize, // Use responsive font size
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
                color: widget.player == Player.x
                    ? Colors.blue.shade800
                    : Colors.red.shade800,
                shadows: [
                  Shadow(
                    offset: const Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: const Color.fromARGB(51, 0, 0, 0),
                  ),
                  if (widget.isWinningCell)
                    Shadow(
                      offset: const Offset(0, 0),
                      blurRadius: 25.0,
                      color: Colors.yellow.shade700,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// GridPainter class is removed as it's no longer needed.

class WinningLinePainter extends CustomPainter {
  final List<int> winningLine;
  final Animation<double> animation;

  WinningLinePainter({required this.winningLine, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.shade700 // Updated winning line color
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final startX = (winningLine[0] % 3) * (size.width / 3) + (size.width / 6);
    final startY = (winningLine[0] ~/ 3) * (size.height / 3) + (size.height / 6);
    final endX = (winningLine[1] % 3) * (size.width / 3) + (size.width / 6);
    final endY = (winningLine[1] ~/ 3) * (size.height / 3) + (size.height / 6);

    final currentEndX = startX + (endX - startX) * animation.value;
    final currentEndY = startY + (endY - startY) * animation.value;

    canvas.drawLine(Offset(startX, startY), Offset(currentEndX, currentEndY), paint);
  }

  @override
  bool shouldRepaint(covariant WinningLinePainter oldDelegate) {
    return oldDelegate.winningLine != winningLine ||
           oldDelegate.animation != animation;
  }
}
