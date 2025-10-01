import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'models/auth_result.dart'; // Import AuthResult
import 'device_service.dart'; // Import DeviceService
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore queries
import 'firebase_project_config_service.dart'; // Import FirebaseProjectConfigService

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register with email and password
  Future<AuthResult> registerWithEmailAndPassword(String email, String password, {String? referralCode}) async {
    try {
      final String? deviceId = await DeviceService().getDeviceId();
      if (deviceId == null) {
        return AuthResult.failure(message: 'Could not get device ID. Please try again.');
      }

      // --- MODIFICATION START ---
      // Temporarily simplify device ID check to use the default FirebaseFirestore instance.
      // This is for debugging the PERMISSION_DENIED error during unauthenticated queries.
      final FirebaseFirestore defaultFirestoreInstance = FirebaseFirestore.instance; // Use default instance
      final deviceCheck = await defaultFirestoreInstance.collection('users').where('deviceId', isEqualTo: deviceId).limit(1).get();
      if (deviceCheck.docs.isNotEmpty) {
        return AuthResult.failure(message: 'Only one account per device is allowed.');
      }
      // --- MODIFICATION END ---


      // Determine which project to shard the new user to
      final String targetProjectId = await FirebaseProjectConfigService.getNextProjectIdForNewUser();
      final FirebaseAuth targetAuth = FirebaseAuth.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(targetProjectId));
      final FirebaseFirestore targetFirestore = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(targetProjectId));


      UserCredential result = await targetAuth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        // Pass the targetFirestore instance to UserService
        await UserService(firestoreInstance: targetFirestore).createUserData(user.uid, email, referralCode: referralCode, deviceId: deviceId, projectId: targetProjectId);
        return AuthResult.success(uid: user.uid);
      }
      return AuthResult.failure(message: 'User creation failed unexpectedly.');
    } on FirebaseAuthException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'FirebaseAuthException during registration');
      return AuthResult.failure(message: _getFriendlyErrorMessage(e.code));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Unknown error during registration');
      return AuthResult.failure(message: 'An unexpected error occurred during registration.');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    // For sign-in, we need to find which project the user belongs to.
    // This is a simplified approach. A more robust solution would involve
    // a central user mapping (e.g., a lightweight, un-sharded Firebase project
    // storing email -> projectId mapping) or Cloud Functions.
    // For now, we will iterate through all projects.
    for (String projectId in FirebaseProjectConfigService.projectIds) {
      try {
        final FirebaseAuth targetAuth = FirebaseAuth.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
        UserCredential result = await targetAuth.signInWithEmailAndPassword(email: email, password: password);
        User? user = result.user;
        if (user != null) {
          // Successfully signed in, set the current user's project context
          // This is a placeholder for how the app would know which project to use
          // for subsequent Firestore operations. A global state management solution
          // (like Provider) would be ideal here to store the active projectId.
          return AuthResult.success(uid: user.uid);
        }
      } on FirebaseAuthException catch (e, s) {
        // If it's a 'user-not-found' or 'wrong-password' error, it might just mean
        // the user is not in this specific project. We continue to the next project.
        // Other errors (e.g., network issues) should still be reported.
        if (e.code != 'user-not-found' && e.code != 'wrong-password') {
          FirebaseCrashlytics.instance.recordError(e, s, reason: 'FirebaseAuthException during sign-in in project $projectId');
          return AuthResult.failure(message: _getFriendlyErrorMessage(e.code));
        }
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s, reason: 'Unknown error during sign-in in project $projectId');
        return AuthResult.failure(message: 'An unexpected error occurred during sign-in.');
      }
    }
    return AuthResult.failure(message: 'No user found with that email and password across all projects.');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error during sign-out');
    }
  }

  // Get current user
  // This method will need to be updated to reflect the sharded authentication.
  // It should return the current user from the *active* FirebaseApp.
  // For now, it returns from the default app, which might not be correct in a sharded setup.
  User? getCurrentUser() {
    // This needs to be refined. The app needs to know which project the user is logged into.
    // This could be stored in a global state or retrieved from a central mapping.
    return _auth.currentUser; // Returns user from the default Firebase app
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(uid: ''); // UID not relevant for password reset success
    } on FirebaseAuthException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'FirebaseAuthException during password reset');
      return AuthResult.failure(message: _getFriendlyErrorMessage(e.code));
    } catch (e, s) {
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

  // Auth change user stream
  Stream<User?> get user {
    // This stream will also need to be adapted for sharded authentication.
    // It should listen to auth state changes across all initialized Firebase apps
    // or, more practically, for the currently active project.
    return _auth.authStateChanges(); // Returns stream from the default Firebase app
  }
}
