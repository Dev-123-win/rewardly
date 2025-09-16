import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const int _referralBonusCoins = 50; // Define referral bonus

  // Create user data on registration
  Future<void> createUserData(String uid, String email, {String? referralCode}) async {
    int initialCoins = 0;
    String? actualReferredBy;

    if (referralCode != null && referralCode.isNotEmpty) {
      final referrerSnapshot = await getUserByReferralCode(referralCode);
      if (referrerSnapshot != null && referrerSnapshot.exists) {
        // Valid referral code, give bonus to new user and referrer
        initialCoins = _referralBonusCoins;
        actualReferredBy = referralCode;
        await updateCoins(referrerSnapshot.id, _referralBonusCoins); // Reward referrer
      }
    }

    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'coins': initialCoins,
      'adsWatchedToday': 0,
      'lastAdWatchDate': DateTime.now().toIso8601String().substring(0, 10),
      'referralCode': uid.substring(0, 8), // Simple referral code from UID
      'referredBy': actualReferredBy,
      'isAdmin': false,
    });
  }

  // Get user data stream
  Stream<DocumentSnapshot> getUserData(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Update user coins
  Future<void> updateCoins(String uid, int amount) async {
    await _firestore.collection('users').doc(uid).update({
      'coins': FieldValue.increment(amount),
    });
  }

  // Update ads watched today
  Future<void> updateAdsWatchedToday(String uid) async {
    final userData = await _firestore.collection('users').doc(uid).get();
    final lastAdWatchDate = userData['lastAdWatchDate'];
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastAdWatchDate == today) {
      await _firestore.collection('users').doc(uid).update({
        'adsWatchedToday': FieldValue.increment(1),
      });
    } else {
      await _firestore.collection('users').doc(uid).update({
        'adsWatchedToday': 1,
        'lastAdWatchDate': today,
      });
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    final userData = await _firestore.collection('users').doc(uid).get();
    return userData['isAdmin'] ?? false;
  }

  // Get user by referral code
  Future<DocumentSnapshot?> getUserByReferralCode(String referralCode) async {
    final querySnapshot = await _firestore.collection('users').where('referralCode', isEqualTo: referralCode).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }
    return null;
  }
}
