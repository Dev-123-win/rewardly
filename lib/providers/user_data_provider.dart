import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Import FirebaseApp
import '../firebase_project_config_service.dart'; // Import FirebaseProjectConfigService
import '../user_service.dart';
import '../logger_service.dart'; // Import LoggerService

class UserDataProvider with ChangeNotifier {
  DocumentSnapshot? _userData;
  bool _isLoading = true;

  String? _userProjectId; // Store the project ID for the current user
  UserService? _shardedUserService; // UserService instance for the specific project

  DocumentSnapshot? get userData => _userData;
  bool get isLoading => _isLoading;
  UserService? get shardedUserService => _shardedUserService; // Expose the sharded UserService

  int _adSpinsEarnedTodayInApp = 0; // In-app only field
  int get adSpinsEarnedToday => _adSpinsEarnedTodayInApp;

  Map<String, dynamic>? get preferredBankDetails => (_userData?.data() as Map<String, dynamic>?)?['preferredBankDetails'] as Map<String, dynamic>?;
  Map<String, dynamic>? get preferredUpiDetails => (_userData?.data() as Map<String, dynamic>?)?['preferredUpiDetails'] as Map<String, dynamic>?;
  String? get lastUsedWithdrawalMethod => (_userData?.data() as Map<String, dynamic>?)?['lastUsedWithdrawalMethod'] as String?;

  // Remove the authStateChanges listener from the constructor
  UserDataProvider();

  // New method to update the user, called by ChangeNotifierProxyProvider
  void updateUser(String? uid, {String? projectId}) {
    _loadUserData(uid, projectId: projectId);
  }

  Future<void> _loadUserData(String? uid, {String? projectId}) async {
    _isLoading = true;
    notifyListeners();

    if (uid != null) {
      try {
        LoggerService.info('UserDataProvider: Attempting to load data for user $uid');

        // Use the provided projectId if available, otherwise try to find it
        if (projectId != null) {
          _userProjectId = projectId;
          LoggerService.info('UserDataProvider: Using provided projectId: $_userProjectId for user $uid.');
        } else {
          // Fallback to searching all shards if projectId is not provided
          LoggerService.warning('UserDataProvider: No projectId provided for user $uid. Falling back to shard search.');
          await _searchAllShardsForUser(uid);
        }

        if (_userProjectId != null) {
          // Initialize the sharded UserService with the correct Firestore instance
          final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(_userProjectId!);
          final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
          _shardedUserService = UserService(firestoreInstance: shardedFirestore);

          // Now listen to the user data from the correct sharded project
          LoggerService.debug('UserDataProvider: Setting up stream listener for user $uid in project $_userProjectId.');
          _shardedUserService!.getUserData(uid).listen(
            (snapshot) {
              _userData = snapshot;
              _isLoading = false;
              notifyListeners();
              LoggerService.info('UserDataProvider: Loaded user data from shard $_userProjectId for $uid. Data exists: ${_userData?.exists}');
            },
            onError: (error, stackTrace) {
              LoggerService.error('UserDataProvider: Stream listener error for user $uid in project $_userProjectId', error, stackTrace);
              _resetState();
            },
            onDone: () {
              LoggerService.debug('UserDataProvider: Stream listener for user $uid in project $_userProjectId is done.');
            },
          );
        } else {
          LoggerService.error('UserDataProvider: Could not determine projectId for user $uid. Resetting state.');
          _resetState();
        }
      } catch (e, stackTrace) {
        LoggerService.error('UserDataProvider: Error in _loadUserData for $uid', e, stackTrace);
        _resetState();
      }
    } else {
      LoggerService.info('UserDataProvider: User is null, resetting state.');
      _resetState();
    }
  }

  @override
  void dispose() {
    // Ensure any active streams are cancelled to prevent memory leaks
    // This might require storing the StreamSubscription and cancelling it here.
    // For now, assuming the stream is managed by the Provider itself.
    super.dispose();
  }

  Future<void> _searchAllShardsForUser(String uid) async {
    String? foundProjectId;
    LoggerService.debug('UserDataProvider: Starting fallback search for user $uid across all shards.');
    for (String projectId in FirebaseProjectConfigService.projectIds) {
      try {
        LoggerService.debug('UserDataProvider: Checking shard $projectId for user $uid.');
        final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(projectId);
        final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
        final shardedUserDoc = await shardedFirestore.collection('users').doc(uid).get();
        if (shardedUserDoc.exists) {
          foundProjectId = projectId;
          LoggerService.info('UserDataProvider: User $uid found in shard: $projectId during fallback search.');
          break; // Found the user's project
        }
      } on Exception catch (e, s) { // Catch specific exceptions for better logging
        LoggerService.error('UserDataProvider: Exception searching shard $projectId for user $uid', e, s);
      } catch (e, s) {
        LoggerService.error('UserDataProvider: Unknown error searching shard $projectId for user $uid', e, s);
      }
    }

    if (foundProjectId != null) {
      _userProjectId = foundProjectId;
    } else {
      LoggerService.error('UserDataProvider: User document for $uid not found in any sharded project after fallback search. Resetting state.');
      _resetState();
    }
  }

  void _resetState() {
    _userData = null;
    _userProjectId = null;
    _shardedUserService = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserCoins(int amount) async {
    if (_userData?.id != null && _shardedUserService != null) {
      await _shardedUserService!.updateCoins(_userData!.id, amount);
      // No need to explicitly reload, as the stream listener will handle updates
    } else {
      LoggerService.warning('UserDataProvider: Attempted to update coins without a valid user ID or sharded UserService. User ID: ${_userData?.id}, ShardedUserService: ${_shardedUserService != null}');
    }
  }

  Future<void> decrementFreeSpinWheelSpins() async {
    if (_userData?.id != null && _shardedUserService != null) {
      await _shardedUserService!.decrementFreeSpinWheelSpins(_userData!.id);
    } else {
      LoggerService.warning('UserDataProvider: Attempted to decrement free spins without a valid user ID or sharded UserService.');
    }
  }

  Future<void> incrementAdSpinWheelSpins(int amount) async {
    _adSpinsEarnedTodayInApp += amount;
    notifyListeners();
    LoggerService.info('UserDataProvider: In-app ad spins incremented by $amount. Current: $_adSpinsEarnedTodayInApp');
  }

  Future<void> decrementAdSpinWheelSpins() async {
    if (_adSpinsEarnedTodayInApp > 0) {
      _adSpinsEarnedTodayInApp--;
      notifyListeners();
      LoggerService.info('UserDataProvider: In-app ad spins decremented. Current: $_adSpinsEarnedTodayInApp');
    } else {
      LoggerService.warning('UserDataProvider: Attempted to decrement ad spins below zero.');
    }
  }

  Future<void> resetSpinWheelDailyCounts() async {
    if (_userData?.id != null && _shardedUserService != null) {
      await _shardedUserService!.resetSpinWheelDailyCounts(_userData!.id);
    } else {
      LoggerService.warning('UserDataProvider: Attempted to reset daily spin counts without a valid user ID or sharded UserService.');
    }
    _adSpinsEarnedTodayInApp = 0; // Reset in-app count as well
    notifyListeners();
    LoggerService.info('UserDataProvider: In-app ad spins reset to $_adSpinsEarnedTodayInApp.');
  }

  // Reset daily ad watch count if the date has changed
  Future<void> resetDailyAdWatchCount() async {
    if (_userData?.id == null || _shardedUserService == null) {
      LoggerService.warning('UserDataProvider: Cannot reset daily ad watch count without a valid user ID or sharded UserService.');
      return;
    }

    final String uid = _userData!.id;
    final Map<String, dynamic>? data = _userData!.data() as Map<String, dynamic>?;

    if (data == null) {
      LoggerService.warning('UserDataProvider: User data is null for $uid. Cannot reset daily ad watch count.');
      return;
    }

    final String lastAdWatchDate = data['lastAdWatchDate'] as String? ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastAdWatchDate != today) {
      await _shardedUserService!.updateUserData(uid, {
        'adsWatchedToday': 0,
        'lastAdWatchDate': today,
      });
      LoggerService.info('UserDataProvider: Daily ad watch count reset for user $uid.');
    } else {
      LoggerService.debug('UserDataProvider: Daily ad watch count not reset for user $uid, still same day.');
    }
  }

  // Update ads watched today (increment and update date)
  Future<void> updateAdsWatchedToday() async {
    if (_userData?.id == null || _shardedUserService == null) {
      LoggerService.warning('UserDataProvider: Cannot update ads watched today without a valid user ID or sharded UserService.');
      return;
    }

    final String uid = _userData!.id;
    final Map<String, dynamic>? data = _userData!.data() as Map<String, dynamic>?;

    if (data == null) {
      LoggerService.warning('UserDataProvider: User data is null for $uid. Cannot update ads watched today.');
      return;
    }

    final String lastAdWatchDate = data['lastAdWatchDate'] as String? ?? '';
    final today = DateTime.now().toIso8601String().substring(0, 10);
    int currentAdsWatched = data['adsWatchedToday'] as int? ?? 0;

    if (lastAdWatchDate != today) {
      // If it's a new day, reset count to 1
      await _shardedUserService!.updateUserData(uid, {
        'adsWatchedToday': 1,
        'lastAdWatchDate': today,
      });
      LoggerService.info('UserDataProvider: First ad watched today for user $uid.');
    } else {
      // If same day, increment count
      await _shardedUserService!.updateUserData(uid, {
        'adsWatchedToday': FieldValue.increment(1),
        'lastAdWatchDate': today, // Ensure date is always updated
      });
      LoggerService.info('UserDataProvider: Ad watched for user $uid. Total today: ${currentAdsWatched + 1}');
    }
  }

  // Track daily activity and check for referrer reward.
  // WARNING: This is highly insecure and should ideally be handled server-side.
  // Any client-side logic can be tampered with.
  Future<void> checkDailyActivityAndReferralReward() async {
    if (_userData?.id == null || _shardedUserService == null) {
      LoggerService.warning('UserDataProvider: Cannot check daily activity without a valid user ID or sharded UserService.');
      return;
    }

    final String uid = _userData!.id;
    final Map<String, dynamic>? data = _userData!.data() as Map<String, dynamic>?;

    if (data == null) {
      LoggerService.warning('UserDataProvider: User data is null for $uid. Cannot check daily activity.');
      return;
    }

    final String lastActiveDate = data['lastActiveDate'] as String? ?? '';
    int daysActiveCount = data['daysActiveCount'] as int? ?? 0;
    final String? referredBy = data['referredBy'] as String?;
    final bool referrerAwarded = data['referrerAwarded'] as bool? ?? false;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastActiveDate != today) {
      // New distinct day, increment count and update last active date
      daysActiveCount++;
      await _shardedUserService!.updateUserData(uid, {
        'daysActiveCount': daysActiveCount,
        'lastActiveDate': today,
      });
      LoggerService.info('UserDataProvider: User $uid active for $daysActiveCount distinct days.');

      // Check for referrer reward
      if (referredBy != null && referredBy.isNotEmpty && daysActiveCount >= 3 && !referrerAwarded) {
        LoggerService.info('UserDataProvider: User $uid met referral reward criteria. Awarding referrer $referredBy.');
        await _shardedUserService!.awardReferrerCoins(uid, referredBy);
      }
    } else {
      LoggerService.debug('UserDataProvider: User $uid already active today.');
    }
  }
}
