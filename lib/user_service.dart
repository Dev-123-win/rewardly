import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Import Cloud Functions
import 'package:uuid/uuid.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance;


  // Create user data on registration
  Future<void> createUserData(String uid, String email, {String? referralCode, String? deviceId, String? projectId}) async {
    try {
      await _firestore.runTransaction((transaction) async {
        int initialCoins = 0;
        String? actualReferredBy;
        String newReferralCode;

        // Call Cloud Function to generate a unique referral code
        try {
          final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('generateUniqueReferralCode');
          final HttpsCallableResult result = await callable.call();
          newReferralCode = result.data['referralCode'];
        } catch (e, s) {
          FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error calling Cloud Function to generate unique referral code');
          // Fallback to client-side generation if Cloud Function fails
          newReferralCode = const Uuid().v4().substring(0, 8);
        }

        // Client-side referral bonus logic removed.
        // The Cloud Function 'handleReferralBonus' will now handle referrer lookup and bonus awarding.
        if (referralCode != null && referralCode.isNotEmpty) {
          actualReferredBy = referralCode;
        }

        // Ensure the generated referral code is unique (though UUID collision is highly unlikely for substring)
        // For robustness, a loop could be added here to regenerate if a collision is detected,
        // but for an 8-character UUID substring, it's generally considered unique enough for this scale.
        // If truly unique and short codes are needed, a server-side generation with collision checks is better.

        transaction.set(_firestore.collection('users').doc(uid), {
          'email': email,
          'coins': initialCoins,
          'adsWatchedToday': 0,
          'lastAdWatchDate': DateTime.now().toIso8601String().substring(0, 10),
          'referralCode': newReferralCode, // Use the generated unique referral code
          'referredBy': actualReferredBy,
          'isAdmin': false,
          'spinWheelFreeSpinsToday': 3, // Initial free spins
          'spinWheelAdSpinsToday': 0, // Initial ad-watched spins
          'lastSpinWheelDate': DateTime.now().toIso8601String().substring(0, 10), // Current date
          'deviceId': deviceId, // Store the device ID
          'projectId': projectId, // Store the project ID this user belongs to
        });
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error creating user data with referral');
      rethrow; // Re-throw to propagate the error if necessary
    }
  }

  // Decrement free spin wheel spins
  Future<void> decrementFreeSpinWheelSpins(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'spinWheelFreeSpinsToday': FieldValue.increment(-1),
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error decrementing free spin wheel spins');
    }
  }

  // Increment ad-watched spin wheel spins
  Future<void> incrementAdSpinWheelSpins(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'spinWheelAdSpinsToday': FieldValue.increment(1),
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error incrementing ad spin wheel spins');
    }
  }

  // Reset daily spin wheel counts if date has changed (now handled by Cloud Function)
  Future<void> resetSpinWheelDailyCounts(String uid, String projectId) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('resetSpinWheelDailyCounts');
      await callable.call({'uid': uid, 'projectId': projectId});
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error calling Cloud Function to reset spin wheel daily counts');
      rethrow;
    }
  }

  // Get user data stream
  Stream<DocumentSnapshot> getUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }


  // Update user coins
  Future<void> updateCoins(String uid, int amount) async {
    try {
      final userDoc = _firestore.collection('users').doc(uid);
      final doc = await userDoc.get();

      if (!doc.exists) {
        await userDoc.set({
          'coins': amount,
        });
      } else {
        await userDoc.update({
          'coins': FieldValue.increment(amount),
        });
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error updating user coins');
    }
  }

  // Update ads watched today (now handled by Cloud Function)
  Future<void> updateAdsWatchedToday(String uid, String projectId) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateAdsWatchedToday');
      await callable.call({'uid': uid, 'projectId': projectId});
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error calling Cloud Function to update ads watched today');
      rethrow;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    final userDataSnapshot = await _firestore.collection('users').doc(uid).get();
    if (userDataSnapshot.exists) {
      final userData = userDataSnapshot.data();
      return (userData != null && userData['isAdmin'] == true);
    }
    return false;
  }

  // Get user by referral code
  Future<DocumentSnapshot?> getUserByReferralCode(String referralCode) async {
    final querySnapshot = await _firestore.collection('users').where('referralCode', isEqualTo: referralCode).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  }

  // Update specific user data fields
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error updating user data fields');
    }
  }
}
