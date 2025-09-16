import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rewardly_app/user_service.dart';

class AdRewardService {
  final UserService _userService = UserService();
  RewardedAd? _rewardedAd;
  final String _adUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test Ad Unit ID

  final User? _user;

  AdRewardService(this._user); // Constructor to receive the current user

  Future<void> loadRewardedAd() async {
    if (_user == null) return; // Cannot load ad without a user

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _setRewardedAdCallbacks();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          // Handle the error appropriately
          log('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void _setRewardedAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
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
        loadRewardedAd(); // Load a new ad if showing failed
      },
    );
  }

  void showRewardedAd({
    required Function onRewardEarned,
    required Function onAdFailedToLoad,
    required Function onAdFailedToShow,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd?.show(onUserEarnedReward: (ad, reward) {
        if (_user != null) {
          rewardUserForAd(uid: _user.uid, coinsPerAd: reward.amount.toInt());
          onRewardEarned();
        }
      });
    } else {
      onAdFailedToShow();
      loadRewardedAd(); // Try to load a new ad
    }
  }

  Future<void> rewardUserForAd({
    required String uid,
    required int coinsPerAd,
  }) async {
    await _userService.updateCoins(uid, coinsPerAd);
    await _userService.updateAdsWatchedToday(uid);
  }
}
