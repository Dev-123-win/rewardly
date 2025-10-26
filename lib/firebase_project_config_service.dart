import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Import for defaultTargetPlatform
import 'logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'firebase_configs/firebase_options_prod_01.dart' as prod01_options;
import 'firebase_configs/firebase_options_prod_02.dart' as prod02_options;
import 'firebase_configs/firebase_options_prod_03.dart' as prod03_options;
import 'firebase_configs/firebase_options_prod_04.dart' as prod04_options;
import 'firebase_configs/firebase_options_prod_05.dart' as prod05_options;
import 'firebase_configs/firebase_options_prod_06.dart' as prod06_options;
import 'firebase_configs/firebase_options_prod_07.dart' as prod07_options;
import 'firebase_configs/firebase_options_prod_08.dart' as prod08_options;
import 'firebase_configs/firebase_options_prod_09.dart' as prod09_options;
import 'firebase_configs/firebase_options_prod_10.dart' as prod10_options;
import 'firebase_configs/firebase_options_prod_11.dart' as prod11_options;
import 'firebase_configs/firebase_options_prod_12.dart' as prod12_options;
import 'firebase_configs/firebase_options_prod_13.dart' as prod13_options;
import 'firebase_configs/firebase_options_prod_14.dart' as prod14_options;
import 'firebase_configs/firebase_options_prod_15.dart' as prod15_options;

class FirebaseProjectConfigService {
  static final Map<String, FirebaseOptions> _projectOptions = {
    'rewardly-new': prod01_options.DefaultFirebaseOptions.android,
    'rewardly-9fe76': prod02_options.DefaultFirebaseOptions.android,
    'rewardly-5': prod03_options.DefaultFirebaseOptions.android,
    'rewardly-4': prod04_options.DefaultFirebaseOptions.android,
    'rewardly-3': prod05_options.DefaultFirebaseOptions.android,
    'rewardly-prod06': prod06_options.DefaultFirebaseOptions.android,
    'rewardly-prod07': prod07_options.DefaultFirebaseOptions.android,
    'rewardly-prod08': prod08_options.DefaultFirebaseOptions.android,
    'rewardly-prod09': prod09_options.DefaultFirebaseOptions.android,
    'rewardly-prod10': prod10_options.DefaultFirebaseOptions.android,
    'rewardly-prod11': prod11_options.DefaultFirebaseOptions.android,
    'rewardly-prod12': prod12_options.DefaultFirebaseOptions.android,
    'rewardly-prod13': prod13_options.DefaultFirebaseOptions.android,
    'rewardly-prod14': prod14_options.DefaultFirebaseOptions.android,
    'rewardly-prod15': prod15_options.DefaultFirebaseOptions.android,
  };

  static List<String> get projectIds => _projectOptions.keys.toList();

  static FirebaseOptions? getOptionsForProject(String projectId) {
    return _projectOptions[projectId];
  }

  static Future<void> initializeAllFirebaseProjects() async {
    // Only attempt to initialize Firebase for Android platform if running on Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Initialize the default Firebase app first
      await Firebase.initializeApp(
        options: prod05_options.DefaultFirebaseOptions.android,
      );
      for (String projectId in _projectOptions.keys) {
        final options = _projectOptions[projectId];
        if (options != null) {
          try {
            await Firebase.initializeApp(
              name: projectId,
              options: options,
            );
          } catch (e) {
            LoggerService.error('Failed to initialize Firebase project: $projectId', e);
          }
        }
      }
    } else {
      LoggerService.info('Firebase initialization skipped for unsupported platform: $defaultTargetPlatform');
    }
  }

  // Get a specific FirebaseApp instance by its name (projectId)
  static FirebaseApp getFirebaseApp(String projectId) {
    return Firebase.app(projectId);
  }

  // Simple round-robin sharding logic for new users
  static Future<String> getNextProjectIdForNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    int currentLastUsedIndex = prefs.getInt(_lastUsedProjectIndexKey) ?? -1; // Load last used index
    LoggerService.debug('FirebaseProjectConfigService: Current lastUsedProjectIndex: $currentLastUsedIndex');

    _lastUsedProjectIndex = (currentLastUsedIndex + 1) % _projectOptions.length;
    await prefs.setInt(_lastUsedProjectIndexKey, _lastUsedProjectIndex); // Save new index

    String assignedProjectId = _projectOptions.keys.elementAt(_lastUsedProjectIndex);
    LoggerService.debug('FirebaseProjectConfigService: New lastUsedProjectIndex: $_lastUsedProjectIndex, Assigned Project ID: $assignedProjectId');
    return assignedProjectId;
  }

  static int _lastUsedProjectIndex = -1; // Initialize to -1 so first call gets index 0
  static const String _lastUsedProjectIndexKey = 'lastUsedProjectIndex';
}
