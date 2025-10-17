import 'package:flutter/material.dart'; // Import for ValueNotifier
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'logger_service.dart'; // Import LoggerService

class AdService {
  // Singleton instance
  AdService._();
  static final AdService _instance = AdService._();
  factory AdService() => _instance;

  bool _isInitialized = false;

  // Initialize Google Mobile Ads SDK
  Future<void> initialize() async {
    if (!_isInitialized) {
      LoggerService.info('Initializing Google Mobile Ads SDK...');
      await MobileAds.instance.initialize();
      _isInitialized = true;
      LoggerService.info('Google Mobile Ads SDK initialized.');
    } else {
      LoggerService.debug('Google Mobile Ads SDK already initialized.');
    }
  }

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  final String _rewardedAdUnitId = 'ca-app-pub-3863562453957252/7819438744'; // TODO: Replace with actual production ad unit ID from Google AdMob

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final String _interstitialAdUnitId = 'ca-app-pub-3863562453957252/8204266334'; // TODO: Replace with actual production ad unit ID from Google AdMob

  // Rewarded Interstitial Ad
  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;
  final String _rewardedInterstitialAdUnitId = 'ca-app-pub-3863562453957252/7908873970'; // Provided by user

  // Banner Ad
  BannerAd? _bannerAd;
  final String _bannerAdUnitId = 'ca-app-pub-3863562453957252/8322001628'; // TODO: Replace with actual production ad unit ID from Google AdMob
  ValueNotifier<bool> bannerAdLoadedNotifier = ValueNotifier<bool>(false);

  BannerAd? get bannerAd => _bannerAd;

  // Load Rewarded Ad
  void loadRewardedAd() {
    if (_rewardedAd != null) {
      LoggerService.debug('RewardedAd already loaded, skipping load request.');
      return; // Ad already loaded
    }
    LoggerService.debug('Attempting to load RewardedAd. Attempt: $_numRewardedLoadAttempts');

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          LoggerService.info('RewardedAd loaded successfully.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _numRewardedLoadAttempts++;
          LoggerService.error('RewardedAd failed to load: $error. Attempts: $_numRewardedLoadAttempts');
          if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
            loadRewardedAd();
          } else {
            LoggerService.warning('Max rewarded ad load attempts reached. Stopping retries.');
          }
        },
      ),
    );
  }

  // Show Rewarded Ad
  void showRewardedAd({
    required Function onRewardEarned,
    required Function onAdFailedToShow, // This callback is for when the ad fails to show
  }) {
    if (_rewardedAd == null) {
      LoggerService.warning('RewardedAd is null when trying to show. Calling onAdFailedToShow.');
      onAdFailedToShow();
      loadRewardedAd(); // Try to load a new ad
      return;
    }

    LoggerService.debug('Attempting to show RewardedAd.');
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => LoggerService.info('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (ad) {
        LoggerService.info('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Load a new ad after the current one is dismissed
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        LoggerService.error('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _rewardedAd = null;
        onAdFailedToShow();
        loadRewardedAd(); // Load a new ad if showing failed
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      LoggerService.info('User earned reward: ${reward.amount} ${reward.type}');
      onRewardEarned(reward.amount.toInt());
    });
    _rewardedAd = null; // Clear ad after showing
  }

  // Load Interstitial Ad
  void loadInterstitialAd() {
    if (_interstitialAd != null) return; // Ad already loaded

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          LoggerService.info('InterstitialAd loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _numInterstitialLoadAttempts++;
          LoggerService.error('InterstitialAd failed to load: $error');
          if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  // Show Interstitial Ad
  void showInterstitialAd({
    required Function onAdDismissed,
    required Function onAdFailedToShow,
  }) {
    if (_interstitialAd == null) {
      onAdFailedToShow();
      loadInterstitialAd(); // Try to load a new ad
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => LoggerService.info('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        LoggerService.info('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed();
        loadInterstitialAd(); // Load a new ad
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        LoggerService.error('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _interstitialAd = null;
        onAdFailedToShow();
        loadInterstitialAd(); // Load a new ad
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null; // Clear ad after showing
  }

  // Load Banner Ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          LoggerService.info('$ad loaded.');
          _bannerAd = ad as BannerAd;
          bannerAdLoadedNotifier.value = true; // Notify listeners that banner ad is loaded
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          LoggerService.error('$ad failed to load: $error');
          ad.dispose();
          bannerAdLoadedNotifier.value = false; // Notify listeners that banner ad failed to load
        },
        onAdOpened: (Ad ad) => LoggerService.info('$ad opened.'),
        onAdClosed: (Ad ad) => LoggerService.info('$ad closed.'),
        onAdImpression: (Ad ad) => LoggerService.info('$ad impression.'),
      ),
    )..load();
  }

  // Dispose of all ads
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedInterstitialAd?.dispose(); // Dispose rewarded interstitial ad
    _bannerAd?.dispose();
  }

  // Load Rewarded Interstitial Ad
  void loadRewardedInterstitialAd() {
    if (_rewardedInterstitialAd != null) {
      LoggerService.debug('RewardedInterstitialAd already loaded, skipping load request.');
      return;
    }
    LoggerService.debug('Attempting to load RewardedInterstitialAd. Attempt: $_numRewardedInterstitialLoadAttempts');

    RewardedInterstitialAd.load(
      adUnitId: _rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          _rewardedInterstitialAd = ad;
          _numRewardedInterstitialLoadAttempts = 0;
          LoggerService.info('RewardedInterstitialAd loaded successfully.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedInterstitialAd = null;
          _numRewardedInterstitialLoadAttempts++;
          LoggerService.error('RewardedInterstitialAd failed to load: $error. Attempts: $_numRewardedInterstitialLoadAttempts');
          if (_numRewardedInterstitialLoadAttempts <= maxFailedLoadAttempts) {
            loadRewardedInterstitialAd();
          } else {
            LoggerService.warning('Max rewarded interstitial ad load attempts reached. Stopping retries.');
          }
        },
      ),
    );
  }

  // Show Rewarded Interstitial Ad
  void showRewardedInterstitialAd({
    required Function onAdDismissed,
    required Function onAdFailedToShow,
    required Function(int rewardAmount) onRewardEarned,
  }) {
    if (_rewardedInterstitialAd == null) {
      LoggerService.warning('RewardedInterstitialAd is null when trying to show. Calling onAdFailedToShow.');
      onAdFailedToShow();
      loadRewardedInterstitialAd(); // Try to load a new ad
      return;
    }

    LoggerService.debug('Attempting to show RewardedInterstitialAd.');
    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => LoggerService.info('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (ad) {
        LoggerService.info('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _rewardedInterstitialAd = null;
        onAdDismissed();
        loadRewardedInterstitialAd(); // Load a new ad after the current one is dismissed
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        LoggerService.error('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _rewardedInterstitialAd = null;
        onAdFailedToShow();
        loadRewardedInterstitialAd(); // Load a new ad if showing failed
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(onUserEarnedReward: (ad, reward) {
      LoggerService.info('User earned reward from RewardedInterstitialAd: ${reward.amount} ${reward.type}');
      onRewardEarned(reward.amount.toInt());
    });
    _rewardedInterstitialAd = null; // Clear ad after showing
  }
}
