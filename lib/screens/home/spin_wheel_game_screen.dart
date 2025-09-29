import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../user_service.dart';
import '../../ad_service.dart'; // Consolidated AdService
import '../../remote_config_service.dart';
import '../../providers/user_data_provider.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async'; // For StreamController
import '../../theme_provider.dart';
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

  // bool _isLoading = true; // Removed unused field
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
    _adService.loadRewardedAd(); // Pre-load rewarded ad
    _adService.loadInterstitialAd(); // Pre-load interstitial ad
    _adService.loadBannerAd(); // Pre-load banner ad

    // Listen to user data changes
    Provider.of<UserDataProvider>(context, listen: false).addListener(_onUserDataChanged);
    // Initial load of spin state after the first frame to ensure context is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSpinState();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    // Update current user here as well, in case it changes
    _currentUser = Provider.of<User?>(context);
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
    // Ensure _currentUser is up-to-date before calling _updateSpinState
    _currentUser = Provider.of<User?>(context, listen: false);
    _updateSpinState();
  }

  Future<void> _updateSpinState() async {
    if (!mounted) return; // Check if widget is still mounted

    // setState(() {
    //   _isLoading = true; // Set loading to true at the start of data fetching
    // });

    _currentUser = Provider.of<User?>(context, listen: false); // Get current user here

    if (_currentUser == null) {
      if (mounted) {
        setState(() {
          // _isLoading = false;
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
          // _isLoading = false;
        });
      }
    } else {
      if(mounted) {
        setState(() {
          // _isLoading = false;
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
      _showResultOverlay(false, message: 'No more spins today. Come back tomorrow!');
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
        _showResultOverlay(false, message: 'Failed to load ad. Try again later.');
      },
      onAdFailedToShow: () {
        _showResultOverlay(false, message: 'Ad could not be shown. Try again later.');
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
    _showResultOverlay(true, reward: rewardAmount);
    _updateSpinState(); // Refresh spin state after reward
  }

  void _showResultOverlay(bool success, {int? reward, String? message}) {
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
    // Determine if the current theme is dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Define a subtle gradient for the background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [Colors.grey.shade900, Colors.grey.shade800, Colors.blueGrey.shade900]
          : [Colors.indigo.shade50, Colors.blue.shade100, Colors.purple.shade100],
    );

    return Scaffold(
      // Apply the gradient background to the Scaffold
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: CustomScrollView( // Changed to CustomScrollView for more flexible scrolling with SliverAppBar
          slivers: [
            SliverAppBar(
              title: const Text(
                'Spin & Win!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24, // Increased font size for title
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0, // Removed elevation for a flatter design
              floating: true, // App bar floats above content
              pinned: true, // App bar remains visible at the top
              expandedHeight: 100, // Slightly expanded height
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor, // Removed .shade700
                        Theme.of(context).primaryColor.withAlpha((255 * 0.7).round()), // Removed .shade400 and used withAlpha
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 20),
                  // Spin Count Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSpinCountCard(
                            label: 'Free Spins',
                            count: _freeSpinsToday,
                            icon: Icons.redeem,
                            color: Colors.deepPurple.shade600,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildSpinCountCard(
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
                  // Fortune Wheel Section
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.9, // Make wheel responsive to width
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
                                  Flexible( // Wrap with Flexible
                                    child: Image.asset('assets/coin.png', height: 40, width: 40),
                                  ),
                                  const SizedBox(width: 10), // Increased spacing
                                  Flexible( // Wrap with Flexible
                                    child: Text(
                                      item == 0 ? 'Try Again' : '$item Coins',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith( // Adjusted font size
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 5.0,
                                                color: Colors.black.withAlpha((255 * 0.5).round()), // withAlpha
                                                offset: const Offset(2.0, 2.0),
                                              ),
                                            ],
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              style: FortuneItemStyle(
                                color: item == 0 ? Colors.red.shade700 : (item % 2 == 0 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary), // Use theme colors
                                borderColor: Colors.white.withAlpha((255 * 0.8).round()), // withAlpha
                                borderWidth: 4, // Thicker border
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
                              width: 80, // Larger indicator
                              height: 80, // Larger indicator
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3), // White border
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((255 * 0.4).round()), // withAlpha
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 60, // Larger icon
                              ),
                            ),
                          ),
                        ],
                        animateFirst: false,
                        rotationCount: 20, // More rotations for a better visual effect
                        duration: const Duration(seconds: 10), // Longer spin duration
                        hapticImpact: HapticImpact.heavy,
                        physics: NoPanPhysics(), // Prevent manual scrolling
                        // centerWidget: Image.asset('assets/AppLogo.png', height: 80, width: 80), // Removed as not supported in 1.3.2
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Action Buttons
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
                            icon: const Icon(Icons.redeem, color: Colors.white, size: 28), // Larger icon
                            label: Text(
                              'Free Spin',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 22), // Increased padding
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // More rounded corners
                              elevation: 10, // Stronger elevation
                              shadowColor: Colors.deepPurple.shade900.withAlpha((255 * 0.5).round()), // withAlpha
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _adSpinsWatchedToday < _spinWheelDailyAdLimit && !_isSpinning
                                ? () => _handleSpinRequest(isFreeSpin: false)
                                : null,
                            icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28), // Larger icon
                            label: Text(
                              'Watch Ad for Spin',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 22), // Increased padding
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // More rounded corners
                              elevation: 10, // Stronger elevation
                              shadowColor: Colors.green.shade900.withAlpha((255 * 0.5).round()), // withAlpha
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Banner Ad Placeholder
                  ValueListenableBuilder<bool>(
                    valueListenable: _adService.bannerAdLoadedNotifier,
                    builder: (context, isLoaded, child) {
                      if (isLoaded && _adService.bannerAd != null) {
                        return Container(
                          margin: const EdgeInsets.only(top: 30, bottom: 20, left: 16, right: 16), // Increased margin
                          width: _adService.bannerAd!.size.width.toDouble(),
                          height: _adService.bannerAd!.size.height.toDouble(),
                          child: ads.AdWidget(ad: _adService.bannerAd!),
                        );
                      } else {
                        return const SizedBox(height: 70); // Taller placeholder for ad space
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Result message overlay (positioned at the top level of Scaffold to cover all content)
      // and spinning indicator overlay
      Stack(
        children: [
          if (_resultMessage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha((255 * 0.85).round()), // withAlpha
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Even more rounded
                    elevation: 20, // Stronger elevation
                    child: Padding(
                      padding: const EdgeInsets.all(40.0), // Increased padding
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _resultMessage!.contains('Congratulations') ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                            color: _resultMessage!.contains('Congratulations') ? Colors.amber.shade600 : Colors.grey.shade500, // Themed icon color
                            size: 80, // Larger icon
                          ),
                          const SizedBox(height: 30), // Increased spacing
                          Text(
                            _resultMessage!,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30), // Increased spacing
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
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                            ),
                            child: const Text('OK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                color: Colors.black.withAlpha((255 * 0.7).round()), // withAlpha
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 5), // Thicker progress indicator
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpinCountCard({
    required String label,
    required int count,
    int? limit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 10, // Increased elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // More rounded corners
      color: Colors.white, // White background
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0), // Increased padding
        child: Column(
          children: [
            Icon(icon, size: 40, color: color), // Larger icon
            const SizedBox(height: 15), // Increased spacing
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600), // Larger font
            ),
            const SizedBox(height: 10), // Increased spacing
            Text(
              limit != null ? '$count / $limit' : '$count',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: color, fontWeight: FontWeight.bold), // Larger font
            ),
          ],
        ),
      ),
    );
  }
}
