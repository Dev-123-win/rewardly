# Plan 2: FCM + GitHub Workflow for Hourly Coin Sync, DAU, and Referral Rewards (Revised - No Firebase Cloud Functions)

**Goal:** Implement Firebase Cloud Messaging (FCM) triggered directly by a GitHub Actions workflow to perform hourly database updates for earned coins, limited to a 12-hour window per day, with local updates in between. Additionally, track Daily Active Users (DAU) and securely award referral rewards via the GitHub Actions workflow. The displayed total balance will always reflect the sum of the Firestore balance and any locally accumulated coins.

**Assumptions:**
*   You are targeting both Android and potentially iOS (FCM is cross-platform).
*   The hourly trigger, FCM message sending, DAU tracking, and referral reward processing are managed directly by GitHub Actions.
*   Devices need to be online to receive FCM messages for timely updates.
*   You are comfortable managing Firebase service account credentials within GitHub Secrets.

---

## Detailed Plan for FCM + GitHub Workflow Integration (Revised):

### Step 1: Add the `firebase_messaging` Package

*   **Action:** Add `firebase_messaging: ^latest_version` to your `pubspec.yaml` file.
*   **Impact:** Enables your Flutter app to receive and handle Firebase Cloud Messages.

### Step 2: Configure Firebase Cloud Messaging in Flutter App

*   **Action:**
    1.  **Android:**
        *   Ensure `google-services.json` is correctly placed in `android/app/`.
        *   Update `android/app/build.gradle.kts` to apply the Google Services plugin.
        *   Configure `AndroidManifest.xml` for FCM (usually handled by `firebase_messaging` plugin, but verify permissions and services).
    2.  **iOS (if applicable):**
        *   Configure Xcode project for Push Notifications.
        *   Upload APNs authentication key to Firebase.
        *   Ensure `GoogleService-Info.plist` is correctly placed.
    3.  **Flutter Code:**
        *   Initialize `FirebaseMessaging` in `main.dart`.
        *   Request notification permissions.
        *   Implement `FirebaseMessaging.onBackgroundMessage` for handling messages when the app is in the background or terminated.
        *   Implement `FirebaseMessaging.onMessage` for handling messages when the app is in the foreground.
        *   Retrieve and store the FCM device token for each user in Firestore.
*   **Files:** `pubspec.yaml`, `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, `lib/main.dart`, `lib/user_service.dart` (to store FCM token).
*   **Impact:** Your app can send and receive FCM messages.

### Step 3: Implement Local Coin Storage and Management

*   **Action:**
    1.  Create a new service, `lib/local_storage_service.dart`, to encapsulate `SharedPreferences` operations.
    2.  Add methods to `LocalStorageService` to:
        *   `getLocallyEarnedCoins(uid)`: Retrieve locally accumulated coins.
        *   `addLocallyEarnedCoins(uid, amount)`: Add coins to the local total.
        *   `resetLocallyEarnedCoins(uid)`: Set local coins to 0.
        *   `setDailySyncStartTime(uid, timestamp)`: Store when the 12-hour sync window started.
        *   `getDailySyncStartTime(uid)`: Retrieve the start time.
        *   `clearDailySyncStartTime(uid)`: Clear the start time.
        *   `setLastActiveDate(uid, dateString)`: Store the last active date locally.
        *   `getLastActiveDate(uid)`: Retrieve the last active date locally.
*   **Files:** `lib/local_storage_service.dart` (new), `lib/user_data_provider.dart` (to use this service).
*   **Impact:** Allows coins to be accumulated locally without immediate Firestore writes, manages the daily sync window state, and optimizes DAU tracking.

### Step 4: Modify Coin Earning Logic to Update Local Storage

*   **Action:** When a user earns coins (e.g., from spin wheel, ads), update the `locallyEarnedCoins` using `LocalStorageService.addLocallyEarnedCoins(uid, amount)` instead of directly updating Firestore.
*   **File:** `lib/screens/home/spin_wheel_game_screen.dart` (in `_updateUserCoins` and similar methods), and any other coin-earning screens/services.
*   **Impact:** Reduces immediate Firestore writes, as only local storage is updated.

### Step 5: Implement Daily Active User (DAU) Tracking (Client-Side)

*   **Action:** In your app's main entry point or wrapper (e.g., `lib/main.dart` or `lib/wrapper.dart`), implement logic to track DAU:
    1.  On app startup/foreground, get the current user's `uid`.
    2.  Get `lastActiveDate` from `LocalStorageService`.
    3.  Get today's date as a string (e.g., `YYYY-MM-DD`).
    4.  If `lastActiveDate` is not today's date:
        *   Call a new method in `UserService` (e.g., `updateDailyActiveStatus`) to:
            *   Increment `daysActiveCount` in the user's Firestore document.
            *   Update `lastActiveDate` in the user's Firestore document to today's date.
        *   Update `lastActiveDate` in `LocalStorageService` to today's date.
*   **Files:** `lib/main.dart` or `lib/wrapper.dart`, `lib/user_service.dart` (add `updateDailyActiveStatus` method), `lib/local_storage_service.dart`.
*   **Impact:** Tracks user activity with a single Firestore write per user per day, optimized by local storage.

### Step 6: Prepare Firebase Service Account Credentials

*   **Action:**
    1.  For *each* of your 5 Firebase projects, generate a Firebase service account private key.
        *   Go to Firebase Console -> Project settings -> Service accounts.
        *   Click "Generate new private key" for each project.
    2.  Store the JSON content of each key file as a **GitHub Secret**. For example, `FIREBASE_ADMIN_SDK_PROD01`, `FIREBASE_ADMIN_SDK_PROD02`, etc.
*   **Impact:** Provides the necessary authentication for your GitHub Action to interact with Firebase (Firestore and FCM) on behalf of each sharded project. **This is a critical security step; keep these secrets secure.**

### Step 7: Create a GitHub Actions Workflow to Send FCM Messages and Process Referrals

*   **Action:**
    1.  In your GitHub repository, create a new workflow file (e.g., `.github/workflows/hourly-sync-and-referrals.yml`).
    2.  Configure the workflow to run on a schedule (e.g., `on: schedule: - cron: '0 * * * *'` for hourly).
    3.  The workflow job will execute a script (e.g., Node.js or Python) that directly uses the Firebase Admin SDK to:
        *   **Process Hourly Coin Sync:**
            *   Loop through each Firebase project's credentials.
            *   For each project, query users who have `fcmToken` and `dailySyncStartTime` set.
            *   Check if they are within their 12-hour active window.
            *   If so, send an FCM *data message* to their device containing their `uid` and `projectId` and `type: 'hourly_coin_sync'`.
        *   **Process Referral Rewards:**
            *   Loop through each Firebase project's credentials.
            *   For each project, query users who have `referredBy` set and `referralBonusAwarded: false`.
            *   For each such referred user:
                *   Find the referrer's user document using the `referredBy` code.
                *   Perform a **Firestore transaction** to atomically update:
                    *   The referred user's `coins` (e.g., add 5000).
                    *   The referrer's `coins` (e.g., add 10000).
                    *   Set `referralBonusAwarded: true` on the referred user's document.
                    *   **(Optional Extension):** Add logic to award referrer bonus based on `daysActiveCount` of referred user (e.g., if `referredUserData.daysActiveCount >= X`). This would require querying for `daysActiveCount` and potentially sending a separate FCM message to the referrer if they are active.
    4.  **Script Logic (Conceptual - e.g., Node.js):**
        ```javascript
        // Example Node.js script (e.g., process_background_tasks.js)
        const admin = require('firebase-admin');

        const projectConfigs = [
            { id: 'rewardly-new', credentials: process.env.FIREBASE_ADMIN_SDK_PROD01 },
            { id: 'rewardly-9fe76', credentials: process.env.FIREBASE_ADMIN_SDK_PROD02 },
            // ... add all 5 projects
        ];

        async function processProject(config) {
            let app;
            try {
                const serviceAccount = JSON.parse(config.credentials);
                app = admin.initializeApp({
                    credential: admin.credential.cert(serviceAccount),
                    databaseURL: `https://${config.id}-default-rtdb.firebaseio.com`
                }, config.id);

                const firestore = app.firestore();
                const messaging = app.messaging();

                console.log(`Processing project: ${config.id}`);

                // --- Hourly Coin Sync ---
                const syncUsersSnapshot = await firestore.collection('users')
                    .where('fcmToken', '!=', null)
                    .where('dailySyncStartTime', '!=', null)
                    .get();

                const syncMessages = [];
                syncUsersSnapshot.forEach(doc => {
                    const userData = doc.data();
                    const uid = doc.id;
                    const fcmToken = userData.fcmToken;
                    const dailySyncStartTimeMillis = userData.dailySyncStartTime;

                    if (fcmToken && dailySyncStartTimeMillis) {
                        const dailySyncStartTime = new Date(dailySyncStartTimeMillis);
                        const elapsedHours = (Date.now() - dailySyncStartTime.getTime()) / (1000 * 60 * 60);

                        if (elapsedHours < 12) {
                            syncMessages.push({
                                token: fcmToken,
                                data: {
                                    type: 'hourly_coin_sync',
                                    uid: uid,
                                    projectId: config.id,
                                },
                            });
                        }
                    }
                });

                if (syncMessages.length > 0) {
                    console.log(`Sending ${syncMessages.length} FCM sync messages for project ${config.id}`);
                    await messaging.sendAll(syncMessages);
                } else {
                    console.log(`No FCM sync messages to send for project ${config.id}`);
                }

                // --- Referral Rewards ---
                const referralUsersSnapshot = await firestore.collection('users')
                    .where('referredBy', '!=', null)
                    .where('referralBonusAwarded', '==', false)
                    .get();

                for (const referredUserDoc of referralUsersSnapshot.docs) {
                    const referredUserData = referredUserDoc.data();
                    const referredUid = referredUserDoc.id;
                    const referrerCode = referredUserData.referredBy;

                    if (referrerCode) {
                        const referrerQuery = await firestore.collection('users')
                            .where('referralCode', '==', referrerCode)
                            .limit(1)
                            .get();

                        if (!referrerQuery.empty) {
                            const referrerDoc = referrerQuery.docs[0];
                            const referrerUid = referrerDoc.id;

                            // Perform transaction for atomic update
                            await firestore.runTransaction(async (transaction) => {
                                const currentReferredUserDoc = await transaction.get(referredUserDoc.ref);
                                const currentReferrerDoc = await transaction.get(referrerDoc.ref);

                                if (currentReferredUserDoc.exists && currentReferrerDoc.exists && !currentReferredUserDoc.data().referralBonusAwarded) {
                                    // Optional: Check referredUserData.daysActiveCount here if needed for referrer bonus
                                    const referredUserCoins = (currentReferredUserDoc.data().coins || 0) + 5000;
                                    const referrerCoins = (currentReferrerDoc.data().coins || 0) + 10000;

                                    transaction.update(referredUserDoc.ref, {
                                        coins: referredUserCoins,
                                        referralBonusAwarded: true,
                                    });
                                    transaction.update(referrerDoc.ref, {
                                        coins: referrerCoins,
                                    });
                                    console.log(`Awarded referral bonus: Referred ${referredUid}, Referrer ${referrerUid} in project ${config.id}`);
                                }
                            });
                        } else {
                            console.warn(`Referrer with code ${referrerCode} not found for referred user ${referredUid} in project ${config.id}`);
                        }
                    }
                }

            } catch (error) {
                console.error(`Error in project ${config.id}:`, error);
            } finally {
                if (app) {
                    await app.delete(); // Clean up Firebase app instance
                }
            }
        }

        async function main() {
            await Promise.all(projectConfigs.map(processProject));
            console.log('All background tasks complete.');
        }

        main().catch(console.error);
        ```
    5.  **GitHub Workflow YAML:**
        ```yaml
        name: Hourly Background Tasks (FCM Sync & Referrals)

        on:
          schedule:
            - cron: '0 * * * *' # Runs every hour

        jobs:
          run-background-tasks:
            runs-on: ubuntu-latest
            steps:
              - name: Checkout code
                uses: actions/checkout@v3

              - name: Set up Node.js
                uses: actions/setup-node@v3
                with:
                  node-version: '16' # Or your preferred Node.js version

              - name: Install Firebase Admin SDK
                run: npm install firebase-admin

              - name: Run Background Tasks Script
                env:
                  FIREBASE_ADMIN_SDK_PROD01: ${{ secrets.FIREBASE_ADMIN_SDK_PROD01 }}
                  FIREBASE_ADMIN_SDK_PROD02: ${{ secrets.FIREBASE_ADMIN_SDK_PROD02 }}
                  # ... add all 5 secrets for your sharded projects
                run: node process_background_tasks.js # Assuming your script is named process_background_tasks.js
        ```
*   **Files:** `.github/workflows/hourly-sync-and-referrals.yml` (new), `process_background_tasks.js` (new script in your repo).
*   **Impact:** Automates hourly coin sync triggers and secure referral reward processing across all sharded projects.

### Step 8: Implement FCM Background Message Handler in Flutter App

*   **Action:** In `lib/main.dart` (or a dedicated FCM service), implement the `FirebaseMessaging.onBackgroundMessage` handler. This handler will be responsible for initializing the correct Firebase app instance, retrieving local coins, updating Firestore, and resetting local coins.
    ```dart
    import 'package:firebase_messaging/firebase_messaging.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:shared_preferences/shared_preferences.dart';
    import 'firebase_project_config_service.dart';
    import 'user_service.dart';
    import 'logger_service.dart';
    import 'local_storage_service.dart';

    @pragma('vm:entry-point')
    Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
      final String? uid = message.data['uid'];
      final String? projectId = message.data['projectId'];
      final String? messageType = message.data['type']; // e.g., 'hourly_coin_sync'

      if (uid == null || projectId == null || messageType == null) {
        LoggerService.error("FCM Background: Missing UID, Project ID, or Message Type in message data.");
        return;
      }

      // Initialize Firebase for the specific project if not already
      if (Firebase.apps.every((app) => app.name != projectId)) {
        await Firebase.initializeApp(
          options: FirebaseProjectConfigService.getOptionsForProject(projectId),
          name: projectId,
        );
      }

      final FirebaseFirestore firestoreInstance = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
      final UserService userService = UserService(firestoreInstance: firestoreInstance);
      final LocalStorageService localStorageService = LocalStorageService();

      LoggerService.info("FCM Background: Processing message type '$messageType' for UID: $uid, Project: $projectId");

      if (messageType == 'hourly_coin_sync') {
        final int locallyEarnedCoins = await localStorageService.getLocallyEarnedCoins(uid);
        final int? dailySyncStartTimeMillis = await localStorageService.getDailySyncStartTime(uid);

        if (dailySyncStartTimeMillis != null) {
          final DateTime dailySyncStartTime = DateTime.fromMillisecondsSinceEpoch(dailySyncStartTimeMillis);
          final Duration elapsed = DateTime.now().difference(dailySyncStartTime);

          if (elapsed.inHours < 12) {
            if (locallyEarnedCoins > 0) {
              await userService.updateCoins(uid, locallyEarnedCoins); // Update Firestore
              await localStorageService.resetLocallyEarnedCoins(uid); // Reset local coins
              LoggerService.info("FCM Background: Synced $locallyEarnedCoins coins for $uid in $projectId. Elapsed: ${elapsed.inHours}h");
            } else {
              LoggerService.info("FCM Background: No local coins to sync for $uid in $projectId. Elapsed: ${elapsed.inHours}h");
            }
          } else {
            LoggerService.info("FCM Background: 12-hour window passed for $uid. Not syncing.");
            await localStorageService.clearDailySyncStartTime(uid); // Clear local state
          }
        } else {
          LoggerService.warning("FCM Background: Daily sync start time not found for $uid.");
        }
      }
      // Add other message types here if needed for future features
    }

    void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(); // Initialize default Firebase app
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      // ... rest of your main function
    }
    ```
*   **Files:** `lib/main.dart`, `lib/user_service.dart`, `lib/local_storage_service.dart`.
*   **Impact:** Enables your app to perform the database update even when closed, triggered by the server.

### Step 9: Update UI to Display Combined Total Balance

*   **Action:** Modify UI elements that display the user's total coin balance (e.g., in `SpinWheelGameScreen`, `profile_screen.dart`) to always show the sum of:
    *   The user's current `coins` balance from Firestore (obtained via `UserDataProvider`).
    *   The `locallyEarnedCoins` from `LocalStorageService`.
    *   This means your UI will need to listen to both the `UserDataProvider` (for Firestore updates) and potentially a stream/notifier from `LocalStorageService` (or re-read `SharedPreferences` on relevant UI updates) to get the most up-to-date local balance.
*   **Impact:** Provides immediate and accurate feedback to the user for all earned coins, while the database update is deferred and batched hourly.

### Step 10: Manage FCM Tokens, Daily Sync Start Time, and Referral Status in Firestore

*   **Action:**
    1.  When a user logs in or registers, get their FCM token (`FirebaseMessaging.instance.getToken()`).
    2.  Store this token in their user document in Firestore (within their assigned sharded project).
    3.  Implement logic to refresh the token (`FirebaseMessaging.onTokenRefresh`) and update it in Firestore if it changes.
    4.  **Crucially:** Store the `dailySyncStartTime` (when the 12-hour window begins for a user) in their Firestore user document. This allows the GitHub Action script to determine which users are eligible for hourly syncs.
    5.  When a new user registers with a referral code, `createUserData` in `lib/user_service.dart` should:
        *   Store `referredBy` (the referrer's code).
        *   Store `referredUserCreatedAt` (timestamp).
        *   Initialize `coins` to `0` (or a base amount without referral bonus).
        *   Add `referralBonusAwarded: false`.
        *   Add `daysActiveCount: 0` and `lastActiveDate: ''` for DAU tracking.
*   **File:** `lib/auth_service.dart`, `lib/user_service.dart`.
*   **Impact:** Ensures the GitHub Action script has all necessary data (FCM token, sync state, referral status) to perform its tasks.

---

This revised plan provides a comprehensive guide for implementing the FCM + GitHub workflow for your hourly coin synchronization, DAU tracking, and secure referral reward processing *without* Firebase Cloud Functions. It's a more complex setup due to managing server-side logic directly in GitHub Actions but offers greater control and cross-platform capabilities.
