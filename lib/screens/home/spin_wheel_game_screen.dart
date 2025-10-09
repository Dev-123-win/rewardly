import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../ad_service.dart';
import '../../providers/user_data_provider.dart';
import 'package:confetti/confetti.dart';

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
    WheelReward(text: '0', coins: 0, color: Colors.grey.shade700, tier: RewardTier.lose),
    WheelReward(text: '50', coins: 50, color: Colors.blue.shade700, tier: RewardTier.bronze),
    WheelReward(text: '0', coins: 0, color: Colors.grey.shade700, tier: RewardTier.lose),
    WheelReward(text: '100', coins: 100, color: Colors.green.shade700, tier: RewardTier.silver),
    WheelReward(text: '0', coins: 0, color: Colors.grey.shade700, tier: RewardTier.lose),
    WheelReward(text: '200', coins: 200, color: Colors.purple.shade700, tier: RewardTier.gold),
    WheelReward(text: '0', coins: 0, color: Colors.grey.shade700, tier: RewardTier.lose),
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
        final double normalizedRotation = (2 * pi - _currentRotation) % (2 * pi); // Normalize to 0-2pi clockwise
        final int winningIndex = (normalizedRotation / segmentAngle).floor();
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

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (BuildContext context) {
        return WinDialog(
          reward: reward,
          onPlayAgain: () {
            Navigator.of(context).pop();
            // Optionally reset game state or just allow another spin
          },
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
              // Coin Display and Spin Counter
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
                        _buildInfoChip(context, Icons.monetization_on, 'Coins: ${userDataProvider.userData?.get('coins') ?? 0}', _coinPulseAnimation),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Position text radially
      final textRadius = radius * 0.7; // Adjust text position
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

    // Draw glow effect
    final glowPaint = Paint()
      ..color = Colors.yellow.withAlpha((0.5 * glowAnimation.value * 255).round())
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowAnimation.value * 15);
    canvas.drawCircle(center, radius, glowPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(center, radius, borderPaint);
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
    final paint = Paint()..color = Colors.red.shade800;
    final path = Path();

    // Triangle pointing upwards
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width / 2 - 15, size.height - 30);
    path.lineTo(size.width / 2 + 15, size.height - 30);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WinDialog extends StatelessWidget {
  final WheelReward reward;
  final VoidCallback onPlayAgain;

  const WinDialog({
    super.key,
    required this.reward,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String content;
    IconData icon;
    Color iconColor;

    if (reward.coins > 0) {
      title = 'Congratulations!';
      content = 'You won ${reward.coins} coins!';
      icon = Icons.celebration;
      iconColor = Colors.amber;
    } else {
      title = 'Better luck next time!';
      content = 'You landed on "0" coins.';
      icon = Icons.sentiment_dissatisfied;
      iconColor = Colors.grey;
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 60),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                content,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onPlayAgain,
                child: const Text('Spin Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
