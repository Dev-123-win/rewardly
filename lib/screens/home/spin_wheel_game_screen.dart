import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Import for StreamController
import 'dart:math';

import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart'; // Import flutter_fortune_wheel
import '../../ad_service.dart';
import '../../providers/user_data_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

// Enum for different reward tiers
enum RewardTier {
  none,
  bronze,
  silver,
  gold,
  platinum,
  lose, // Added lose tier
}

// Class to define a single wheel reward segment
class WheelReward {
  final String text;
  final int coins;
  final Color color;
  final RewardTier tier;

  WheelReward({
    required this.text,
    required this.coins,
    required this.color,
    required this.tier,
  });
}

class SpinWheelGameScreen extends StatefulWidget {
  const SpinWheelGameScreen({super.key});

  @override
  State<SpinWheelGameScreen> createState() => _SpinWheelGameScreenState();
}

class _SpinWheelGameScreenState extends State<SpinWheelGameScreen>
    with TickerProviderStateMixin {
  final AdService _adService = AdService();
  late ConfettiController _confettiController;
  late AnimationController _coinPulseController;
  late Animation<double> _coinPulseAnimation;

  final StreamController<int> _selected = StreamController<int>();
  int _fortuneWheelSelected = 0;
  bool _isSpinning = false;

  // Define the rewards for the wheel
  final List<WheelReward> _rewards = [
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose),
    WheelReward(text: '100', coins: 100, color: Colors.amber.shade700, tier: RewardTier.silver),
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose),
    WheelReward(text: '200', coins: 200, color: Colors.amber.shade700, tier: RewardTier.gold),
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose),
    WheelReward(text: '150', coins: 150, color: Colors.amber.shade700, tier: RewardTier.bronze),
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose),
    WheelReward(text: '500', coins: 500, color: Colors.amber.shade700, tier: RewardTier.platinum),
  ];

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd(); // Preload rewarded ad
    _initializeSpinData(); // Initialize spin data from UserDataProvider

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _coinPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _coinPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _coinPulseController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _coinPulseController.dispose();
    _adService.dispose();
    _selected.close(); // Close the stream controller
    super.dispose();
  }

  Future<void> _initializeSpinData() async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    await userDataProvider.resetSpinWheelDailyCounts(); // Reset daily counts if date changed
  }

  void _spinWheel() async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final currentFreeSpins = userDataProvider.userData?.get('spinWheelFreeSpinsToday') ?? 0;
    final currentAdSpins = userDataProvider.userData?.get('spinWheelAdSpinsToday') ?? 0;

    if (_isSpinning || (currentFreeSpins == 0 && currentAdSpins == 0)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No spins left! Watch an ad or wait for free spins.')),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    HapticFeedback.lightImpact();

    if (currentFreeSpins > 0) {
      await userDataProvider.decrementFreeSpinWheelSpins();
    } else if (currentAdSpins > 0) {
      await userDataProvider.decrementAdSpinWheelSpins();
    }

    final random = Random();
    _fortuneWheelSelected = random.nextInt(_rewards.length);
    _selected.add(_fortuneWheelSelected);

    // Wait for the wheel to stop spinning
    await Future.delayed(const Duration(seconds: 5)); // FortuneWheel's default duration is 5 seconds

    setState(() {
      _isSpinning = false;
      final WheelReward wonReward = _rewards[_fortuneWheelSelected];
      _showWinDialog(wonReward);
    });
  }

  void _showWinDialog(WheelReward reward) {
    if (!mounted) return;

    if (reward.coins > 0) {
      _updateUserCoins(reward.coins);
      _confettiController.play();
      _coinPulseController.forward(from: 0).whenComplete(() => _coinPulseController.reverse());
    }
    if (!mounted) return;

    String title;
    String content;
    String lottieAsset;

    if (reward.coins > 0) {
      title = 'Congratulations!';
      content = 'You won ${reward.coins} coins!';
      lottieAsset = 'assets/lottie/win animation.json';
    } else {
      title = 'Better luck next time!';
      content = 'You landed on "0" coins.';
      lottieAsset = 'assets/lottie/lose and draw.json';
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
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
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ScaleTransition(
                    scale: _coinPulseAnimation,
                    child: Lottie.asset(
                      lottieAsset,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ScaleTransition(
                    scale: _coinPulseAnimation,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Spin Again'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateUserCoins(int coins) async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    if (coins > 0 && userDataProvider.userData?.id != null && userDataProvider.shardedUserService != null) {
      await userDataProvider.updateUserCoins(coins);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You earned $coins coins!')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update coins. Please try again.')),
      );
    }
  }

  void _watchAdToSpin() {
    setState(() {
      _isSpinning = true; // Indicate ad loading
    });
    _adService.showRewardedAd(
      onRewardEarned: (int rewardAmount) async {
        if (mounted) {
          setState(() {
            _isSpinning = false;
          });
          final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
          // Check if user has earned less than 10 ad spins today
          if (userDataProvider.adSpinsEarnedToday < 10) {
            await userDataProvider.incrementAdSpinWheelSpins(2); // Grant 2 spins
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You earned 2 spins!')),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You have reached the daily limit for ad spins (10 ads).')),
            );
          }
        }
      },
      onAdFailedToLoad: () {
        if (mounted) {
          setState(() {
            _isSpinning = false;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load rewarded ad. Try again.')),
          );
        }
      },
      onAdFailedToShow: () {
        if (mounted) {
          setState(() {
            _isSpinning = false;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to show rewarded ad. Try again.')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spin and Win'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer<UserDataProvider>(
                builder: (context, userDataProvider, child) {
                  return _buildInfoChip(context, Icons.monetization_on, 'Coins: ${userDataProvider.userData?.get('coins') ?? 0}', _coinPulseAnimation);
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Particle Background (keeping for visual effect if desired)
            // AnimatedBuilder(
            //   animation: _particleAnimation,
            //   builder: (context, child) {
            //     return CustomPaint(
            //       painter: ParticleBackgroundPainter(animation: _particleAnimation),
            //       child: Container(),
            //     );
            //   },
            // ),
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
                const SizedBox(height: 20), // Spacing from app bar
                // Available Spins Display
                Consumer<UserDataProvider>(
                  builder: (context, userDataProvider, child) {
                    final freeSpins = userDataProvider.userData?.get('spinWheelFreeSpinsToday') ?? 0;
                    final adSpins = userDataProvider.userData?.get('spinWheelAdSpinsToday') ?? 0;
                    final totalSpins = freeSpins + adSpins;
                    return Text(
                      'Available Spins: $totalSpins',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: FortuneWheel(
                      selected: _selected.stream,
                      items: [
                        for (var reward in _rewards)
                          FortuneItem(
                            style: FortuneItemStyle(
                              color: reward.color,
                              borderColor: Colors.white,
                              borderWidth: 3,
                              textAlign: TextAlign.center,
                            ),
                            child: Text(
                              reward.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                      ],
                      onAnimationEnd: () {
                        // This callback is triggered when the wheel animation ends.
                        // The win dialog is already handled in _spinWheel after a delay.
                      },
                      indicators: <FortuneIndicator>[
                        FortuneIndicator(
                          alignment: Alignment.topCenter, // Aligns the indicator to the top of the wheel
                          child: TrianglePointer(
                            color: Colors.red,
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSpinning ? null : _spinWheel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSpinning
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Spin'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSpinning ? null : _watchAdToSpin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSpinning
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Ad Watching Button'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text, [Animation<double>? animation]) {
    return ScaleTransition(
      scale: animation ?? const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25.0),
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
      ),
    );
  }
}

class TrianglePointer extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const TrianglePointer({
    Key? key,
    required this.color,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _TrianglePainter(color),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}
