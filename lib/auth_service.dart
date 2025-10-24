import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // FIX: Corrected import path
import 'models/auth_result.dart'; // Import AuthResult
import 'device_service.dart'; // Import DeviceService
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore queries
import 'logger_service.dart'; // Import LoggerService
import 'firebase_project_config_service.dart'; // Import FirebaseProjectConfigService
// import 'logger_service.dart'; // Import LoggerService
import 'package:rxdart/rxdart.dart'; // Import RxDart
import 'package:firebase_messaging/firebase_messaging.dart'; // Import FirebaseMessaging

class AuthService {
  // Temporary flag to enable/disable device ID check for debugging
  static final bool _enableDeviceIdCheck = false; // Set to false to disable for now

  // BehaviorSubject to emit the current authenticated user (and their project ID) across all projects
  final _userSubject = BehaviorSubject<AuthResult?>.seeded(null);

  // Private constructor
  AuthService._internal() {
    _initializeAuthStateListeners();
  }

  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  // Factory constructor to return the singleton instance
  factory AuthService() => _instance;

  // Method to initialize auth state listeners for all projects
  void _initializeAuthStateListeners() {
    for (String projectId in FirebaseProjectConfigService.projectIds) {
      final FirebaseAuth authInstance = FirebaseAuth.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
      authInstance.authStateChanges().listen((User? user) {
        if (user != null) {
          _userSubject.add(AuthResult.success(uid: user.uid, projectId: projectId));
          _updateFCMTokenForUser(user.uid, projectId); // Update FCM token on auth state change
        } else if (_userSubject.value?.uid == null) { // Check only UID for simplicity in nulling out
          _userSubject.add(null);
        }
      });
    }
    // Also listen to the default instance for good measure, if not covered by sharded projects
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // For the default instance, we don't have a specific projectId from sharding logic
        _userSubject.add(AuthResult.success(uid: user.uid, projectId: null));
        // We cannot update FCM token for a default project without knowing the shard
      } else if (_userSubject.value?.uid == null) { // Check only UID for simplicity in nulling out
        _userSubject.add(null);
      }
    });
  }

  // Register with email and password
  Future<AuthResult> registerWithEmailAndPassword(String email, String password, {String? referralCode}) async {
    try {
      final String? deviceId = await DeviceService().getDeviceId();
      if (deviceId == null) {
        return AuthResult.failure(message: 'Could not get device ID. Please try again.');
      }

      // Conditionally perform device ID check based on _enableDeviceIdCheck flag
      if (_enableDeviceIdCheck) {
        for (String projectId in FirebaseProjectConfigService.projectIds) {
          final FirebaseFirestore firestoreInstance = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
          final deviceCheck = await firestoreInstance.collection('users').where('deviceId', isEqualTo: deviceId).limit(1).get();
          if (deviceCheck.docs.isNotEmpty) {
            return AuthResult.failure(message: 'Only one account per device is allowed.');
          }
        }
      }

      // Determine which project to shard the new user to
      final String targetProjectId = await FirebaseProjectConfigService.getNextProjectIdForNewUser();
      LoggerService.info('AuthService: Registering new user ($email) to project: $targetProjectId');
      final FirebaseAuth targetAuth = FirebaseAuth.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(targetProjectId));
      final FirebaseFirestore targetFirestore = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(targetProjectId));

      UserCredential result = await targetAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
          LoggerService.info('AuthService: User created in project $targetProjectId with UID: ${user.uid}');
          final String? fcmToken = await FirebaseMessaging.instance.getToken(); // Get FCM token
          await UserService(firestoreInstance: targetFirestore).createUserData(user.uid, email, referralCode: referralCode, deviceId: deviceId, projectId: targetProjectId, fcmToken: fcmToken);
          LoggerService.info('AuthService: User data created in Firestore for UID: ${user.uid}');
          _userSubject.add(AuthResult.success(uid: user.uid, projectId: targetProjectId)); // Add the newly registered user to the stream
          return AuthResult.success(uid: user.uid, projectId: targetProjectId);
        }
        LoggerService.warning('AuthService: User creation failed unexpectedly for $email.');
        return AuthResult.failure(message: 'User creation failed unexpectedly.');
    } on FirebaseAuthException catch (e, s) {
      LoggerService.error('AuthService: FirebaseAuthException during registration for $email. Code: ${e.code}', e, s);
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'FirebaseAuthException during registration');
      return AuthResult.failure(message: _getFriendlyErrorMessage(e.code));
    } catch (e, s) {
      LoggerService.error('AuthService: Unknown error during registration for $email', e, s);
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Unknown error during registration');
      return AuthResult.failure(message: 'An unexpected error occurred during registration.');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    LoggerService.info('AuthService: Attempting to sign in user: $email');
    for (String projectId in FirebaseProjectConfigService.projectIds) {
      try {
        LoggerService.info('AuthService: Trying to sign in $email in project: $projectId');
        final FirebaseAuth targetAuth = FirebaseAuth.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
        UserCredential result = await targetAuth.signInWithEmailAndPassword(email: email, password: password);
        User? user = result.user;
        if (user != null) {
          LoggerService.info('AuthService: Successfully signed in $email to project: $projectId with UID: ${user.uid}');
          _userSubject.add(AuthResult.success(uid: user.uid, projectId: projectId)); // Add the newly logged-in user to the stream
          _updateFCMTokenForUser(user.uid, projectId); // Update FCM token on successful sign-in
          return AuthResult.success(uid: user.uid, projectId: projectId);
        }
      } on FirebaseAuthException catch (e, s) {
        LoggerService.error('AuthService: FirebaseAuthException during sign-in for $email in project $projectId. Code: ${e.code}', e, s);
        // Continue to next project if the error is related to credentials not matching in this specific project
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          LoggerService.warning('AuthService: Sign-in failed for $email in project $projectId with code: ${e.code}. Continuing to next project.');
        } else {
          LoggerService.error('AuthService: FirebaseAuthException during sign-in in project $projectId', e, s);
          FirebaseCrashlytics.instance.recordError(e, s, reason: 'FirebaseAuthException during sign-in in project $projectId');
          return AuthResult.failure(message: _getFriendlyErrorMessage(e.code));
        }
      } catch (e, s) {
        LoggerService.error('AuthService: Unknown error during sign-in in project $projectId', e, s);
        FirebaseCrashlytics.instance.recordError(e, s, reason: 'Unknown error during sign-in in project $projectId');
        return AuthResult.failure(message: 'An unexpected error occurred during sign-in.');
      }
    }
    LoggerService.warning('AuthService: No user found with $email and password across all projects.');
    return AuthResult.failure(message: 'No user found with that email and password across all projects.');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      LoggerService.info('Attempting to sign out current user.');
      // Sign out from all initialized FirebaseAuth instances
      for (String projectId in FirebaseProjectConfigService.projectIds) {
        final FirebaseAuth authInstance = FirebaseAuth.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
        await authInstance.signOut();
      }
      await FirebaseAuth.instance.signOut(); // Also sign out from the default instance
      _userSubject.add(null); // Emit null to indicate no active user
      LoggerService.info('User signed out successfully from all projects.');
    } catch (e, s) {
      LoggerService.error('Error during sign-out', e, s);
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error during sign-out');
    }
  }

  // Get current user (from the BehaviorSubject)
  AuthResult? getCurrentUser() {
    LoggerService.info('Getting current user from AuthService BehaviorSubject.');
    return _userSubject.value;
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      LoggerService.info('Sending password reset email to: $email');
      // Attempt to send reset email via the default instance, or the active one if available.
      // This might need refinement for sharded projects if a user only exists in a specific shard.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      LoggerService.info('Password reset email sent to: $email');
      return AuthResult.success(uid: '');
    } on FirebaseAuthException catch (e, s) {
      LoggerService.error('FirebaseAuthException during password reset', e, s);
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'FirebaseAuthException during password reset');
      return AuthResult.failure(message: _getFriendlyErrorMessage(e.code));
    } catch (e, s) {
      LoggerService.error('Unknown error during password reset', e, s);
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Unknown error during password reset');
      return AuthResult.failure(message: 'An unexpected error occurred during password reset.');
    }
  }

  // Helper to get user-friendly error messages
  String _getFriendlyErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'An unknown authentication error occurred.';
    }
  }

  // Auth change user stream (exposes the BehaviorSubject stream)
  Stream<AuthResult?> get user {
    LoggerService.info('AuthService.user stream accessed. Current value: ${_userSubject.value?.uid}');
    return _userSubject.stream;
  }

  // Helper to update FCM token in Firestore
  Future<void> _updateFCMTokenForUser(String uid, String projectId) async {
    try {
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        final FirebaseFirestore firestoreInstance = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
        await UserService(firestoreInstance: firestoreInstance).updateUserData(uid, {'fcmToken': fcmToken});
        LoggerService.info('FCM Token updated for user $uid in project $projectId: $fcmToken');
      } else {
        LoggerService.warning('FCM Token is null for user $uid in project $projectId.');
      }
    } catch (e, s) {
      LoggerService.error('Error updating FCM token for user $uid in project $projectId: $e', e, s);
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error updating FCM token');
    }
  }
}
