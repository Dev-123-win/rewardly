import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Import FirebaseApp
import 'package:rewardly_app/firebase_project_config_service.dart'; // Import FirebaseProjectConfigService
import '../user_service.dart';
import '../logger_service.dart'; // Import LoggerService

class UserDataProvider with ChangeNotifier {
  // The default UserService is no longer needed here, as we'll use a sharded one.
  // final UserService _userService = UserService();
  DocumentSnapshot? _userData;
  bool _isLoading = true;

  String? _userProjectId; // Store the project ID for the current user
  UserService? _shardedUserService; // UserService instance for the specific project

  DocumentSnapshot? get userData => _userData;
  bool get isLoading => _isLoading;
  UserService? get shardedUserService => _shardedUserService; // Expose the sharded UserService

  UserDataProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _loadUserData(user);
    });
  }

  Future<void> _loadUserData(User? user) async {
    _isLoading = true;
    notifyListeners();

    if (user != null) {
      try {
        // First, get the user's project ID from the default Firestore instance
        // This assumes the user's document in the default project stores their assigned projectId
        final defaultFirestore = FirebaseFirestore.instance;
        final userDocInDefaultProject = await defaultFirestore.collection('users').doc(user.uid).get();

        if (userDocInDefaultProject.exists && userDocInDefaultProject.data()?['projectId'] != null) {
          _userProjectId = userDocInDefaultProject.data()?['projectId'] as String?;
          // Initialize the sharded UserService with the correct Firestore instance
          final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(_userProjectId!);
          final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
          _shardedUserService = UserService(firestoreInstance: shardedFirestore);

          // Now listen to the user data from the correct sharded project
          _shardedUserService!.getUserData(user.uid).listen((snapshot) {
            _userData = snapshot;
            _isLoading = false;
            notifyListeners();
          });
        } else {
          // Fallback: If projectId is not in the default project, search all shards
          LoggerService.warning('User document for ${user.uid} in default project does not contain projectId or document not found. Searching all shards.');
          String? foundProjectId;
          for (String projectId in FirebaseProjectConfigService.projectIds) {
            try {
              final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(projectId);
              final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
              final shardedUserDoc = await shardedFirestore.collection('users').doc(user.uid).get();
              if (shardedUserDoc.exists) {
                foundProjectId = projectId;
                break; // Found the user's project
              }
            } catch (e, s) {
              LoggerService.error('Error searching shard $projectId for user ${user.uid}', e, s);
            }
          }

          if (foundProjectId != null) {
            _userProjectId = foundProjectId;
            final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(_userProjectId!);
            final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
            _shardedUserService = UserService(firestoreInstance: shardedFirestore);

            _shardedUserService!.getUserData(user.uid).listen((snapshot) {
              _userData = snapshot;
              _isLoading = false;
              notifyListeners();
            });
            LoggerService.info('User ${user.uid} found in shard: $_userProjectId');
          } else {
            LoggerService.error('User document for ${user.uid} not found in any sharded project.');
            _resetState();
          }
        }
      } catch (e, stackTrace) {
        LoggerService.error('Error loading user data for ${user.uid}', e, stackTrace);
        _resetState();
      }
    } else {
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
      LoggerService.warning('Attempted to update coins without a logged-in user or sharded UserService.');
    }
  }
}
