import 'package:google_mobile_ads/google_mobile_ads.dart';
class AdService {
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // Ad Unit IDs
  final String _rewardedAdUnitId = 'ca-app-pub-3863562453957252/781943874';

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _numRewardedLoadAttempts++;
          if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
            loadRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd(Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward) {
    if (_rewardedAd == null) {
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {},
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        loadRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    _rewardedAd = null;
  }
}
