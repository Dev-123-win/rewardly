import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart'; // Import FirebaseApp
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'firebase_project_config_service.dart'; // Import FirebaseProjectConfigService
import 'logger_service.dart'; // Import LoggerService

class WithdrawalService {
  // No longer needs a default UserService, as it will be created with the correct Firestore instance

  Future<String?> submitWithdrawal({
    required String uid,
    required int amount,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    if (amount <= 0) {
      return 'Please enter a valid amount.';
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'User not logged in.';
    }

    String? projectId;
    final defaultFirestore = FirebaseFirestore.instance;
    final userDocInDefaultProject = await defaultFirestore.collection('users').doc(uid).get();

    if (userDocInDefaultProject.exists && userDocInDefaultProject.data()?['projectId'] != null) {
      projectId = userDocInDefaultProject.data()?['projectId'] as String?;
    } else {
      // Fallback: If projectId is not in the default project, search all shards
      LoggerService.warning('User document for $uid in default project does not contain projectId or document not found. Searching all shards for withdrawal.');
      for (String pId in FirebaseProjectConfigService.projectIds) {
        try {
          final FirebaseApp shardedApp = FirebaseProjectConfigService.getFirebaseApp(pId);
          final FirebaseFirestore shardedFirestore = FirebaseFirestore.instanceFor(app: shardedApp);
          final shardedUserDoc = await shardedFirestore.collection('users').doc(uid).get();
          if (shardedUserDoc.exists) {
            projectId = pId;
            LoggerService.info('User $uid found in shard: $projectId for withdrawal.');
            break; // Found the user's project
          }
        } catch (e, s) {
          LoggerService.error('Error searching shard $pId for user $uid during withdrawal', e, s);
        }
      }
    }

    if (projectId == null) {
      LoggerService.error('User document for $uid not found in any sharded project for withdrawal.');
      return 'Could not determine user\'s project ID.';
    }

    // Get the Firestore instance for the user's specific project
    final FirebaseFirestore userFirestore = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));

    if (paymentDetails.isEmpty) {
      return 'Please enter payment details.';
    }

    try {
      await userFirestore.runTransaction((transaction) async {
        final userDocRef = userFirestore.collection('users').doc(uid);
        final userSnapshot = await transaction.get(userDocRef);

        if (!userSnapshot.exists) {
          throw Exception('User document not found for withdrawal.');
        }

        final int currentCoins = (userSnapshot.data()?['coins'] as int?) ?? 0;

        if (amount > currentCoins) {
          throw Exception('Insufficient coins for withdrawal.');
        }

        // Deduct coins
        transaction.update(userDocRef, {'coins': FieldValue.increment(-amount)});

        // Add withdrawal request
        transaction.set(userFirestore.collection('withdrawalRequests').doc(), {
          'uid': uid,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'paymentDetails': paymentDetails,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'projectId': projectId,
        });
      });
      return null;
    } on Exception catch (e, s) {
      LoggerService.error('Withdrawal transaction failed: $e', e, s);
      return e.toString().contains('Insufficient coins') ? 'Insufficient coins.' : 'Failed to submit withdrawal request. Please try again.';
    } catch (e, s) {
      LoggerService.error('Error submitting withdrawal request: $e', e, s);
      return 'Failed to submit withdrawal request. Please try again.';
    }
  }
}
