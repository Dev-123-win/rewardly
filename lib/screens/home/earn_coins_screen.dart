import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For Timer
import '../../ad_service.dart';
import '../../providers/user_data_provider.dart';
import '../../shared/neuromorphic_constants.dart'; // For neumorphic design
import '../../logger_service.dart'; // Import LoggerService

class EarnCoinsScreen extends StatefulWidget {
  const EarnCoinsScreen({super.key});

  @override
  State<EarnCoinsScreen> createState() => _EarnCoinsScreenState();
}

class _EarnCoinsScreenState extends State<EarnCoinsScreen> with TickerProviderStateMixin {
  final AdService _adService = AdService();
  static const int _dailyAdLimit = 10;
  static const int _coinsPerAd = 100; // Fixed coins per ad
  static const int _timerDuration = 5; // 5-second timer

  int _currentAdIndex = 0; // Tracks which ad card is currently active/unlocked
  int _adsWatchedToday = 0;
  Timer? _countdownTimer;
  int _secondsRemaining = _timerDuration;
  bool _isAdLoading = false;

  // Animation controllers for neumorphic effects and subtle animations
  late AnimationController _cardAnimationController;
  late Animation<double> _cardScaleAnimation;

  @override
  void initState() {
    super.initState();
    LoggerService.debug('EarnCoinsScreen: initState - Loading rewarded ad.');
    _adService.loadRewardedAd(); // Preload rewarded ad
    _initializeAdProgress();

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cardAnimationController.dispose();
    _adService.dispose();
    super.dispose();
  }

  Future<void> _initializeAdProgress() async {
    LoggerService.debug('EarnCoinsScreen: _initializeAdProgress called.');
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    await userDataProvider.resetDailyAdWatchCount(); // Reset if new day

    setState(() {
      _adsWatchedToday = userDataProvider.userData?.get('adsWatchedToday') ?? 0;
      _currentAdIndex = _adsWatchedToday; // Start from the next ad to watch
    });
    
    if (_currentAdIndex < _dailyAdLimit) {
      _startCountdownTimer(); // Start timer for the first available ad
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel(); // Cancel any existing timer
    _secondsRemaining = _timerDuration;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _watchAd(int adIndex) async {
    LoggerService.debug('EarnCoinsScreen: _watchAd called for adIndex: $adIndex. Current adIndex: $_currentAdIndex, secondsRemaining: $_secondsRemaining, adsWatchedToday: $_adsWatchedToday');
    if (_isAdLoading || adIndex != _currentAdIndex || _secondsRemaining > 0 || _adsWatchedToday >= _dailyAdLimit) {
      return; // Prevent multiple ad loads, wrong index, or if timer is active/limit reached
    }

    setState(() {
      _isAdLoading = true;
    });
    LoggerService.debug('EarnCoinsScreen: _watchAd - Calling _adService.showRewardedAd().');

    _adService.showRewardedAd(
      onRewardEarned: (int rewardAmount) async {
        if (!mounted) return;
        setState(() {
          _isAdLoading = false;
          _adsWatchedToday++;
          _currentAdIndex++;
        });
        
        final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
        await userDataProvider.updateUserCoins(_coinsPerAd); // Award fixed coins
        await userDataProvider.updateAdsWatchedToday(); // Increment ad count in Firestore

        if (!mounted) return; // Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You earned $_coinsPerAd coins!')),
        );

        if (_currentAdIndex < _dailyAdLimit) {
          _startCountdownTimer(); // Start timer for the next ad
        } else {
          _countdownTimer?.cancel(); // All ads watched
        }
      },
      onAdFailedToShow: () {
        LoggerService.error('EarnCoinsScreen: _watchAd - Ad failed to show.');
        if (!mounted) return;
        setState(() {
          _isAdLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to show rewarded ad. Try again.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor, // Use neumorphic background color
        appBar: AppBar(
        title: const Text('Watch & Earn Coins'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextColor,
      ),
      body: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, child) {
          _adsWatchedToday = userDataProvider.userData?.get('adsWatchedToday') ?? 0;
          _currentAdIndex = _adsWatchedToday; // Ensure currentAdIndex is always in sync

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(kDefaultPadding),
                itemCount: _dailyAdLimit,
                itemBuilder: (context, index) {
                  final bool isUnlocked = index == _currentAdIndex && _adsWatchedToday < _dailyAdLimit;
                  final bool isWatched = index < _adsWatchedToday;
                  final bool isLocked = index > _currentAdIndex || _adsWatchedToday >= _dailyAdLimit;

                  return _buildAdCard(
                    context,
                    index + 1,
                    isUnlocked: isUnlocked,
                    isWatched: isWatched,
                    isLocked: isLocked,
                  );
                },
              ),
              if (_isAdLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withAlpha((255 * 0.6).round()), // Fix deprecated withOpacity
                    child: const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildAdCard(
    BuildContext context,
    int adNumber, {
    required bool isUnlocked,
    required bool isWatched,
    required bool isLocked,
  }) {
    Function()? onPressed;
    Color cardColor = kSurfaceColor;
    List<BoxShadow> boxShadow = kNeumorphicShadows;
    IconData icon = Icons.lock;
    Color iconColor = kDisabledColor;
    String statusText = 'Locked';

    if (isWatched) {
      cardColor = kPrimaryColor.withAlpha((255 * 0.2).round()); // Fix deprecated withOpacity
      boxShadow = kNeumorphicPressedShadows;
      icon = Icons.check_circle;
      iconColor = kPrimaryColor;
      statusText = 'Watched';
      onPressed = null;
    } else if (isUnlocked) {
      cardColor = kSurfaceColor;
      boxShadow = kNeumorphicShadows;
      icon = Icons.play_circle_fill;
      iconColor = kAccentColor;
      statusText = 'Watch Ad';
      onPressed = _secondsRemaining == 0 ? () => _watchAd(adNumber - 1) : null;
    } else if (isLocked) {
      cardColor = kSurfaceColor.withAlpha((255 * 0.5).round()); // Fix deprecated withOpacity
      boxShadow = kNeumorphicShadows;
      icon = Icons.lock;
      iconColor = kDisabledColor;
      statusText = 'Locked';
      onPressed = null;
    }

    if (isUnlocked && _secondsRemaining > 0) {
      statusText = 'Waiting... $_secondsRemaining s';
      icon = Icons.timer;
      iconColor = kAccentColor;
    }

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
        padding: const EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
          boxShadow: boxShadow,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earn $_coinsPerAd Coins',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: kTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: iconColor,
                        ),
                  ),
                ],
              ),
            ),
            if (isUnlocked && _secondsRemaining == 0)
              ScaleTransition(
                scale: _cardScaleAnimation,
                child: Icon(Icons.arrow_forward_ios, color: kAccentColor),
              ),
          ],
        ),
      ),
    );
  }
}
