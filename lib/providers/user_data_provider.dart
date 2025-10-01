import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Remove the authStateChanges listener from the constructor
  UserDataProvider();

  // New method to update the user, called by ChangeNotifierProxyProvider
  void updateUser(User? user) {
    _loadUserData(user);
  }

  Future<void> _loadUserData(User? user) async {
    _isLoading = true;
    notifyListeners();

    if (user != null) {
      try {
        LoggerService.info('UserDataProvider: Attempting to load data for user ${user.uid}');
        // First, get the user's project ID from the default Firestore instance
        final defaultFirestore = FirebaseFirestore.instance;
        final userDocInDefaultProject = await defaultFirestore.collection('users').doc(user.uid).get();

        if (userDocInDefaultProject.exists) {
          LoggerService.info('UserDataProvider: User document exists in default project for ${user.uid}.');
          if (userDocInDefaultProject.data()?['projectId'] != null) {
            _userProjectId = userDocInDefaultProject.data()?['projectId'] as String?;
            LoggerService.info('UserDataProvider: Found projectId: $_userProjectId for user ${user.uid} in default project.');
            // Initialize the sharded UserService with the correct Firestore instance
            final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(_userProjectId!);
            final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
            _shardedUserService = UserService(firestoreInstance: shardedFirestore);

            // Now listen to the user data from the correct sharded project
            _shardedUserService!.getUserData(user.uid).listen((snapshot) {
              _userData = snapshot;
              _isLoading = false;
              notifyListeners();
              LoggerService.info('UserDataProvider: Loaded user data from shard $_userProjectId for ${user.uid}. Data exists: ${_userData?.exists}');
            });
          } else {
            LoggerService.warning('UserDataProvider: User document for ${user.uid} in default project exists but does NOT contain projectId. Falling back to shard search.');
            await _searchAllShardsForUser(user.uid);
          }
        } else {
          LoggerService.warning('UserDataProvider: User document for ${user.uid} NOT found in default project. Falling back to shard search.');
          await _searchAllShardsForUser(user.uid);
        }
      } catch (e, stackTrace) {
        LoggerService.error('UserDataProvider: Error loading user data for ${user.uid}', e, stackTrace);
        _resetState();
      }
    } else {
      LoggerService.info('UserDataProvider: User is null, resetting state.');
      _resetState();
    }
  }

  Future<void> _searchAllShardsForUser(String uid) async {
    String? foundProjectId;
    for (String projectId in FirebaseProjectConfigService.projectIds) {
      try {
        final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(projectId);
        final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
        final shardedUserDoc = await shardedFirestore.collection('users').doc(uid).get();
        if (shardedUserDoc.exists) {
          foundProjectId = projectId;
          LoggerService.info('UserDataProvider: User $uid found in shard: $projectId during fallback search.');
          // Update default Firestore with projectId for future quick lookups
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'projectId': projectId,
            'email': FirebaseAuth.instance.currentUser?.email, // Assuming email is available
          }, SetOptions(merge: true));
          break; // Found the user's project
        }
      } catch (e, s) {
        LoggerService.error('UserDataProvider: Error searching shard $projectId for user $uid', e, s);
      }
    }

    if (foundProjectId != null) {
      _userProjectId = foundProjectId;
      final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(_userProjectId!);
      final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
      _shardedUserService = UserService(firestoreInstance: shardedFirestore);

      _shardedUserService!.getUserData(uid).listen((snapshot) {
        _userData = snapshot;
        _isLoading = false;
        notifyListeners();
        LoggerService.info('UserDataProvider: Loaded user data from shard $_userProjectId for $uid after fallback. Data exists: ${_userData?.exists}');
      });
    } else {
      LoggerService.error('UserDataProvider: User document for $uid not found in any sharded project after fallback search.');
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _shardedUserService != null) {
      await _shardedUserService!.updateCoins(user.uid, amount);
      // No need to explicitly reload, as the stream listener will handle updates
    } else {
      LoggerService.warning('UserDataProvider: Attempted to update coins without a logged-in user or sharded UserService.');
    }
  }
}
