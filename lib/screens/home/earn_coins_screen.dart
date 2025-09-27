import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/ad_service.dart'; // Consolidated AdService
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rewardly_app/user_service.dart';
import 'package:rewardly_app/providers/user_data_provider.dart'; // Import UserDataProvider
import 'package:rewardly_app/widgets/animated_tap.dart'; // Import AnimatedTap

class EarnCoinsScreen extends StatefulWidget {
  const EarnCoinsScreen({super.key});

  @override
  State<EarnCoinsScreen> createState() => _EarnCoinsScreenState();
}

class _EarnCoinsScreenState extends State<EarnCoinsScreen> {
  final AdService _adService = AdService();
  final UserService _userService = UserService();
  bool _isAdLoading = false;
  User? _currentUser;
  int _adsWatchedToday = 0; // New state variable for ads watched today
  static const int _dailyAdLimit = 10; // Define daily ad limit

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<User?>(context, listen: false);
    _loadAd(); // Load ad when screen initializes

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
    _updateAdsWatchedState();
  }

  Future<void> _updateAdsWatchedState() async {
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
        await _userService.updateCoins(_currentUser!.uid, points);
        await _userService.updateAdsWatchedToday(_currentUser!.uid); // Increment ads watched today
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You earned $points coins!')),
        );
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
    final int remainingAds = _dailyAdLimit - _adsWatchedToday;

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
          : remainingAds > 0
              ? ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: remainingAds, // Show only remaining ads
                  itemBuilder: (context, index) {
                    // Each card offers 100 coins
                    return _AdCard(
                      title: 'Watch an ad',
                      points: 100,
                      onWatchAd: () => _watchAd(100),
                    );
                  },
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
    );
  }
}

class _AdCard extends StatelessWidget {
  final String title;
  final int points;
  final VoidCallback onWatchAd;

  const _AdCard({
    required this.title,
    required this.points,
    required this.onWatchAd,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.green[700], size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '$points Points',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedTap( // Wrap ElevatedButton with AnimatedTap
              onTap: onWatchAd,
              child: ElevatedButton(
                onPressed: null, // onPressed is handled by AnimatedTap
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Watch Ad ($points Coins)',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
