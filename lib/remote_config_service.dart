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
    await fetchAndActivate();
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

  Future<void> setConfigDefaults(Map<String, dynamic> defaults) async {
    await _remoteConfig.setDefaults(defaults);
  }
}
