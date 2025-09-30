const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK. This is crucial for interacting with Firestore
// and other Firebase services, especially across multiple projects.
admin.initializeApp();

/**
 * Cloud Function to process withdrawal requests.
 * This function is triggered whenever a new document is created in the
 * 'withdrawalRequests' collection of any sharded Firestore database.
 *
 * It performs the following steps:
 * 1. Validates the incoming withdrawal request data.
 * 2. Determines the correct sharded Firebase project for the user.
 * 3. Executes a Firestore transaction to:
 *    a. Fetch the user's current coin balance.
 *    b. Check for sufficient funds.
 *    c. Deduct the withdrawal amount from the user's coins.
 *    d. Update the status of the withdrawal request.
 * 4. Logs success or failure.
 */
exports.processWithdrawal = functions.firestore
    .document('withdrawalRequests/{requestId}')
    .onCreate(async (snap, context) => {
      const requestData = snap.data();
      const userId = requestData.uid;
      const amount = requestData.amount;
      const projectId = requestData.projectId; // The project ID where the user's data resides

      // Basic validation of the request data
      if (!userId || !amount || amount <= 0 || !projectId) {
        console.error('Invalid withdrawal request data:', requestData);
        // Update the request status to failed with an error message
        return snap.ref.update({ status: 'failed', error: 'Invalid request data' });
      }

      try {
        // Get the Firebase App instance corresponding to the user's projectId.
        // This allows the function to interact with the correct sharded Firestore.
        const app = admin.app(projectId);
        const firestore = admin.firestore(app);

        const userRef = firestore.collection('users').doc(userId);

        // Run a Firestore transaction to ensure atomicity and prevent race conditions
        await firestore.runTransaction(async (transaction) => {
          const userDoc = await transaction.get(userRef);

          // Check if the user document exists
          if (!userDoc.exists) {
            throw new Error('User not found in project ' + projectId);
          }

          const currentCoins = userDoc.data().coins || 0;

          // Check if the user has sufficient coins
          if (currentCoins < amount) {
            throw new Error('Insufficient coins for withdrawal');
          }

          // Deduct coins from the user's balance
          transaction.update(userRef, { coins: admin.firestore.FieldValue.increment(-amount) });
          // Update the withdrawal request status to processed
          transaction.update(snap.ref, { status: 'processed', processedAt: admin.firestore.FieldValue.serverTimestamp() });
        });

        console.log(`Withdrawal for user ${userId} in project ${projectId} processed successfully.`);
        return null; // Indicate successful completion of the function
      } catch (error) {
        console.error(`Error processing withdrawal for user ${userId} in project ${projectId}:`, error);
        // Update the withdrawal request status to failed with the error message
        return snap.ref.update({ status: 'failed', error: error.message });
      }
    });

/**
 * Cloud Function to generate a unique referral code.
 * This function generates an 8-character UUID substring and checks its uniqueness
 * across all sharded Firestore instances. If a collision is detected, it
 * regenerates the code until a unique one is found.
 *
 * It performs the following steps:
 * 1. Generates a new 8-character UUID substring.
 * 2. Queries all known Firebase projects (shards) to check if the code already exists.
 * 3. If a collision is found, it repeats steps 1 and 2.
 * 4. Returns the unique referral code.
 */
exports.generateUniqueReferralCode = functions.https.onCall(async (data, context) => {
  // Ensure the request is authenticated if necessary, or adjust security rules
  // if this function should be callable by unauthenticated users.
  // if (!context.auth) {
  //   throw new functions.https.HttpsError('unauthenticated', 'Only authenticated users can generate referral codes.');
  // }

  // TODO: Replace with actual project IDs from your Firebase setup.
  // These should ideally be fetched from a secure configuration or environment variables.
  const projectIds = ['rewardly-new', 'rewardly-1', 'rewardly-2', 'rewardly-3', 'rewardly-4'];

  let isUnique = false;
  let referralCode = '';
  const uuid = require('uuid'); // Import uuid library

  while (!isUnique) {
    referralCode = uuid.v4().substring(0, 8);
    let collisionDetected = false;

    for (const pId of projectIds) {
      try {
        let app;
        try {
          app = admin.app(pId);
        } catch (e) {
          app = admin.initializeApp({
            credential: admin.credential.applicationDefault(),
            projectId: pId,
          }, pId);
        }

        const firestore = admin.firestore(app);
        const querySnapshot = await firestore.collection('users')
            .where('referralCode', '==', referralCode)
            .limit(1)
            .get();

        if (!querySnapshot.empty) {
          collisionDetected = true;
          console.log(`Collision detected for referral code ${referralCode} in project ${pId}. Regenerating.`);
          break; // Collision found, break and regenerate
        }
      } catch (e) {
        console.error(`Error checking uniqueness in project ${pId} for code ${referralCode}:`, e);
        // Depending on error handling strategy, you might want to rethrow or treat as collision
        // For now, we'll log and continue, assuming a potential issue means we should regenerate.
        collisionDetected = true; // Treat error as a potential collision to be safe
        break;
      }
    }

    if (!collisionDetected) {
      isUnique = true;
    }
  }

  console.log(`Generated unique referral code: ${referralCode}`);
  return { referralCode: referralCode };
});

/**
 * Cloud Function to handle cross-shard referral bonus logic.
 * This function is triggered whenever a new user document is created in
 * the 'users' collection of any sharded Firestore database.
 *
 * It performs the following steps:
 * 1. Extracts the 'referredBy' code from the new user's data.
 * 2. If 'referredBy' is present, it queries all known Firebase projects (shards)
 *    to find the referrer's user document using their 'referralCode'.
 * 3. If the referrer is found, it performs a transaction on the referrer's
 *    specific shard to update their 'coins' balance by adding a referral bonus.
 * 4. Logs success or failure.
 */
exports.handleReferralBonus = functions.firestore
    .document('users/{userId}')
    .onCreate(async (snap, context) => {
      const newUserData = snap.data();
      const referredBy = newUserData.referredBy;
      const newUserProjectId = newUserData.projectId; // The project ID where the new user's data resides

      if (!referredBy) {
        console.log('New user does not have a referrer. Skipping referral bonus.');
        return null;
      }

      // TODO: Replace with actual project IDs from your Firebase setup.
      // These should ideally be fetched from a secure configuration or environment variables.
      const projectIds = ['rewardly-new', 'rewardly-1', 'rewardly-2', 'rewardly-3', 'rewardly-4'];
      const referralBonusCoins = 500; // TODO: Fetch this from Remote Config or a secure server-side config

      let referrerFound = false;
      let referrerProjectId = null;
      let referrerUid = null;

      for (const pId of projectIds) {
        try {
          // Initialize app for each project if not already initialized
          let app;
          try {
            app = admin.app(pId);
          } catch (e) {
            app = admin.initializeApp({
              credential: admin.credential.applicationDefault(),
              projectId: pId,
            }, pId);
          }

          const firestore = admin.firestore(app);
          const referrerQuerySnapshot = await firestore.collection('users')
              .where('referralCode', '==', referredBy)
              .limit(1)
              .get();

          if (!referrerQuerySnapshot.empty) {
            referrerFound = true;
            referrerDoc = referrerQuerySnapshot.docs[0];
            referrerUid = referrerDoc.id;
            referrerProjectId = pId;
            console.log(`Referrer ${referrerUid} found in project ${referrerProjectId}`);
            break; // Referrer found, no need to check other projects
          }
        } catch (e) {
          console.error(`Error querying project ${pId} for referrer ${referredBy}:`, e);
        }
      }

      if (!referrerFound) {
        console.warn(`Referrer with code ${referredBy} not found in any project.`);
        return null;
      }

      // If referrer is found, update their coins in their specific shard
      try {
        const referrerApp = admin.app(referrerProjectId);
        const referrerFirestore = admin.firestore(referrerApp);
        const referrerRef = referrerFirestore.collection('users').doc(referrerUid);

        await referrerFirestore.runTransaction(async (transaction) => {
          const referrerDocSnapshot = await transaction.get(referrerRef);

          if (!referrerDocSnapshot.exists) {
            throw new Error(`Referrer document ${referrerUid} not found in project ${referrerProjectId} during bonus transaction.`);
          }

          transaction.update(referrerRef, {
            coins: admin.firestore.FieldValue.increment(referralBonusCoins),
          });
        });

        console.log(`Referral bonus of ${referralBonusCoins} coins awarded to referrer ${referrerUid} in project ${referrerProjectId}.`);
        return null;
      } catch (error) {
        console.error(`Error awarding referral bonus to ${referrerUid} in project ${referrerProjectId}:`, error);
        // Log to Crashlytics or other error monitoring if available
        return null;
      }
    });

/**
 * Cloud Function to securely update ads watched today.
 * This function is called by the client to increment the 'adsWatchedToday' count
 * for a user, ensuring server-side validation of the date.
 *
 * It performs the following steps:
 * 1. Validates the incoming user ID.
 * 2. Determines the correct sharded Firebase project for the user.
 * 3. Fetches the user's document and checks the 'lastAdWatchDate'.
 * 4. If the date is different from today (server-side date), it resets the count and updates the date.
 * 5. Increments 'adsWatchedToday'.
 * 6. Logs success or failure.
 */
exports.updateAdsWatchedToday = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Only authenticated users can update ad watch counts.');
  }

  const uid = context.auth.uid;
  const projectId = data.projectId; // The project ID where the user's data resides

  if (!uid || !projectId) {
    throw new functions.https.HttpsError('invalid-argument', 'User ID and Project ID are required.');
  }

  try {
    const app = admin.app(projectId);
    const firestore = admin.firestore(app);
    const userRef = firestore.collection('users').doc(uid);

    await firestore.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User document not found.');
      }

      const serverTimestamp = admin.firestore.FieldValue.serverTimestamp();
      const today = new Date().toISOString().substring(0, 10); // Server-side date

      let adsWatchedToday = userDoc.data().adsWatchedToday || 0;
      const lastAdWatchDate = userDoc.data().lastAdWatchDate;

      if (lastAdWatchDate !== today) {
        adsWatchedToday = 0; // Reset if it's a new day
        transaction.update(userRef, {
          adsWatchedToday: 1,
          lastAdWatchDate: today,
        });
      } else {
        transaction.update(userRef, {
          adsWatchedToday: admin.firestore.FieldValue.increment(1),
        });
      }
    });

    console.log(`User ${uid} in project ${projectId} updated adsWatchedToday successfully.`);
    return { success: true };
  } catch (error) {
    console.error(`Error updating adsWatchedToday for user ${uid} in project ${projectId}:`, error);
    throw new functions.https.HttpsError('internal', 'Failed to update ads watched today.', error.message);
  }
});

/**
 * Cloud Function to securely reset spin wheel daily counts.
 * This function is called by the client to reset 'spinWheelFreeSpinsToday' and
 * 'spinWheelAdSpinsToday' for a user, ensuring server-side validation of the date.
 *
 * It performs the following steps:
 * 1. Validates the incoming user ID.
 * 2. Determines the correct sharded Firebase project for the user.
 * 3. Fetches the user's document and checks the 'lastSpinWheelDate'.
 * 4. If the date is different from today (server-side date), it resets the counts and updates the date.
 * 5. Logs success or failure.
 */
exports.resetSpinWheelDailyCounts = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Only authenticated users can reset spin wheel counts.');
  }

  const uid = context.auth.uid;
  const projectId = data.projectId; // The project ID where the user's data resides

  if (!uid || !projectId) {
    throw new functions.https.HttpsError('invalid-argument', 'User ID and Project ID are required.');
  }

  try {
    const app = admin.app(projectId);
    const firestore = admin.firestore(app);
    const userRef = firestore.collection('users').doc(uid);

    await firestore.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User document not found.');
      }

      const today = new Date().toISOString().substring(0, 10); // Server-side date
      const lastSpinWheelDate = userDoc.data().lastSpinWheelDate;

      if (lastSpinWheelDate !== today) {
        transaction.update(userRef, {
          spinWheelFreeSpinsToday: 3, // Reset to initial free spins
          spinWheelAdSpinsToday: 0,
          lastSpinWheelDate: today,
        });
      }
    });

    console.log(`User ${uid} in project ${projectId} reset spin wheel daily counts successfully.`);
    return { success: true };
  } catch (error) {
    console.error(`Error resetting spin wheel daily counts for user ${uid} in project ${projectId}:`, error);
    throw new functions.https.HttpsError('internal', 'Failed to reset spin wheel daily counts.', error.message);
  }
});

/**
 * Cloud Function to securely check if a user is an admin.
 * This function queries the user's document in their specific shard to check the 'isAdmin' field.
 * It should be used for security-critical admin functionalities.
 *
 * It performs the following steps:
 * 1. Validates the incoming user ID.
 * 2. Determines the correct sharded Firebase project for the user.
 * 3. Fetches the user's document and checks the 'isAdmin' field.
 * 4. Returns true if the user is an admin, false otherwise.
 */
exports.checkAdminStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Only authenticated users can check admin status.');
  }

  const uid = context.auth.uid;
  const projectId = data.projectId; // The project ID where the user's data resides

  if (!uid || !projectId) {
    throw new functions.https.HttpsError('invalid-argument', 'User ID and Project ID are required.');
  }

  try {
    const app = admin.app(projectId);
    const firestore = admin.firestore(app);
    const userRef = firestore.collection('users').doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      console.log(`User document not found for ${uid} in project ${projectId}.`);
      return { isAdmin: false };
    }

    const isAdmin = userDoc.data().isAdmin === true;
    console.log(`User ${uid} in project ${projectId} admin status: ${isAdmin}`);
    return { isAdmin: isAdmin };
  } catch (error) {
    console.error(`Error checking admin status for user ${uid} in project ${projectId}:`, error);
    throw new functions.https.HttpsError('internal', 'Failed to check admin status.', error.message);
  }
});

/**
 * Cloud Function to securely check if a user is an admin.
 * This function queries the user's document in their specific shard to check the 'isAdmin' field.
 * It should be used for security-critical admin functionalities.
 *
 * It performs the following steps:
 * 1. Validates the incoming user ID.
 * 2. Determines the correct sharded Firebase project for the user.
 * 3. Fetches the user's document and checks the 'isAdmin' field.
 * 4. Returns true if the user is an admin, false otherwise.
 */
exports.checkAdminStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Only authenticated users can check admin status.');
  }

  const uid = context.auth.uid;
  const projectId = data.projectId; // The project ID where the user's data resides

  if (!uid || !projectId) {
    throw new functions.https.HttpsError('invalid-argument', 'User ID and Project ID are required.');
  }

  try {
    const app = admin.app(projectId);
    const firestore = admin.firestore(app);
    const userRef = firestore.collection('users').doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      console.log(`User document not found for ${uid} in project ${projectId}.`);
      return { isAdmin: false };
    }

    const isAdmin = userDoc.data().isAdmin === true;
    console.log(`User ${uid} in project ${projectId} admin status: ${isAdmin}`);
    return { isAdmin: isAdmin };
  } catch (error) {
    console.error(`Error checking admin status for user ${uid} in project ${projectId}:`, error);
    throw new functions.https.HttpsError('internal', 'Failed to check admin status.', error.message);
  }
});

/**
 * Cloud Function to securely check if a user is an admin.
 * This function queries the user's document in their specific shard to check the 'isAdmin' field.
 * It should be used for security-critical admin functionalities.
 *
 * It performs the following steps:
 * 1. Validates the incoming user ID.
 * 2. Determines the correct sharded Firebase project for the user.
 * 3. Fetches the user's document and checks the 'isAdmin' field.
 * 4. Returns true if the user is an admin, false otherwise.
 */
exports.checkAdminStatus = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Only authenticated users can check admin status.');
  }

  const uid = context.auth.uid;
  const projectId = data.projectId; // The project ID where the user's data resides

  if (!uid || !projectId) {
    throw new functions.https.HttpsError('invalid-argument', 'User ID and Project ID are required.');
  }

  try {
    const app = admin.app(projectId);
    const firestore = admin.firestore(app);
    const userRef = firestore.collection('users').doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      console.log(`User document not found for ${uid} in project ${projectId}.`);
      return { isAdmin: false };
    }

    const isAdmin = userDoc.data().isAdmin === true;
    console.log(`User ${uid} in project ${projectId} admin status: ${isAdmin}`);
    return { isAdmin: isAdmin };
  } catch (error) {
    console.error(`Error checking admin status for user ${uid} in project ${projectId}:`, error);
    throw new functions.https.HttpsError('internal', 'Failed to check admin status.', error.message);
  }
});
