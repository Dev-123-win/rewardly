import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Private constructor
  RemoteConfigService._();

  // Singleton instance
  static final RemoteConfigService _instance = RemoteConfigService._();

  // Factory constructor to return the singleton instance
  factory RemoteConfigService() {
    return _instance;
  }

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    _setDefaults(); // Set default values
    await fetchAndActivate();
  }

  // Set default values for Remote Config parameters
  void _setDefaults() {
    _remoteConfig.setDefaults(const {
      'daily_ad_limit': 5, // Existing default
      'coins_per_ad': 10, // Existing default
      'admin_email': 'admin@example.com', // Existing default
      'spin_wheel_daily_ad_limit': 10, // New default for spin wheel game
      'max_bonus_coins_per_milestone': 50, // New default for tunnel runner game
    });
  }

  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // print('Error fetching remote config: $e'); // Avoid print in production code
    }
  }

  int get dailyAdLimit => _remoteConfig.getInt('daily_ad_limit');
  int get coinsPerAd => _remoteConfig.getInt('coins_per_ad');
  String get adminEmail => _remoteConfig.getString('admin_email');
  int get spinWheelDailyAdLimit => _remoteConfig.getInt('spin_wheel_daily_ad_limit');
  int get maxBonusCoinsPerMilestone => _remoteConfig.getInt('max_bonus_coins_per_milestone');
}
