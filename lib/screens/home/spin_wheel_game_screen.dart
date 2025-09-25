import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/user_service.dart';
import 'package:rewardly_app/ad_service.dart'; // Consolidated AdService
import 'package:rewardly_app/remote_config_service.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async'; // For StreamController

class SpinWheelGameScreen extends StatefulWidget {
  const SpinWheelGameScreen({super.key});

  @override
  State<SpinWheelGameScreen> createState() => _SpinWheelGameScreenState();
}

class _SpinWheelGameScreenState extends State<SpinWheelGameScreen> {
  final UserService _userService = UserService();
  final AdService _adService = AdService(); // Use consolidated AdService
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  User? _currentUser;
  int _freeSpinsToday = 0;
  int _adSpinsWatchedToday = 0;
  int _spinWheelDailyAdLimit = 10; // Default, will be updated by RemoteConfig

  bool _isLoading = true; // Keep for initial data loading
  bool _isSpinning = false;
  String? _resultMessage;

  final StreamController<int> _fortuneWheelController = StreamController<int>();
  final List<int> _fortuneItems = [
    0, // No reward
    10,
    20,
    50,
    100,
    200,
  ];
  int _selectedItem = 0; // Index of the selected item after spin

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<User?>(context, listen: false);
    _adService.loadRewardedAd(); // Pre-load an ad
    _adService.loadInterstitialAd(); // Pre-load interstitial if needed for other features

    // Listen to user data changes
    Provider.of<UserDataProvider>(context, listen: false).addListener(_onUserDataChanged);
    _updateSpinState(); // Initial load of spin state
  }

  @override
  void dispose() {
    Provider.of<UserDataProvider>(context, listen: false).removeListener(_onUserDataChanged);
    _adService.dispose(); // Dispose all ads managed by the singleton AdService
    _fortuneWheelController.close();
    super.dispose();
  }

  void _onUserDataChanged() {
    _updateSpinState();
  }

  Future<void> _updateSpinState() async {
    if (_currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Ensure daily counts are reset if date has changed
    await _userService.resetSpinWheelDailyCounts(_currentUser!.uid);

    final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
    if (userData != null && userData.data() != null) {
      final data = userData.data() as Map<String, dynamic>;
      setState(() {
        _freeSpinsToday = data['spinWheelFreeSpinsToday'] ?? 0;
        _adSpinsWatchedToday = data['spinWheelAdSpinsToday'] ?? 0;
        _spinWheelDailyAdLimit = _remoteConfigService.spinWheelDailyAdLimit;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSpinRequest({required bool isFreeSpin}) async {
    if (_currentUser == null || _isSpinning) return;

    if (isFreeSpin && _freeSpinsToday > 0) {
      setState(() {
        _isSpinning = true;
        _resultMessage = null;
      });
      await _userService.decrementFreeSpinWheelSpins(_currentUser!.uid);
      _startSpin();
    } else if (!isFreeSpin && _adSpinsWatchedToday < _spinWheelDailyAdLimit) {
      _showRewardedAdForSpin();
    } else {
      _showResultOverlay(false, null, 'No more spins today. Come back tomorrow!');
    }
  }

  void _showRewardedAdForSpin() {
    _adService.showRewardedAd(
      onRewardEarned: (int rewardAmount) async {
        if (_currentUser != null) {
          setState(() {
            _isSpinning = true;
            _resultMessage = null;
          });
          await _userService.incrementAdSpinWheelSpins(_currentUser!.uid);
          _startSpin();
        }
      },
      onAdFailedToLoad: () {
        _showResultOverlay(false, null, 'Failed to load ad. Try again later.');
      },
      onAdFailedToShow: () {
        _showResultOverlay(false, null, 'Ad could not be shown. Try again later.');
      },
    );
  }

  void _startSpin() {
    setState(() {
      _selectedItem = Fortune.randomInt(0, _fortuneItems.length);
    });
    _fortuneWheelController.add(_selectedItem);
  }

  Future<void> _handleSpinComplete(int rewardAmount) async {
    if (_currentUser == null) return;

    await _userService.updateCoins(_currentUser!.uid, rewardAmount);

    setState(() {
      _isSpinning = false;
    });
    _showResultOverlay(true, rewardAmount);
    _updateSpinState(); // Refresh spin state after reward
  }

  void _showResultOverlay(bool success, int? reward, [String? message]) {
    setState(() {
      if (success) {
        _resultMessage = 'Congratulations! You won $reward coins!';
      } else {
        _resultMessage = message ?? 'No reward this time.';
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _resultMessage = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin & Win!'),
        backgroundColor: Colors.deepPurple.shade400,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: ShimmerLoading.rectangular(height: 50, width: 200),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FortuneWheel(
                          selected: _fortuneWheelController.stream,
                          items: [
                            for (var item in _fortuneItems)
                              FortuneItem(
                                child: Text(
                                  item == 0 ? 'Try Again' : '$item Coins',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                style: FortuneItemStyle(
                                  color: item == 0 ? Colors.redAccent.shade700 : Colors.deepPurple.shade700,
                                  borderColor: Colors.deepPurple.shade900,
                                  borderWidth: 3,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                          onAnimationEnd: () {
                            _handleSpinComplete(_fortuneItems[_selectedItem]);
                          },
                          indicators: <FortuneIndicator>[
                            FortuneIndicator(
                              alignment: Alignment.topCenter,
                              child: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.amber,
                                size: 50,
                              ),
                            ),
                          ],
                          animateFirst: false,
                          rotationCount: 8, // More rotations for a better visual effect
                          duration: const Duration(seconds: 5), // Longer spin duration
                          hapticImpact: HapticImpact.heavy,
                          physics: NoPanPhysics(), // Prevent manual scrolling
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Free Spins Today: $_freeSpinsToday',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.deepPurple.shade800, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ad Spins Today: $_adSpinsWatchedToday / $_spinWheelDailyAdLimit',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.deepPurple.shade800, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _freeSpinsToday > 0 && !_isSpinning
                                      ? () => _handleSpinRequest(isFreeSpin: true)
                                      : null,
                                  icon: const Icon(Icons.redeem, color: Colors.white),
                                  label: const Text('Free Spin', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple.shade600,
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _adSpinsWatchedToday < _spinWheelDailyAdLimit && !_isSpinning
                                      ? () => _handleSpinRequest(isFreeSpin: false)
                                      : null,
                                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                                  label: const Text('Watch Ad for Spin', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_resultMessage != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha((0.7 * 255).round()),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _resultMessage!,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _resultMessage = null;
                                });
                                _updateSpinState(); // Refresh button state
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('OK', style: TextStyle(fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_isSpinning)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha((0.5 * 255).round()),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
