import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';

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
  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _particleController;
  late Animation<double> _particleAnimation;
  late ConfettiController _confettiController;
  late AnimationController _coinPulseController;
  late Animation<double> _coinPulseAnimation;

  double _currentRotation = 0.0;
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

    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _wheelAnimation = CurvedAnimation(
      parent: _wheelController,
      curve: Curves.easeOutExpo,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_glowController);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_particleController);

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
    _wheelController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _confettiController.dispose();
    _coinPulseController.dispose();
    _adService.dispose();
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
      if (!mounted) return; // Check mounted before using context
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
    final double randomAngle = random.nextDouble() * (2 * pi); // Random angle for a full rotation
    final double targetAngle = (2 * pi * 5) + randomAngle; // Spin 5 full rotations + random angle

    _wheelController.reset();
    _wheelAnimation = Tween<double>(
      begin: _currentRotation,
      end: targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _wheelController,
        curve: Curves.easeOutExpo,
      ),
    );

    _wheelController.forward().whenComplete(() {
      setState(() {
        _isSpinning = false;
        _currentRotation = targetAngle % (2 * pi); // Keep rotation within 0-2pi

        // Determine the winning segment
        final double segmentAngle = (2 * pi) / _rewards.length;
        // The pointer is at the top, which corresponds to an angle of 3*pi/2 (270 degrees) in Flutter's canvas (0 is right, clockwise positive).
        // We need to find which segment is under this pointer.
        // The wheel rotates clockwise, so we need to adjust the current rotation relative to the pointer.
        // We want to find the segment that is "under" the pointer.
        // The segments are drawn starting from angle 0 (right) and going clockwise.
        // If the wheel has rotated by _currentRotation, then the segment that was originally at angle `(3*pi/2 - _currentRotation)`
        // (modulo 2*pi) is now under the pointer.
        double pointerAngle = (3 * pi / 2); // Pointer is at the top (270 degrees)
        double adjustedRotation = (_currentRotation + pointerAngle) % (2 * pi);

        // Calculate the index. The segments are ordered clockwise starting from the right.
        // We need to reverse the order for the visual representation to match the logical index.
        // The first segment (index 0) is drawn from 0 to segmentAngle.
        // If the pointer is at the top, it's pointing at the segment whose start angle is just before 3*pi/2.
        // The segments are drawn starting from index 0 at the right, then 1, 2, etc., clockwise.
        // To get the correct index, we need to consider the angle from the "top" position.
        // The angle from the top (3*pi/2) to the start of the first segment (0) is pi/2.
        // So, we need to shift the angle by pi/2 to align the "top" with the start of the first segment.
        double normalizedWinningAngle = (adjustedRotation + pi / 2) % (2 * pi);
        int winningIndex = (_rewards.length - 1) - (normalizedWinningAngle / segmentAngle).floor();
        winningIndex = winningIndex % _rewards.length; // Ensure index is within bounds

        final WheelReward wonReward = _rewards[winningIndex];

        _showWinDialog(wonReward);
      });
    });
  }

  void _showWinDialog(WheelReward reward) {
    if (!mounted) return;

    if (reward.coins > 0) {
      _updateUserCoins(reward.coins);
      _confettiController.play();
      _coinPulseController.forward(from: 0).whenComplete(() => _coinPulseController.reverse());
    }
    if (!mounted) return; // Check mounted before using context

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
                    scale: _coinPulseAnimation,
                    child: Lottie.asset(
                      lottieAsset,
                      width: 150, // Adjust size as needed
                      height: 150, // Adjust size as needed
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 25), // Increased spacing
                  ScaleTransition(
                    scale: _coinPulseAnimation,
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
                  SizedBox(
                    width: double.infinity, // Full width button
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Optionally reset game state or just allow another spin
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor, // Use primary color for button
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18), // Larger padding
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded button
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
      if (!mounted) return; // Check mounted before using context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You earned $coins coins!')),
      );
    } else {
      if (!mounted) return; // Check mounted before using context
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
            if (!mounted) return; // Check mounted before using context
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You earned 2 spins!')),
            );
          } else {
            if (!mounted) return; // Check mounted before using context
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
          if (!mounted) return; // Check mounted before using context
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
          if (!mounted) return; // Check mounted before using context
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
          title: const Text('Spin the Wheel'),
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
            // Particle Background
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticleBackgroundPainter(animation: _particleAnimation),
                  child: Container(),
                );
              },
            ),
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
                // Spin Counter
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<UserDataProvider>(
                    builder: (context, userDataProvider, child) {
                      final freeSpins = userDataProvider.userData?.get('spinWheelFreeSpinsToday') ?? 0;
                      final adSpins = userDataProvider.userData?.get('spinWheelAdSpinsToday') ?? 0;
                      final adsWatchedToday = userDataProvider.adSpinsEarnedToday; // Get ads watched today
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoChip(context, Icons.refresh, 'Free Spins: $freeSpins'),
                          _buildInfoChip(context, Icons.videocam, 'Ad Spins: $adSpins ($adsWatchedToday/10 ads)'), // Display ads watched
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Spin Wheel
                        AnimatedBuilder(
                          animation: _wheelAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _wheelAnimation.value,
                              child: CustomPaint(
                                size: const Size(300, 300),
                                painter: SpinWheelPainter(rewards: _rewards, glowAnimation: _glowAnimation),
                              ),
                            );
                          },
                        ),
                      // Wheel Pointer
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: WheelPointerPainter(),
                      ),
                      // Central "SPIN" text
                      GestureDetector(
                        onTap: _isSpinning ? null : _spinWheel,
                        child: Container(
                          width: 100, // Size of the tappable area
                          height: 100,
                          alignment: Alignment.center,
                          child: Text(
                            'SPIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
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
                    ElevatedButton(
                      onPressed: _isSpinning ? null : _spinWheel,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      child: _isSpinning
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Spin for Free'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isSpinning ? null : _watchAdToSpin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      child: _isSpinning
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Watch Ad to Spin (2 Spins)'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text, [Animation<double>? animation]) {
    return ScaleTransition(
      scale: animation ?? const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25.0),
          // Removed boxShadow for no elevation
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

// Custom Painters (to be implemented in Phase 2)
class SpinWheelPainter extends CustomPainter {
  final List<WheelReward> rewards;
  final Animation<double> glowAnimation;

  SpinWheelPainter({required this.rewards, required this.glowAnimation}) : super(repaint: glowAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = (2 * pi) / rewards.length;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = i * segmentAngle;

      final paint = Paint()..color = rewards[i].color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, segmentAngle, true, paint);

      // Draw text
      final textPainter = TextPainter(
        text: TextSpan(
          text: rewards[i].text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20, // Slightly smaller font size
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Position text radially, closer to the center
      final textRadius = radius * 0.6; // Adjust text position
      final textAngle = startAngle + segmentAngle / 2;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2); // Rotate text to align with segment
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Draw outer border
    final outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0; // Thicker border
    canvas.drawCircle(center, radius, outerBorderPaint);

    // Draw inner black circle
    final innerCirclePaint = Paint()..color = Colors.black;
    final innerRadius = radius * 0.4; // Adjust size of inner circle
    canvas.drawCircle(center, innerRadius, innerCirclePaint);

    // Draw inner white border for the black circle
    final innerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, innerRadius, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant SpinWheelPainter oldDelegate) {
    return oldDelegate.rewards != rewards || oldDelegate.glowAnimation != glowAnimation;
  }
}

class ParticleBackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  ParticleBackgroundPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(0); // Use a fixed seed for consistent particles
    final particleCount = 50;
    final particlePaint = Paint()..color = Colors.white.withAlpha((0.3 * 255).round());

    for (int i = 0; i < particleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animation.value * size.height) % size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // This painter is not directly used for confetti, as confetti_widget handles it.
    // It's a placeholder if custom confetti drawing was needed.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WheelPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red; // Changed color to red
    final path = Path();

    // Triangle pointing downwards at the top of the wheel
    path.moveTo(size.width / 2, 0); // Top center
    path.lineTo(size.width / 2 - 20, 40); // Bottom-left point
    path.lineTo(size.width / 2 + 20, 40); // Bottom-right point
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
