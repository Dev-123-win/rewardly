import 'package:cloud_firestore/cloud_firestore.dart';
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

        // Client-side generation of a unique referral code
        newReferralCode = const Uuid().v4().substring(0, 8);
        // Note: Global uniqueness across shards is difficult to guarantee client-side
        // without extensive queries, which are inefficient and prone to race conditions.
        // We rely on Firestore Security Rules to prevent modification after creation.

        if (referralCode != null && referralCode.isNotEmpty) {
          actualReferredBy = referralCode;
          // Client-side referral bonus logic:
          // The plan states that 'handleReferralBonus' is highly sensitive and
          // should ideally remain server-side or be removed.
          // For now, we will only store 'referredBy' and rely on manual processing
          // or a simplified client-side approach (with acknowledged security risks)
          // if the bonus system is to be retained without Cloud Functions.
          // For this implementation, we are not awarding bonuses client-side.
        }

        transaction.set(_firestore.collection('users').doc(uid), {
          'email': email,
          'coins': initialCoins,
          'adsWatchedToday': 0,
          'lastAdWatchDate': '', // Initialize as empty, updated on first ad watch
          'referralCode': newReferralCode,
          'referredBy': actualReferredBy,
          'isAdmin': false,
          'spinWheelFreeSpinsToday': 3, // Initial free spins
          'spinWheelAdSpinsToday': 0,
          'lastSpinWheelDate': '', // Initialize as empty, updated on first spin
          'deviceId': deviceId,
          'projectId': projectId,
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

  // Reset daily spin wheel counts if date has changed (now handled client-side)
  Future<void> resetSpinWheelDailyCounts(String uid) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User document not found.');
        }

        final today = DateTime.now().toIso8601String().substring(0, 10);
        final lastSpinWheelDate = userDoc.data()?['lastSpinWheelDate'] as String? ?? '';

        if (lastSpinWheelDate != today) {
          transaction.update(userRef, {
            'spinWheelFreeSpinsToday': 3, // Reset to initial free spins
            'spinWheelAdSpinsToday': 0,
            'lastSpinWheelDate': today,
          });
        }
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error resetting spin wheel daily counts client-side');
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

  // Update ads watched today (now handled client-side)
  Future<void> updateAdsWatchedToday(String uid) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User document not found.');
        }

        final today = DateTime.now().toIso8601String().substring(0, 10);
        final lastAdWatchDate = userDoc.data()?['lastAdWatchDate'] as String? ?? '';

        if (lastAdWatchDate != today) {
          transaction.update(userRef, {
            'adsWatchedToday': 1, // Reset to 1 for the new day
            'lastAdWatchDate': today,
          });
        } else {
          transaction.update(userRef, {
            'adsWatchedToday': FieldValue.increment(1),
          });
        }
      });
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error updating ads watched today client-side');
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
