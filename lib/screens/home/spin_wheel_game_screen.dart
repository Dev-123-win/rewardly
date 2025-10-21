import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
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
  ad, // Added ad tier for watching ads
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
    WheelReward(text: '500', coins: 500, color: Colors.amber.shade700, tier: RewardTier.platinum), // 1st 500
    WheelReward(text: '150', coins: 150, color: Colors.amber.shade700, tier: RewardTier.bronze),
    WheelReward(text: 'Watch Ad', coins: 0, color: Colors.purple.shade700, tier: RewardTier.ad), // Ad segment
    WheelReward(text: '500', coins: 500, color: Colors.amber.shade700, tier: RewardTier.platinum), // 2nd 500
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose),
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose), // Added to dilute 500 chance
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose), // Added to dilute 500 chance
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose), // Added to dilute 500 chance
    WheelReward(text: '0', coins: 0, color: Colors.blue.shade700, tier: RewardTier.lose), // Added to dilute 500 chance
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

  void _spinWheel(
    double dialogLottieSize,
    double dialogTitleFontSize,
    double dialogContentFontSize,
    EdgeInsetsGeometry dialogButtonPadding,
    double dialogButtonTextFontSize,
  ) async {
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

    final random = Random();
    _fortuneWheelSelected = random.nextInt(_rewards.length);
    _selected.add(_fortuneWheelSelected);

    // Wait for the wheel to stop spinning
    await Future.delayed(const Duration(seconds: 5)); // FortuneWheel's default duration is 5 seconds

    setState(() {
      _isSpinning = false;
      final WheelReward wonReward = _rewards[_fortuneWheelSelected];
      _handleSpinResult(
        wonReward,
        dialogLottieSize,
        dialogTitleFontSize,
        dialogContentFontSize,
        dialogButtonPadding,
        dialogButtonTextFontSize,
      );
    });
  }

  Future<void> _handleSpinResult(
    WheelReward reward,
    double dialogLottieSize,
    double dialogTitleFontSize,
    double dialogContentFontSize,
    EdgeInsetsGeometry dialogButtonPadding,
    double dialogButtonTextFontSize,
  ) async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final currentFreeSpins = userDataProvider.userData?.get('spinWheelFreeSpinsToday') ?? 0;
    final currentAdSpins = userDataProvider.userData?.get('spinWheelAdSpinsToday') ?? 0;

    if (reward.tier == RewardTier.ad) {
      // If it's an ad reward, show ad dialog and don't decrement spin yet
      _showAdRewardDialog(
        reward,
        dialogLottieSize,
        dialogTitleFontSize,
        dialogContentFontSize,
        dialogButtonPadding,
        dialogButtonTextFontSize,
      );
    } else {
      // For coin rewards, decrement spin and show win dialog
      if (currentFreeSpins > 0) {
        await userDataProvider.decrementFreeSpinWheelSpins();
      } else if (currentAdSpins > 0) {
        await userDataProvider.decrementAdSpinWheelSpins();
      }
      _showWinDialog(
        reward,
        dialogLottieSize,
        dialogTitleFontSize,
        dialogContentFontSize,
        dialogButtonPadding,
        dialogButtonTextFontSize,
      );
    }
  }

  void _showWinDialog(
    WheelReward reward,
    double dialogLottieSize,
    double dialogTitleFontSize,
    double dialogContentFontSize,
    EdgeInsetsGeometry dialogButtonPadding,
    double dialogButtonTextFontSize,
  ) {
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
                  color: Colors.black.withAlpha((255 * 0.15).round()),
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
                      width: dialogLottieSize,
                      height: dialogLottieSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ScaleTransition(
                    scale: _coinPulseAnimation,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark, fontSize: dialogTitleFontSize),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700, fontSize: dialogContentFontSize),
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
                        padding: dialogButtonPadding,
                        textStyle: TextStyle(fontSize: dialogButtonTextFontSize, fontWeight: FontWeight.bold),
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

  void _showAdRewardDialog(
    WheelReward reward,
    double dialogLottieSize,
    double dialogTitleFontSize,
    double dialogContentFontSize,
    EdgeInsetsGeometry dialogButtonPadding,
    double dialogButtonTextFontSize,
  ) {
    if (!mounted) return;

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
                  color: Colors.black.withAlpha((255 * 0.15).round()),
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
                  Lottie.asset(
                    'assets/lottie/game loading.json', // Placeholder Lottie for ad
                    width: dialogLottieSize,
                    height: dialogLottieSize,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Watch an Ad!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark, fontSize: dialogTitleFontSize),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Watch a short ad to get another spin!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700, fontSize: dialogContentFontSize),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Dismiss dialog immediately
                        setState(() {
                          _isSpinning = true; // Indicate ad loading
                        });
                        _adService.showRewardedAd(
                          onRewardEarned: (int rewardAmount) async {
                            if (mounted) {
                              setState(() {
                                _isSpinning = false;
                              });
                              // No spin decrement needed, user gets to spin again
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ad watched! Spin again!')),
                              );
                            }
                          },
                          onAdFailedToShow: () async {
                            if (mounted) {
                              setState(() {
                                _isSpinning = false;
                              });
                              // Ad failed, decrement spin
                              final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
                              final currentFreeSpins = userDataProvider.userData?.get('spinWheelFreeSpinsToday') ?? 0;
                              final currentAdSpins = userDataProvider.userData?.get('spinWheelAdSpinsToday') ?? 0;

                              if (currentFreeSpins > 0) {
                                await userDataProvider.decrementFreeSpinWheelSpins();
                              } else if (currentAdSpins > 0) {
                                await userDataProvider.decrementAdSpinWheelSpins();
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to show ad. Spin consumed.')),
                              );
                            }
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: dialogButtonPadding,
                        textStyle: TextStyle(fontSize: dialogButtonTextFontSize, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Watch Ad'),
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
          title: const Text('Lucky Spin'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;

            final verticalSpacing = isSmallScreen ? 15.0 : 20.0;
            final spinTextFontSize = isSmallScreen ? 20.0 : 24.0;
            final wheelSize = isSmallScreen ? screenWidth * 0.8 : screenWidth * 0.6;
            final buttonTextFontSize = isSmallScreen ? 18.0 : 20.0;
            final buttonIconSize = isSmallScreen ? 20.0 : 24.0;
            final fortuneItemFontSize = isSmallScreen ? 20.0 : 24.0;
            final trianglePointerWidth = isSmallScreen ? 50.0 : 60.0;
            final trianglePointerHeight = isSmallScreen ? 30.0 : 40.0;
            final dialogLottieSize = isSmallScreen ? 120.0 : 150.0;
            final dialogTitleFontSize = isSmallScreen ? 22.0 : 28.0;
            final dialogContentFontSize = isSmallScreen ? 16.0 : 18.0;
            final dialogButtonPadding = isSmallScreen ? const EdgeInsets.symmetric(vertical: 15) : const EdgeInsets.symmetric(vertical: 18);
            final dialogButtonTextFontSize = isSmallScreen ? 18.0 : 20.0;


            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE0F7FA), // Light Cyan
                    Color(0xFFBBDEFB), // Light Blue
                  ],
                ),
              ),
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
                      SizedBox(height: verticalSpacing), // Spacing from app bar
                      // Available Spins Display
                      Consumer<UserDataProvider>(
                        builder: (context, userDataProvider, child) {
                          final freeSpins = userDataProvider.userData?.get('spinWheelFreeSpinsToday') ?? 0;
                          final adSpins = userDataProvider.userData?.get('spinWheelAdSpinsToday') ?? 0;
                          final totalSpins = freeSpins + adSpins;
                          return Text(
                            'Available Spins: $totalSpins',
                            style: TextStyle(
                              fontSize: spinTextFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: verticalSpacing),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: wheelSize,
                            height: wheelSize,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((255 * 0.2).round()),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: FortuneWheel(
                                selected: _selected.stream,
                                animateFirst: false, // Prevent automatic spin on screen open
                                physics: NoPanPhysics(), // Disable manual rotation
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
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: fortuneItemFontSize,
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
                                      width: trianglePointerWidth,
                                      height: trianglePointerHeight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                              child: _GradientButton(
                                onPressed: _isSpinning
                                    ? null
                                    : () => _spinWheel(
                                          dialogLottieSize,
                                          dialogTitleFontSize,
                                          dialogContentFontSize,
                                          dialogButtonPadding,
                                          dialogButtonTextFontSize,
                                        ),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8C00), Color(0xFFFF4500)], // Orange to OrangeRed
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                child: _isSpinning
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text('Spin to Win!', style: TextStyle(fontSize: buttonTextFontSize)),
                              ),
                            ),
                            SizedBox(height: verticalSpacing * 0.5),
                            SizedBox(
                              width: double.infinity,
                              child: _GradientButton(
                                onPressed: _isSpinning ? null : _watchAdToSpin,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8A2BE2), Color(0xFF4B0082)], // BlueViolet to Indigo
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                child: _isSpinning
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Watch Ad for Spin!', style: TextStyle(fontSize: buttonTextFontSize)),
                                          SizedBox(width: verticalSpacing * 0.5),
                                          HugeIcon(icon: HugeIcons.strokeRoundedPlay, size: buttonIconSize),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
    super.key,
    required this.color,
    required this.width,
    required this.height,
  });

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
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withAlpha((255 * 0.8).round()), // Lighter shade at the top
        color, // Original color at the bottom
        color.withAlpha((255 * 0.9).round()), // Slightly darker at the very bottom
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, 0); // Top-left corner of the base
    path.lineTo(size.width, 0); // Top-right corner of the base
    path.lineTo(size.width / 2, size.height); // Apex at the bottom
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}

class _GradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.child,
    required this.gradient,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.3).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
