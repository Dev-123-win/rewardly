import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ad_service.dart';
import '../../remote_config_service.dart';
import '../../providers/user_data_provider.dart';
import '../../logger_service.dart';

class SpinWheelGameScreen extends StatefulWidget {
  const SpinWheelGameScreen({super.key});

  @override
  State<SpinWheelGameScreen> createState() => _SpinWheelGameScreenState();
}

class _SpinWheelGameScreenState extends State<SpinWheelGameScreen> {
  final AdService _adService = AdService();
  // UserService will be obtained from Provider
  final RemoteConfigService _remoteConfigService = RemoteConfigService();
  User? _currentUser;

  StreamController<int> controller = StreamController<int>();
  int _currentSpinIndex = 0;
  bool _isSpinning = false;
  bool _isAdLoading = false;

  // Spin wheel rewards (coins)
  final List<int> _items = [
    10, 50, 20, 100, 30, 75, 40, 150,
  ];

  int _freeSpinsToday = 0;
  int _adSpinsToday = 0;
  int _spinWheelDailyAdLimit = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<User?>(context, listen: false);
    _adService.loadRewardedAd(); // Preload rewarded ad for extra spins
    _loadRemoteConfig();

    // Listen to user data changes to update spin counts
    Provider.of<UserDataProvider>(context, listen: false).addListener(_onUserDataChanged);
    _updateSpinCounts(); // Initial load of spin counts
  }

  @override
  void dispose() {
    controller.close();
    _adService.dispose();
    Provider.of<UserDataProvider>(context, listen: false).removeListener(_onUserDataChanged);
    super.dispose();
  }

  void _onUserDataChanged() {
    if (!mounted) return;
    _updateSpinCounts();
  }

  Future<void> _loadRemoteConfig() async {
    await _remoteConfigService.initialize();
    if (mounted) {
      setState(() {
        _spinWheelDailyAdLimit = _remoteConfigService.spinWheelDailyAdLimit;
      });
    }
  }

  Future<void> _updateSpinCounts() async {
    if (!mounted || _currentUser == null) return;

    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // Ensure daily counts are reset if date has changed using the sharded UserService
    final String? projectId = (userDataProvider.userData?.data() as Map<String, dynamic>?)?['projectId'];
    if (projectId != null) {
      await userDataProvider.shardedUserService!.resetSpinWheelDailyCounts(_currentUser!.uid, projectId);
    } else {
      LoggerService.error('ProjectId not found for user ${_currentUser!.uid} when resetting spin wheel daily counts.');
    }

    final userData = userDataProvider.userData;

    if (userData != null && userData.data() != null) {
      final data = userData.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _freeSpinsToday = data['spinWheelFreeSpinsToday'] ?? 0;
          _adSpinsToday = data['spinWheelAdSpinsToday'] ?? 0;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _freeSpinsToday = 0;
          _adSpinsToday = 0;
        });
      }
    }
  }

  void _spinWheel({bool isAdSpin = false}) async {
    if (_isSpinning || _currentUser == null) return;

    if (!isAdSpin && _freeSpinsToday <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No free spins left! Watch an ad for more.')),
      );
      return;
    }

    if (isAdSpin && _adSpinsToday >= _spinWheelDailyAdLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached your daily ad spin limit.')),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _currentSpinIndex = Random().nextInt(_items.length);
      controller.add(_currentSpinIndex);
    });

    // Wait for the wheel to stop spinning
    await Future.delayed(const Duration(seconds: 5)); // Adjust duration based on animation

    if (!mounted) return;

    setState(() {
      _isSpinning = false;
    });

    final int earnedCoins = _items[_currentSpinIndex];
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    await userDataProvider.shardedUserService!.updateCoins(_currentUser!.uid, earnedCoins);

    if (isAdSpin) {
      await userDataProvider.shardedUserService!.incrementAdSpinWheelSpins(_currentUser!.uid);
    } else {
      await userDataProvider.shardedUserService!.decrementFreeSpinWheelSpins(_currentUser!.uid);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You won $earnedCoins coins!')),
    );
  }

  void _watchAdForSpin() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to watch ads.')),
      );
      return;
    }

    if (_adSpinsToday >= _spinWheelDailyAdLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached your daily ad spin limit.')),
      );
      return;
    }

    setState(() {
      _isAdLoading = true;
    });

    _adService.showRewardedAd(
      onRewardEarned: (int rewardAmount) {
        if (!mounted) return;
        setState(() {
          _isAdLoading = false;
        });
        _spinWheel(isAdSpin: true); // Grant a spin after watching ad
      },
      onAdFailedToLoad: () {
        if (!mounted) return;
        setState(() {
          _isAdLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load ad. Please try again.')),
        );
      },
      onAdFailedToShow: () {
        if (!mounted) return;
        setState(() {
          _isAdLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to show ad. Please try again.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final currentCoins = (userDataProvider.userData?.data() as Map<String, dynamic>?)?['coins'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin & Win'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isAdLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : Column(
              children: [
                const SizedBox(height: 20),
                _buildBalanceDisplay(currentCoins),
                const SizedBox(height: 20),
                Expanded(
                  child: FortuneWheel(
                    selected: controller.stream,
                    items: [
                      for (var item in _items)
                        FortuneItem(
                          child: Text(
                            '$item Coins',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          style: FortuneItemStyle(
                            color: _items.indexOf(item) % 2 == 0 ? Colors.deepPurple : Colors.deepPurpleAccent,
                            borderColor: Colors.white,
                            borderWidth: 2,
                          ),
                        ),
                    ],
                    onAnimationEnd: () {
                      // Animation end is handled by the Future.delayed in _spinWheel
                    },
                    indicators: const <FortuneIndicator>[
                      FortuneIndicator(
                        alignment: Alignment.topCenter,
                        child: TriangleIndicator(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSpinButtons(),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildBalanceDisplay(int coins) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monetization_on, color: Colors.amber, size: 30),
            const SizedBox(width: 10),
            Text(
              'Your Coins: $coins',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _isSpinning || _freeSpinsToday <= 0 ? null : () => _spinWheel(isAdSpin: false),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              'Spin for Free ($_freeSpinsToday left)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSpinning || _freeSpinsToday <= 0 ? Colors.grey : Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _isSpinning || _adSpinsToday >= _spinWheelDailyAdLimit ? null : _watchAdForSpin,
            icon: const Icon(Icons.videocam, color: Colors.white),
            label: Text(
              'Watch Ad for Spin ($_adSpinsToday/$_spinWheelDailyAdLimit today)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSpinning || _adSpinsToday >= _spinWheelDailyAdLimit ? Colors.grey : Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }
}
