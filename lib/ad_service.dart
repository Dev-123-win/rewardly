import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Singleton instance
  AdService._();
  static final AdService _instance = AdService._();
  factory AdService() => _instance;

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  final String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test Ad Unit ID

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test Ad Unit ID

  // Load Rewarded Ad
  void loadRewardedAd() {
    if (_rewardedAd != null) return; // Ad already loaded

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          log('RewardedAd loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _numRewardedLoadAttempts++;
          log('RewardedAd failed to load: $error');
          if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
            loadRewardedAd();
          }
        },
      ),
    );
  }

  // Show Rewarded Ad
  void showRewardedAd({
    required Function onRewardEarned,
    required Function onAdFailedToLoad,
    required Function onAdFailedToShow,
  }) {
    if (_rewardedAd == null) {
      onAdFailedToShow();
      loadRewardedAd(); // Try to load a new ad
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => log('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (ad) {
        log('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Load a new ad after the current one is dismissed
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _rewardedAd = null;
        onAdFailedToShow();
        loadRewardedAd(); // Load a new ad if showing failed
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
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
          log('InterstitialAd loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _numInterstitialLoadAttempts++;
          log('InterstitialAd failed to load: $error');
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
      onAdShowedFullScreenContent: (InterstitialAd ad) => log('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed();
        loadInterstitialAd(); // Load a new ad
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _interstitialAd = null;
        onAdFailedToShow();
        loadInterstitialAd(); // Load a new ad
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null; // Clear ad after showing
  }

  // Dispose of all ads
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
