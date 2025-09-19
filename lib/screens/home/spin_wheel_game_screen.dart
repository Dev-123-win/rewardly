import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../user_service.dart';
import '../../ad_service.dart'; // Consolidated AdService
import '../../remote_config_service.dart';
import '../../shared/shimmer_loading.dart';
import '../../providers/user_data_provider.dart';
import 'dart:convert'; // For JSON encoding/decoding

class SpinWheelGameScreen extends StatefulWidget {
  const SpinWheelGameScreen({super.key});

  @override
  State<SpinWheelGameScreen> createState() => _SpinWheelGameScreenState();
}

class _SpinWheelGameScreenState extends State<SpinWheelGameScreen> {
  late final WebViewController _controller;
  final UserService _userService = UserService();
  final AdService _adService = AdService(); // Use consolidated AdService
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  User? _currentUser;
  int _freeSpinsToday = 0;
  int _adSpinsWatchedToday = 0;
  int _spinWheelDailyAdLimit = 10; // Default, will be updated by RemoteConfig

  bool _isLoading = true;
  bool _isSpinning = false;
  String? _resultMessage;
  // int? _lastRewardAmount; // Removed as it was unused

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<User?>(context, listen: false);
    _adService.loadRewardedAd(); // Pre-load an ad
    _adService.loadInterstitialAd(); // Pre-load interstitial if needed for other features
    // Note: AdService is a singleton, so no need to pass _currentUser to its constructor.
    // AdService handles user context internally or expects it to be passed to show methods.

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // print('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            // print('Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            // print('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            _updateSpinState(); // Send initial spin state to web
          },
          onWebResourceError: (WebResourceError error) {
            // print('''
            // Page resource error:
            //   code: ${error.errorCode}
            //   description: ${error.description}
            //   errorType: ${error.errorType}
            //   isForMainFrame: ${error.isForMainFrame}
            //           ''');
          },
        ),
      )
      ..loadFlutterAsset('assets/web/spin_wheel_game.html');

    // Listen to user data changes
    Provider.of<UserDataProvider>(context, listen: false).addListener(_onUserDataChanged);
  }

  @override
  void dispose() {
    Provider.of<UserDataProvider>(context, listen: false).removeListener(_onUserDataChanged);
    _adService.dispose(); // Dispose all ads managed by the singleton AdService
    super.dispose();
  }

  void _onUserDataChanged() {
    _updateSpinState();
  }

  Future<void> _updateSpinState() async {
    if (_currentUser == null) return;

    // Ensure daily counts are reset if date has changed
    await _userService.resetSpinWheelDailyCounts(_currentUser!.uid);

    final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
    if (userData != null && userData.data() != null) {
      final data = userData.data() as Map<String, dynamic>;
      setState(() {
        _freeSpinsToday = data['spinWheelFreeSpinsToday'] ?? 0;
        _adSpinsWatchedToday = data['spinWheelAdSpinsToday'] ?? 0;
        _spinWheelDailyAdLimit = _remoteConfigService.spinWheelDailyAdLimit;
      });
    }
    _sendSpinAvailabilityToWeb();
  }

  void _sendSpinAvailabilityToWeb() {
    final canSpinFree = _freeSpinsToday > 0;
    final canSpinAd = _adSpinsWatchedToday < _spinWheelDailyAdLimit;

    _controller.runJavaScript('''
      if (window.updateSpinButton) {
        window.updateSpinButton(${jsonEncode(canSpinFree)}, ${jsonEncode(canSpinAd)});
      }
    ''');
  }

  void _handleJavaScriptMessage(String message) {
    final Map<String, dynamic> data = jsonDecode(message);
    final String type = data['type'];

    switch (type) {
      case 'spinComplete':
        final int rewardAmount = data['rewardAmount'];
        _handleSpinComplete(rewardAmount);
        break;
      case 'requestSpin':
        _handleSpinRequest();
        break;
      case 'spinStarted':
        setState(() {
          _isSpinning = true;
          _resultMessage = null;
          // _lastRewardAmount = null; // Removed as it was unused
        });
        break;
    }
  }

  Future<void> _handleSpinRequest() async {
    if (_currentUser == null || _isSpinning) return;

    if (_freeSpinsToday > 0) {
      // Use a free spin
      await _userService.decrementFreeSpinWheelSpins(_currentUser!.uid);
      _controller.runJavaScript('window.startSpinAnimation(true);'); // Tell web to spin
    } else if (_adSpinsWatchedToday < _spinWheelDailyAdLimit) {
      // Offer ad for a spin
      _showRewardedAdForSpin();
    } else {
      // No more spins today
      _controller.runJavaScript('window.showNoMoreSpinsMessage();');
    }
  }

  void _showRewardedAdForSpin() {
    _adService.showRewardedAd(
      onRewardEarned: (int rewardAmount) async { // AdService now passes rewardAmount
        if (_currentUser != null) {
          await _userService.incrementAdSpinWheelSpins(_currentUser!.uid);
          _controller.runJavaScript('window.startSpinAnimation(true);'); // Tell web to spin
        }
      },
      onAdFailedToLoad: () {
        _controller.runJavaScript('window.handleAdResult(false, "ad_for_spin", 0);'); // Inform web of ad failure
        _showResultOverlay(false, null, 'Failed to load ad. Try again later.');
      },
      onAdFailedToShow: () {
        _controller.runJavaScript('window.handleAdResult(false, "ad_for_spin", 0);'); // Inform web of ad failure
        _showResultOverlay(false, null, 'Ad could not be shown. Try again later.');
      },
    );
  }

  Future<void> _handleSpinComplete(int rewardAmount) async {
    if (_currentUser == null) return;

    // Reward user with coins
    await _userService.updateCoins(_currentUser!.uid, rewardAmount);

    setState(() {
      _isSpinning = false;
      // _lastRewardAmount = rewardAmount; // Removed as it was unused
    });
    _controller.runJavaScript('window.handleAdResult(true, $rewardAmount);'); // Inform web of reward
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: ShimmerLoading.rectangular(height: 50, width: 200), // Placeholder for loading
            ),
          if (_resultMessage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha((0.7 * 255).round()), // Fixed deprecated withOpacity
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _resultMessage!,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _resultMessage = null;
                          });
                          _sendSpinAvailabilityToWeb(); // Refresh button state
                        },
                        child: const Text('OK'),
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
