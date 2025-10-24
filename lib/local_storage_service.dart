import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart'; // Assuming you have a logger service

class LocalStorageService {
  static const String _locallyEarnedCoinsKey = 'locallyEarnedCoins_';
  static const String _dailySyncStartTimeKey = 'dailySyncStartTime_';
  static const String _lastActiveDateKey = 'lastActiveDate_';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<int> getLocallyEarnedCoins(String uid) async {
    final prefs = await _getPrefs();
    return prefs.getInt('$_locallyEarnedCoinsKey$uid') ?? 0;
  }

  Future<void> addLocallyEarnedCoins(String uid, int amount) async {
    final prefs = await _getPrefs();
    int currentCoins = prefs.getInt('$_locallyEarnedCoinsKey$uid') ?? 0;
    await prefs.setInt('$_locallyEarnedCoinsKey$uid', currentCoins + amount);
    LoggerService.info('LocalStorage: Added $amount coins locally for $uid. New total: ${currentCoins + amount}');
  }

  Future<void> resetLocallyEarnedCoins(String uid) async {
    final prefs = await _getPrefs();
    await prefs.setInt('$_locallyEarnedCoinsKey$uid', 0);
    LoggerService.info('LocalStorage: Reset local coins for $uid to 0.');
  }

  Future<void> setDailySyncStartTime(String uid, int timestampMillis) async {
    final prefs = await _getPrefs();
    await prefs.setInt('$_dailySyncStartTimeKey$uid', timestampMillis);
    LoggerService.info('LocalStorage: Set daily sync start time for $uid to $timestampMillis.');
  }

  Future<int?> getDailySyncStartTime(String uid) async {
    final prefs = await _getPrefs();
    return prefs.getInt('$_dailySyncStartTimeKey$uid');
  }

  Future<void> clearDailySyncStartTime(String uid) async {
    final prefs = await _getPrefs();
    await prefs.remove('$_dailySyncStartTimeKey$uid');
    LoggerService.info('LocalStorage: Cleared daily sync start time for $uid.');
  }

  Future<void> setLastActiveDate(String uid, String dateString) async {
    final prefs = await _getPrefs();
    await prefs.setString('$_lastActiveDateKey$uid', dateString);
    LoggerService.info('LocalStorage: Set last active date for $uid to $dateString.');
  }

  Future<String?> getLastActiveDate(String uid) async {
    final prefs = await _getPrefs();
    return prefs.getString('$_lastActiveDateKey$uid');
  }
}
