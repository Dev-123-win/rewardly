import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../user_service.dart';
import '../../ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import for AdWidget
import 'dart:math';
import '../../widgets/animated_tap.dart'; // Import AnimatedTap

enum Player { x, o, none }
enum GameMode { easy, medium, hard }
enum GameResult { win, lose, draw, ongoing }

class TicTacToeGameScreen extends StatefulWidget {
  const TicTacToeGameScreen({super.key});

  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen> {
  final UserService _userService = UserService();
  final AdService _adService = AdService();
  User? _currentUser;

  List<Player> board = List.filled(9, Player.none);
  Player currentPlayer = Player.x;
  GameMode selectedMode = GameMode.easy;
  GameResult gameResult = GameResult.ongoing;
  bool _isGameOver = false;
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<User?>(context, listen: false);
    _adService.loadInterstitialAd();
    _adService.loadBannerAd(); // Load banner ad
    _resetGame();
  }

  @override
  void dispose() {
    _adService.dispose(); // Dispose all ads
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, Player.none);
      currentPlayer = Player.x;
      gameResult = GameResult.ongoing;
      _isGameOver = false;
      _isLoadingAd = false;
    });
    if (currentPlayer == Player.o) {
      _makeComputerMove();
    }
  }

  void _onTap(int index) {
    if (board[index] == Player.none && !_isGameOver && currentPlayer == Player.x) {
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
        if (_checkWin(Player.o)) {
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
        if (_checkWin(Player.x)) {
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
    if (_checkWin(Player.o)) return 10 - depth;
    if (_checkWin(Player.x)) return -10 + depth;
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

  bool _checkWin(Player player) {
    // Check rows
    for (int i = 0; i < 9; i += 3) {
      if (board[i] == player && board[i + 1] == player && board[i + 2] == player) return true;
    }
    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[i] == player && board[i + 3] == player && board[i + 6] == player) return true;
    }
    // Check diagonals
    if (board[0] == player && board[4] == player && board[8] == player) return true;
    if (board[2] == player && board[4] == player && board[6] == player) return true;
    return false;
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
    if (_checkWin(Player.x)) {
      gameResult = GameResult.win;
      _isGameOver = true;
      _showGameResultDialog();
    } else if (_checkWin(Player.o)) {
      gameResult = GameResult.lose;
      _isGameOver = true;
      _showGameResultDialog();
    } else if (_checkDraw(board)) {
      gameResult = GameResult.draw;
      _isGameOver = true;
      _showGameResultDialog();
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
    if (_currentUser != null && coins > 0) {
      await _userService.updateCoins(_currentUser!.uid, coins);
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You earned $coins coins!')),
      );
    }
  }

  void _showGameResultDialog() {
    int rewardCoins = _getRewardCoins();
    if (rewardCoins > 0) {
      _updateUserCoins(rewardCoins);
    }

    _adService.showInterstitialAd(
      onAdDismissed: () {
        _adService.loadInterstitialAd(); // Preload next ad
        _showResultDialogContent(rewardCoins);
      },
      onAdFailedToShow: () {
        _adService.loadInterstitialAd(); // Preload next ad
        _showResultDialogContent(rewardCoins);
      },
    );
  }

  void _showResultDialogContent(int rewardCoins) {
    if(!mounted) return;
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _resetGame();
              },
              child: const Text('Play Again'),
            ),
            if (gameResult != GameResult.win && gameResult != GameResult.draw)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _showRewardedAdForCoins();
                },
                child: const Text('Watch Ad for +X Coins'),
              ),
          ],
        );
      },
    );
  }

  void _showRewardedAdForCoins() {
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
        await _updateUserCoins(rewardAmount); // Reward amount from AdService
        _resetGame();
      },
      onAdFailedToLoad: () {
        if(mounted) {
          setState(() {
            _isLoadingAd = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load rewarded ad. Try again.')),
          );
        }
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
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50, // Themed background
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0), // Increased padding
                child: Column(
                  children: [
                    // Current Player Indicator
                    _buildPlayerIndicator(context),
                    const SizedBox(height: 20),
                    // Difficulty Selector
                    _buildDifficultySelector(context),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20.0), // Increased padding
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15.0, // Increased spacing
                    mainAxisSpacing: 15.0, // Increased spacing
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return _buildGameCell(index);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0), // Increased padding
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh, size: 24),
                  label: const Text('Reset Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
              // Banner Ad Placeholder
              if (_adService.bannerAd != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10), // Add some margin
                  width: _adService.bannerAd!.size.width.toDouble(),
                  height: _adService.bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _adService.bannerAd!),
                ),
            ],
          ),
          if (_isLoadingAd)
            Positioned.fill(
              child: Container(
                color: Color.fromARGB((255 * 0.6).round(), 0, 0, 0), // Darker overlay
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerIndicator(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Player: ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            Text(
              currentPlayer == Player.x ? 'X (You)' : 'O (NPC)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: currentPlayer == Player.x ? Theme.of(context).primaryColor : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Difficulty:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
            ),
            DropdownButton<GameMode>(
              value: selectedMode,
              onChanged: (GameMode? newValue) {
                setState(() {
                  selectedMode = newValue!;
                  _resetGame();
                });
              },
              items: const [
                DropdownMenuItem(value: GameMode.easy, child: Text('Easy')),
                DropdownMenuItem(value: GameMode.medium, child: Text('Medium')),
                DropdownMenuItem(value: GameMode.hard, child: Text('Hard')),
              ],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              underline: Container(), // Remove underline
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCell(int index) {
    return AnimatedTap(
      onTap: () => _onTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Solid white background for cells
          borderRadius: BorderRadius.circular(15.0), // More rounded corners
          border: Border.all(color: Colors.grey.shade300, width: 2.0), // Subtle border
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB((255 * 0.05).round(), 0, 0, 0),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            board[index] == Player.x
                ? 'X'
                : board[index] == Player.o
                    ? 'O'
                    : '',
            style: TextStyle(
              fontSize: 70, // Larger font size
              fontWeight: FontWeight.w900, // Bolder weight
              fontFamily: 'Poppins', // Use a professional font
              color: board[index] == Player.x ? Theme.of(context).primaryColor : Colors.redAccent,
              shadows: [
                Shadow(
                  offset: const Offset(2.0, 2.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB((255 * 0.2).round(), 0, 0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
