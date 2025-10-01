import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // FIX: Corrected import path
import 'models/auth_result.dart'; // Import AuthResult
import 'device_service.dart'; // Import DeviceService
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore queries
import 'firebase_project_config_service.dart'; // Import FirebaseProjectConfigService
import 'logger_service.dart'; // Import LoggerService
import 'package:rxdart/rxdart.dart'; // Import RxDart

class AuthService {
  // Use a nullable FirebaseAuth to represent the active instance, default to the main instance.
  // This will be updated to the sharded project's instance upon successful login.
  // FirebaseAuth? _activeFirebaseAuth = FirebaseAuth.instance; // No longer directly used for stream

  // BehaviorSubject to emit the current authenticated user across all projects
  final _userSubject = BehaviorSubject<User?>.seeded(null); // FIX: Using .seeded() constructor

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
          LoggerService.info('Auth state changed: User ${user.uid} detected in project: $projectId');
          _userSubject.add(user);
        } else if (_userSubject.value?.uid == null || _userSubject.value?.email == null) {
          // Only set to null if there's no other active user or it's currently null
          // This prevents a sign-out from one shard from immediately signing out all if another is active.
          // More complex logic might be needed here for true multi-shard sign-out management.
          LoggerService.info('Auth state changed: No user detected in project: $projectId');
          _userSubject.add(null);
        }
      });
    }
    // Also listen to the default instance for good measure, if not covered by sharded projects
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        LoggerService.info('Auth state changed: User ${user.uid} detected in default project.');
        _userSubject.add(user);
      } else if (_userSubject.value?.uid == null || _userSubject.value?.email == null) {
        LoggerService.info('Auth state changed: No user detected in default project.');
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

      // Revert temporary change: iterate through all projects for device ID check
      for (String projectId in FirebaseProjectConfigService.projectIds) {
        LoggerService.info('Checking device ID ($deviceId) in project: $projectId');
        final FirebaseFirestore firestoreInstance = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
        final deviceCheck = await firestoreInstance.collection('users').where('deviceId', isEqualTo: deviceId).limit(1).get();
        if (deviceCheck.docs.isNotEmpty) {
          LoggerService.warning('Device ID ($deviceId) already exists in project: $projectId');
          return AuthResult.failure(message: 'Only one account per device is allowed.');
        }
      }

      // Determine which project to shard the new user to
      final String targetProjectId = await FirebaseProjectConfigService.getNextProjectIdForNewUser();
      LoggerService.info('Registering new user ($email) to project: $targetProjectId');
      final FirebaseAuth targetAuth = FirebaseAuth.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(targetProjectId));
      final FirebaseFirestore targetFirestore = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(targetProjectId));

      UserCredential result = await targetAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        LoggerService.info('User created in project $targetProjectId with UID: ${user.uid}');
        await UserService(firestoreInstance: targetFirestore).createUserData(user.uid, email, referralCode: referralCode, deviceId: deviceId, projectId: targetProjectId);
        LoggerService.info('User data created in Firestore for UID: ${user.uid}');
        _userSubject.add(user); // Add the newly registered user to the stream
        return AuthResult.success(uid: user.uid);
      }
      return AuthResult.failure(message: 'User creation failed unexpectedly.');
    } on FirebaseAuthException catch (e, s) {
      LoggerService.error('FirebaseAuthException during registration', e, s);
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'FirebaseAuthException during registration');
      return AuthResult.failure(message: _getFriendlyErrorMessage(e.code));
    } catch (e, s) {
      LoggerService.error('Unknown error during registration', e, s);
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Unknown error during registration');
      return AuthResult.failure(message: 'An unexpected error occurred during registration.');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    LoggerService.info('Attempting to sign in user: $email');
    for (String projectId in FirebaseProjectConfigService.projectIds) {
      try {
        LoggerService.info('Trying to sign in $email in project: $projectId');
        final FirebaseAuth targetAuth = FirebaseAuth.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
        UserCredential result = await targetAuth.signInWithEmailAndPassword(email: email, password: password);
        User? user = result.user;
        if (user != null) {
          LoggerService.info('Successfully signed in $email to project: $projectId with UID: ${user.uid}');
          _userSubject.add(user); // Add the newly logged-in user to the stream
          return AuthResult.success(uid: user.uid);
        }
      } on FirebaseAuthException catch (e, s) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          LoggerService.info('Sign-in failed for $email in project $projectId with code: ${e.code}. Continuing to next project.');
        } else {
          LoggerService.error('FirebaseAuthException during sign-in in project $projectId', e, s);
          FirebaseCrashlytics.instance.recordError(e, s, reason: 'FirebaseAuthException during sign-in in project $projectId');
          return AuthResult.failure(message: _getFriendlyErrorMessage(e.code));
        }
      } catch (e, s) {
        LoggerService.error('Unknown error during sign-in in project $projectId', e, s);
        FirebaseCrashlytics.instance.recordError(e, s, reason: 'Unknown error during sign-in in project $projectId');
        return AuthResult.failure(message: 'An unexpected error occurred during sign-in.');
      }
    }
    LoggerService.warning('No user found with $email and password across all projects.');
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
  User? getCurrentUser() {
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
  Stream<User?> get user {
    LoggerService.info('AuthService.user stream accessed. Current value: ${_userSubject.value?.uid}');
    return _userSubject.stream;
  }
}
