import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:convert'; // Import for json.decode
import 'logger_service.dart'; // Import LoggerService

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
      // 'admin_email': 'admin@example.com', // Removed hardcoded admin email. Manage admin access via Firebase Authentication Custom Claims or a dedicated Firestore collection.
      'spin_wheel_daily_ad_limit': 10, // New default for spin wheel game
      'max_bonus_coins_per_milestone': 50, // New default for tunnel runner game
      'ad_rewards_list': '[30, 72, 120, 162, 210, 240, 300]', // Default ad rewards as JSON string
    });
  }

  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e, s) {
      LoggerService.error('Error fetching remote config: $e', e, s);
    }
  }

  int get dailyAdLimit => _remoteConfig.getInt('daily_ad_limit');
  int get coinsPerAd => _remoteConfig.getInt('coins_per_ad');
  // String get adminEmail => _remoteConfig.getString('admin_email'); // Removed hardcoded admin email getter
  int get spinWheelDailyAdLimit => _remoteConfig.getInt('spin_wheel_daily_ad_limit');
  int get maxBonusCoinsPerMilestone => _remoteConfig.getInt('max_bonus_coins_per_milestone');

  List<int> get adRewardsList {
    final String jsonString = _remoteConfig.getString('ad_rewards_list');
    try {
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList.cast<int>();
    } catch (e, s) {
      LoggerService.error('Error decoding ad_rewards_list from Remote Config: $e', e, s);
      return [30, 72, 120, 162, 210, 240, 300]; // Fallback to hardcoded defaults
    }
  }
}
