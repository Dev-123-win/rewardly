import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ad_service.dart'; // Consolidated AdService
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/user_data_provider.dart'; // Import UserDataProvider
import '../../widgets/animated_tap.dart'; // Import AnimatedTap
import '../../logger_service.dart'; // Import LoggerService

import '../../remote_config_service.dart'; // Import RemoteConfigService

class EarnCoinsScreen extends StatefulWidget {
  const EarnCoinsScreen({super.key});

  @override
  State<EarnCoinsScreen> createState() => _EarnCoinsScreenState();
}

class _EarnCoinsScreenState extends State<EarnCoinsScreen> {
  final AdService _adService = AdService();
  // UserService will be obtained from Provider
  bool _isAdLoading = false;
  User? _currentUser;
  int _adsWatchedToday = 0; // New state variable for ads watched today
  int _dailyAdLimit = 0; // Will be fetched from Remote Config
  List<int> _adRewards = []; // Will be fetched from Remote Config
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<User?>(context, listen: false);
    _loadRemoteConfigAndAds(); // Load remote config and then ads

    // Listen to user data changes to update adsWatchedToday
    Provider.of<UserDataProvider>(context, listen: false).addListener(_onUserDataChanged);
    _updateAdsWatchedState(); // Initial load of ads watched state
  }

  @override
  void dispose() {
    _adService.dispose();
    Provider.of<UserDataProvider>(context, listen: false).removeListener(_onUserDataChanged);
    super.dispose();
  }

  void _onUserDataChanged() {
    if (!mounted) return;
    _updateAdsWatchedState();
  }

  Future<void> _loadRemoteConfigAndAds() async {
    await _remoteConfigService.initialize();
    if (mounted) {
      setState(() {
        _dailyAdLimit = _remoteConfigService.dailyAdLimit;
        _adRewards = _remoteConfigService.adRewardsList;
      });
    }
    _loadAd(); // Load ad after remote config is loaded
  }

  Future<void> _updateAdsWatchedState() async {
    if (!mounted) return; // Add mounted check here
    LoggerService.debug('Updating adsWatchedToday state. Current value: $_adsWatchedToday'); // Log for debugging
    if (_currentUser == null) {
      if (mounted) {
        setState(() {
          _adsWatchedToday = 0;
        });
      }
      return;
    }

    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final userData = userDataProvider.userData;

    if (userData != null && userData.data() != null) {
      final data = userData.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _adsWatchedToday = data['adsWatchedToday'] ?? 0;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _adsWatchedToday = 0;
        });
      }
    }
  }

  void _loadAd() async {
    if (!mounted) return;
    setState(() {
      _isAdLoading = true;
    });
    _adService.loadRewardedAd();
    if (!mounted) return;
    setState(() {
      _isAdLoading = false;
    });
  }

  void _watchAd(int points) {
    if (_currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to watch ads.')),
      );
      return;
    }

    if (_adsWatchedToday >= _dailyAdLimit) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached your daily ad limit.')),
      );
      return;
    }

    _adService.showRewardedAd(
      onRewardEarned: (int rewardAmount) async {
        final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
        await userDataProvider.shardedUserService!.updateCoins(_currentUser!.uid, points);
        // ProjectId is no longer needed for client-side updateAdsWatchedToday
        await userDataProvider.shardedUserService!.updateAdsWatchedToday(_currentUser!.uid); // Increment ads watched today
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You earned $points coins!')),
        );
        // Manually update state to reflect the watched ad immediately
        if (mounted) {
          setState(() {
            _adsWatchedToday++;
          });
        }
        _loadAd(); // Reload ad
      },
      onAdFailedToLoad: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load ad. Please try again.')),
        );
        _loadAd(); // Try reloading ad
      },
      onAdFailedToShow: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to show ad. Please try again.')),
        );
        _loadAd(); // Try reloading ad
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalAds = _adRewards.length;
    final int adsRemaining = totalAds - _adsWatchedToday;

    return Scaffold(
      appBar: AppBar(
        title: Text('Watch & Earn', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isAdLoading
          ? const Center(
              child: SpinKitCircle(
                color: Colors.deepPurple,
                size: 50.0,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ads Watched Today: $_adsWatchedToday / $totalAds',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _adsWatchedToday / totalAds,
                        backgroundColor: Colors.grey[300],
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: adsRemaining > 0
                      ? ListView( // Changed to ListView as we're showing only one card or a few
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          children: [
                            _AdCard(
                              title: 'Watch Ad #${_adsWatchedToday + 1}',
                              points: _adRewards[_adsWatchedToday],
                              onWatchAd: () => _watchAd(_adRewards[_adsWatchedToday]),
                              isLocked: false, // The displayed card is always the next available, so it's not locked
                              lockedMessage: null,
                            ),
                          ],
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                                const SizedBox(height: 20),
                                Text(
                                  'You\'ve watched all your ads for today!',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Come back tomorrow for more earning opportunities.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final String title;
  final int points;
  final VoidCallback? onWatchAd; // Make nullable for locked state
  final bool isLocked;
  final String? lockedMessage;

  const _AdCard({
    required this.title,
    required this.points,
    this.onWatchAd,
    this.isLocked = false,
    this.lockedMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [
              Colors.white.withAlpha((0.8 * 255).round()),
              Colors.white.withAlpha((0.5 * 255).round()),
              Colors.purple.withAlpha((0.1 * 255).round()),
              Colors.yellow.withAlpha((0.1 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Custom "AD" icon (like a TV)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'AD',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset('assets/coin.png', height: 24, width: 24), // Coin image
                  const SizedBox(width: 5),
                  Text(
                    '+$points', // Display points as +X
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedTap(
              onTap: isLocked ? null : onWatchAd, // Disable tap if locked
              child: ElevatedButton(
                onPressed: isLocked ? null : onWatchAd, // Disable button if locked
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLocked ? Colors.grey[300] : Colors.deepPurple, // Grey if locked, purple if unlocked
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: isLocked ? 0 : 5, // No elevation if locked
                ),
                child: Text(
                  isLocked ? (lockedMessage ?? 'Locked') : 'Watch Ad', // Only "Watch Ad"
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isLocked ? Colors.grey[700] : Colors.white, // Darker text if locked
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
