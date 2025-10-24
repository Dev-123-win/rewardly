import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Replaced webview_flutter
import '../../ad_service.dart';
import '../../providers/user_data_provider.dart';
import '../../shared/neuromorphic_constants.dart';
import '../../logger_service.dart';
import 'dart:math'; // For random task generation

// Define a model for a read task
class ReadTask {
  final int durationMinutes;
  final int coins;
  final String url;
  final String title;

  ReadTask({
    required this.durationMinutes,
    required this.coins,
    required this.url,
    required this.title,
  });
}

class ReadAndEarnScreen extends StatefulWidget {
  const ReadAndEarnScreen({super.key});

  @override
  State<ReadAndEarnScreen> createState() => _ReadAndEarnScreenState();
}

class _ReadAndEarnScreenState extends State<ReadAndEarnScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  final AdService _adService = AdService();
  ReadTask? _currentReadTask;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  DateTime? _backgroundTime;
  bool _isAdLoading = false;
  bool _isReading = false;
  // Removed _showWebView, _webViewController, _isLoadingWebView as InAppBrowser handles its own display

  // Animation controllers for neumorphic effects and subtle animations
  late AnimationController _cardAnimationController;
  late Animation<double> _cardScaleAnimation;

  final List<ReadTask> _availableReadTasks = [
    ReadTask(durationMinutes: 1, coins: 30, url: 'https://rewardly.page.gd/index.html', title: 'Read for 1 Minute'),
    ReadTask(durationMinutes: 2, coins: 60, url: 'https://rewardly.page.gd/2minute.html', title: 'Read for 2 Minutes'),
    ReadTask(durationMinutes: 3, coins: 100, url: 'https://rewardly.page.gd/3minute.html', title: 'Read for 3 Minutes'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _adService.loadInterstitialAd(); // Preload interstitial ad
    _generateNewReadTask();

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
    WidgetsBinding.instance.removeObserver(this);
    _cardAnimationController.dispose();
    _adService.dispose();
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Dismiss any active snackbar
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    LoggerService.debug('App lifecycle state changed: $state');
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
      LoggerService.debug('App paused at: $_backgroundTime');
    } else if (state == AppLifecycleState.resumed) {
      LoggerService.debug('App resumed.');
      if (_isReading && _backgroundTime != null) {
        final int elapsedSeconds = DateTime.now().difference(_backgroundTime!).inSeconds;
        LoggerService.debug('Elapsed in background: $elapsedSeconds seconds. Seconds remaining: $_secondsRemaining');

        if (elapsedSeconds < _secondsRemaining) {
          // User returned before the timer would have naturally expired
          _resetTaskAndGenerateNew();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You returned too early! No reward.')),
          );
        } else {
          // User returned after the timer would have expired
          _countdownTimer?.cancel();
          _secondsRemaining = 0;
          _showClaimCoinsModal();
        }
      }
      _backgroundTime = null; // Reset background time
    }
  }

  void _generateNewReadTask() {
    setState(() {
      _currentReadTask = _availableReadTasks[Random().nextInt(_availableReadTasks.length)];
      _secondsRemaining = _currentReadTask!.durationMinutes * 60;
      _isReading = false;
      LoggerService.debug('New read task generated: ${_currentReadTask!.title} for ${_currentReadTask!.durationMinutes} minutes.');
    });
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _isReading = true;
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
          _isReading = false;
          _showClaimCoinsModal();
        }
      });
    });
  }

  void _launchUrlInApp(String url) async {
    try {
      await InAppBrowser.openWithSystemBrowser(url: WebUri(url)); // Changed Uri.parse to WebUri
      LoggerService.debug('Launched URL in InAppBrowser: $url');
    } catch (e) {
      LoggerService.error('Failed to launch URL in InAppBrowser: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  void _showClaimCoinsModal() {
    if (!mounted || _currentReadTask == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(kDefaultPadding * 2),
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(kDefaultBorderRadius * 2)),
            boxShadow: kNeumorphicShadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Task Completed!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: kTextColor,
                    ),
              ),
              const SizedBox(height: kDefaultPadding),
              Text(
                'You earned ${_currentReadTask!.coins} coins!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: kAccentColor,
                    ),
              ),
              const SizedBox(height: kDefaultPadding * 2),
              ElevatedButton(
                onPressed: _claimCoins,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 2, vertical: kDefaultPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                  ),
                ),
                child: Text(
                  'Claim Coins',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _claimCoins() async {
    Navigator.pop(context); // Close the modal sheet
    if (!mounted || _currentReadTask == null) return;

    setState(() {
      _isAdLoading = true;
    });

    _adService.showInterstitialAd(
      onAdDismissed: () async {
        if (!mounted) return;
        setState(() {
          _isAdLoading = false;
        });
        final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
        if (!mounted) return; // Check mounted again after async operation
        await userDataProvider.updateUserCoins(_currentReadTask!.coins);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You claimed ${_currentReadTask!.coins} coins!')),
        );
        _generateNewReadTask(); // Generate a new task after claiming
      },
      onAdFailedToShow: () async { // Made async to allow await
        LoggerService.error('ReadAndEarnScreen: _claimCoins - Interstitial ad failed to show.');
        if (!mounted) return;
        setState(() {
          _isAdLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to show ad. Coins awarded directly.')),
        );
        // Award coins even if ad fails to show
        final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
        if (!mounted) return; // Check mounted again after async operation
        await userDataProvider.updateUserCoins(_currentReadTask!.coins); // Await the update
        _generateNewReadTask(); // Generate a new task after claiming
      },
    );
  }

  void _resetTaskAndGenerateNew() {
    _countdownTimer?.cancel();
    setState(() {
      _isReading = false;
      _secondsRemaining = 0;
    });
    _generateNewReadTask();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text('Read & Earn'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: kTextColor,
        ),
        body: Stack(
          children: [
            Center(
              child: _currentReadTask == null
                  ? const CircularProgressIndicator(color: kPrimaryColor)
                  : _buildReadCard(context),
            ),
            if (_isAdLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha((255 * 0.6).round()),
                  child: const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadCard(BuildContext context) {
    if (_currentReadTask == null) return const SizedBox.shrink();

    Function()? onPressed;
    Color cardColor = kSurfaceColor;
    List<BoxShadow> boxShadow = kNeumorphicShadows;
    dynamic icon = HugeIcons.strokeRoundedBook01;
    Color iconColor = kAccentColor;
    String statusText = 'Start Reading';

    if (_isReading) {
      statusText = 'Reading... ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}';
      icon = HugeIcons.strokeRoundedTime01;
      iconColor = kPrimaryColor;
      onPressed = null; // Disable button while reading
    } else {
      onPressed = () {
        _launchUrlInApp(_currentReadTask!.url);
        _startCountdownTimer();
      };
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600; // Define what constitutes a "small screen"

        return GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            padding: const EdgeInsets.all(kDefaultPadding),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(kDefaultBorderRadius),
              boxShadow: boxShadow,
            ),
            child: isSmallScreen
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(icon: icon, color: iconColor, size: 30),
                      const SizedBox(height: kDefaultPadding / 2),
                      Flexible(
                        child: Text(
                          _currentReadTask!.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: kTextColor,
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          'Earn ${_currentReadTask!.coins} Coins',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kTextColor,
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          statusText,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: iconColor,
                              ),
                        ),
                      ),
                      if (!_isReading)
                        Padding(
                          padding: const EdgeInsets.only(top: kDefaultPadding),
                          child: ScaleTransition(
                            scale: _cardScaleAnimation,
                            child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: kAccentColor),
                          ),
                        ),
                    ],
                  )
                : Row(
                    children: [
                      HugeIcon(icon: icon, color: iconColor, size: 30),
                      const SizedBox(width: kDefaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentReadTask!.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: kTextColor,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Earn ${_currentReadTask!.coins} Coins',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kTextColor,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              statusText,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: iconColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isReading)
                        ScaleTransition(
                          scale: _cardScaleAnimation,
                          child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: kAccentColor),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
