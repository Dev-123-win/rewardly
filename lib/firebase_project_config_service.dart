import 'package:firebase_core/firebase_core.dart';
import 'logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'firebase_configs/firebase_options_prod_01.dart' as prod01_options;
import 'firebase_configs/firebase_options_prod_02.dart' as prod02_options;
import 'firebase_configs/firebase_options_prod_03.dart' as prod03_options;
import 'firebase_configs/firebase_options_prod_04.dart' as prod04_options;
import 'firebase_configs/firebase_options_prod_05.dart' as prod05_options;

class FirebaseProjectConfigService {
  static final Map<String, FirebaseOptions> _projectOptions = {
    'rewardly-new': prod01_options.DefaultFirebaseOptions.currentPlatform,
    'rewardly-9fe76': prod02_options.DefaultFirebaseOptions.currentPlatform,
    'rewardly-5': prod03_options.DefaultFirebaseOptions.currentPlatform,
    'rewardly-4': prod04_options.DefaultFirebaseOptions.currentPlatform,
    'rewardly-3': prod05_options.DefaultFirebaseOptions.currentPlatform,
  };

  static List<String> get projectIds => _projectOptions.keys.toList();

  static FirebaseOptions? getOptionsForProject(String projectId) {
    return _projectOptions[projectId];
  }

  static Future<void> initializeAllFirebaseProjects() async {
    // Initialize the default Firebase app first
    await Firebase.initializeApp(
      options: prod05_options.DefaultFirebaseOptions.currentPlatform,
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
  }

  // Get a specific FirebaseApp instance by its name (projectId)
  static FirebaseApp getFirebaseApp(String projectId) {
    return Firebase.app(projectId);
  }

  // Simple round-robin sharding logic for new users
  static Future<String> getNextProjectIdForNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    _lastUsedProjectIndex = prefs.getInt(_lastUsedProjectIndexKey) ?? -1; // Load last used index

    _lastUsedProjectIndex = (_lastUsedProjectIndex + 1) % _projectOptions.length;
    await prefs.setInt(_lastUsedProjectIndexKey, _lastUsedProjectIndex); // Save new index

    return _projectOptions.keys.elementAt(_lastUsedProjectIndex);
  }

  static int _lastUsedProjectIndex = -1; // Initialize to -1 so first call gets index 0
  static const String _lastUsedProjectIndexKey = 'lastUsedProjectIndex';
}
