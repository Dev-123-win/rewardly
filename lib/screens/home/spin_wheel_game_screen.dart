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
import 'package:rewardly_app/theme_provider.dart';
import 'dart:developer' as developer;
import 'package:google_mobile_ads/google_mobile_ads.dart' as ads; // Import for AdWidget with alias

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
  ThemeProvider? _themeProvider;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  @override
  void dispose() {
    Provider.of<UserDataProvider>(context, listen: false).removeListener(_onUserDataChanged);
    _adService.dispose(); // Dispose all ads managed by the singleton AdService
    _fortuneWheelController.close();
    developer.log('ThemeProvider in dispose: $_themeProvider');
    super.dispose();
  }

  void _onUserDataChanged() {
    _updateSpinState();
  }

  Future<void> _updateSpinState() async {
    if (_currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    // Ensure daily counts are reset if date has changed
    await _userService.resetSpinWheelDailyCounts(_currentUser!.uid);

    if (!mounted) return;

    final userData = userDataProvider.userData;
    if (userData != null && userData.data() != null) {
      final data = userData.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _freeSpinsToday = data['spinWheelFreeSpinsToday'] ?? 0;
          _adSpinsWatchedToday = data['spinWheelAdSpinsToday'] ?? 0;
          _spinWheelDailyAdLimit = _remoteConfigService.spinWheelDailyAdLimit;
          _isLoading = false;
        });
      }
    } else {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSpinRequest({required bool isFreeSpin}) async {
    if (_currentUser == null || _isSpinning) return;

    if (isFreeSpin && _freeSpinsToday > 0) {
      if (mounted) {
        setState(() {
          _isSpinning = true;
          _resultMessage = null;
        });
      }
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
          if (mounted) {
            setState(() {
              _isSpinning = true;
              _resultMessage = null;
            });
          }
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
    if (mounted) {
      setState(() {
        _selectedItem = Fortune.randomInt(0, _fortuneItems.length);
      });
    }
    _fortuneWheelController.add(_selectedItem);
  }

  Future<void> _handleSpinComplete(int rewardAmount) async {
    if (_currentUser == null) return;

    await _userService.updateCoins(_currentUser!.uid, rewardAmount);
    
    if(!mounted) return;

    if (mounted) {
      setState(() {
        _isSpinning = false;
      });
    }
    _showResultOverlay(true, rewardAmount);
    _updateSpinState(); // Refresh spin state after reward
  }

  void _showResultOverlay(bool success, int? reward, [String? message]) {
    if(!mounted) return;
    if (mounted) {
      setState(() {
        if (success) {
          _resultMessage = 'Congratulations! You won $reward coins!';
        } else {
          _resultMessage = message ?? 'No reward this time.';
        }
      });
    }
    Future.delayed(const Duration(seconds: 3), () {
      if(mounted) {
        setState(() {
          _resultMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()), // Themed background
      appBar: AppBar(
        title: const Text('Spin & Win!'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: ShimmerLoading.rectangular(height: 50, width: 200),
            )
          : Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    // Spin Count Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSpinCountCard(
                              context,
                              label: 'Free Spins',
                              count: _freeSpinsToday,
                              icon: Icons.redeem,
                              color: Colors.deepPurple.shade600,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildSpinCountCard(
                              context,
                              label: 'Ad Spins',
                              count: _adSpinsWatchedToday,
                              limit: _spinWheelDailyAdLimit,
                              icon: Icons.videocam,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FortuneWheel(
                          selected: _fortuneWheelController.stream,
                          items: [
                            for (var item in _fortuneItems)
                              FortuneItem(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (item != 0) Image.asset('assets/coin.png', height: 24, width: 24),
                                    const SizedBox(width: 5),
                                    Text(
                                      item == 0 ? 'Try Again' : '$item Coins',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                style: FortuneItemStyle(
                                  color: item == 0 ? Colors.redAccent.shade700 : Theme.of(context).primaryColor, // Themed colors
                                  borderColor: Color.fromARGB((255 * 0.5).round(), 255, 255, 255),
                                  borderWidth: 2,
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
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB((255 * 0.2).round(), 0, 0, 0),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                          animateFirst: false,
                          rotationCount: 10, // More rotations for a better visual effect
                          duration: const Duration(seconds: 7), // Longer spin duration
                          hapticImpact: HapticImpact.heavy,
                          physics: NoPanPhysics(), // Prevent manual scrolling
                          // Add a central widget to the wheel
                          // centerWidget: Image.asset('assets/AppLogo.png', height: 80, width: 80),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _freeSpinsToday > 0 && !_isSpinning
                                  ? () => _handleSpinRequest(isFreeSpin: true)
                                  : null,
                              icon: const Icon(Icons.redeem, color: Colors.white),
                              label: const Text('Free Spin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.shade600,
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                              label: const Text('Watch Ad for Spin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Banner Ad Placeholder
                    if (_adService.bannerAd != null)
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 10), // Add some margin
                        width: _adService.bannerAd!.size.width.toDouble(),
                        height: _adService.bannerAd!.size.height.toDouble(),
                        child: ads.AdWidget(ad: _adService.bannerAd!),
                      ),
                  ],
                ),
                if (_resultMessage != null)
                  Positioned.fill(
                    child: Container(
                      color: Color.fromARGB((255 * 0.8).round(), 0, 0, 0), // Darker overlay
                      child: Center(
                        child: Card(
                          margin: const EdgeInsets.all(30),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _resultMessage!.contains('Congratulations') ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                                  color: _resultMessage!.contains('Congratulations') ? Colors.amber.shade700 : Colors.grey,
                                  size: 60,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _resultMessage!,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    if (mounted) {
                                      setState(() {
                                        _resultMessage = null;
                                      });
                                    }
                                    _updateSpinState(); // Refresh button state
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 5,
                                  ),
                                  child: const Text('OK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_isSpinning)
                  Positioned.fill(
                    child: Container(
                      color: Color.fromARGB((255 * 0.6).round(), 0, 0, 0), // Darker overlay
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSpinCountCard(
    BuildContext context, {
    required String label,
    required int count,
    int? limit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(
              limit != null ? '$count / $limit' : '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
