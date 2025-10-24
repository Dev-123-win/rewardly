# Plan 1: WorkManager Integration for Hourly Coin Sync

**Goal:** Implement `WorkManager` to perform hourly database updates for earned coins, limited to a 12-hour window per day, with local updates in between. The displayed total balance will always reflect the sum of the Firestore balance and any locally accumulated coins.

**Assumptions:**
*   You are primarily targeting Android, as `WorkManager` is an Android-specific solution.
*   The background tasks will be "deferrable" – meaning they don't need to run at an *exact* precise second, but rather around a scheduled time, as determined by the Android OS.

---

## Detailed Plan for WorkManager Integration with Specific Scheduling:

### Step 1: Add the `workmanager` Package

*   **Action:** Add `workmanager: ^latest_version` to your `pubspec.yaml` file.
*   **Impact:** Enables Flutter to interact with Android's WorkManager API.

### Step 2: Configure Android Manifest and Application Class

*   **Action:**
    1.  **`android/app/src/main/AndroidManifest.xml`**: Ensure the following `WorkManager` components are declared within the `<application>` tag. This is crucial for `WorkManager` to function correctly.
        ```xml
        <provider
            android:name="androidx.work.impl.WorkManagerInitializer"
            android:authorities="${applicationId}.workmanager-init"
            android:enabled="false"
            android:exported="false" />
        <receiver android:name="androidx.work.impl.background.systemalarm.SystemAlarmServiceReceiver"
            android:enabled="false"
            android:exported="false" />
        <receiver android:name="androidx.work.impl.background.systemjob.SystemJobService"
            android:enabled="false"
            android:exported="false" />
        <service android:name="androidx.work.impl.background.systemalarm.SystemAlarmService"
            android:enabled="false"
            android:exported="false" />
        <service android:name="androidx.work.impl.background.systemjob.SystemJobService"
            android:enabled="false"
            android:exported="false"
            android:permission="android.permission.BIND_JOB_SERVICE" />
        ```
    2.  **`android/app/src/main/java/.../MainApplication.java` (or `.kt`)**: Modify your main Android application class to initialize `WorkManager` and register your Dart entry point.
        *   **Java Example (`MainApplication.java`):**
            ```java
            import io.flutter.app.FlutterApplication;
            import io.flutter.plugin.common.PluginRegistry;
            import io.flutter.plugins.GeneratedPluginRegistrant;
            import be.tramckrijte.workmanager.WorkmanagerPlugin;

            public class MainApplication extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {
                @Override
                public void onCreate() {
                    super.onCreate();
                    WorkmanagerPlugin.setInitializer(this, this);
                }

                @Override
                public void registerWith(PluginRegistry registry) {
                    GeneratedPluginRegistrant.registerWith(registry);
                }
            }
            ```
        *   **Kotlin Example (`MainApplication.kt`):**
            ```kotlin
            import io.flutter.app.FlutterApplication
            import io.flutter.plugin.common.PluginRegistry
            import io.flutter.plugins.GeneratedPluginRegistrant
            import be.tramckrijte.workmanager.WorkmanagerPlugin

            class MainApplication: FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
                override fun onCreate() {
                    super.onCreate()
                    WorkmanagerPlugin.setInitializer(this, this)
                }

                override fun registerWith(registry: PluginRegistry) {
                    GeneratedPluginRegistrant.registerWith(registry)
                }
            }
            ```
*   **Impact:** Allows `WorkManager` to run your Dart code in the background.

### Step 3: Create a Top-Level Dart Entry Point for Background Tasks

*   **Action:** Create a new Dart file, e.g., `lib/background_tasks.dart`, with a top-level function that `WorkManager` will call. This function will be the entry point for all background tasks.
*   **File:** `lib/background_tasks.dart`
*   **Impact:** This is the bridge between the native Android `WorkManager` and your Flutter/Dart code.

### Step 4: Implement Local Coin Storage and Management

*   **Action:**
    1.  Create a new service, `lib/local_storage_service.dart`, to encapsulate `SharedPreferences` operations.
    2.  Add methods to `LocalStorageService` to:
        *   `getLocallyEarnedCoins(uid)`: Retrieve locally accumulated coins.
        *   `addLocallyEarnedCoins(uid, amount)`: Add coins to the local total.
        *   `resetLocallyEarnedCoins(uid)`: Set local coins to 0.
        *   `setDailySyncStartTime(uid, timestamp)`: Store when the 12-hour sync window started.
        *   `getDailySyncStartTime(uid)`: Retrieve the start time.
        *   `clearDailySyncStartTime(uid)`: Clear the start time.
*   **Files:** `lib/local_storage_service.dart` (new), `lib/user_data_provider.dart` (to use this service).
*   **Impact:** Allows coins to be accumulated locally without immediate Firestore writes and manages the daily sync window state.

### Step 5: Modify Coin Earning Logic to Update Local Storage

*   **Action:** When a user earns coins (e.g., from spin wheel, ads), update the `locallyEarnedCoins` using `LocalStorageService.addLocallyEarnedCoins(uid, amount)` instead of directly updating Firestore.
*   **File:** `lib/screens/home/spin_wheel_game_screen.dart` (in `_updateUserCoins` and similar methods), and any other coin-earning screens/services.
*   **Impact:** Reduces immediate Firestore writes, as only local storage is updated.

### Step 6: Implement the `HourlyCoinSyncWorker` Logic

*   **Action:** Inside `lib/background_tasks.dart`, define your `callbackDispatcher` and the `HourlyCoinSyncWorker` logic. This worker will:
    ```dart
    import 'package:workmanager/workmanager.dart';
    import 'package:firebase_core/firebase_core.dart';
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:shared_preferences/shared_preferences.dart'; // For local storage
    import 'firebase_project_config_service.dart';
    import 'user_service.dart';
    import 'logger_service.dart';
    import 'local_storage_service.dart'; // New service

    const String HOURLY_COIN_SYNC_TASK = "hourlyCoinSyncTask";
    const String DAILY_SYNC_START_TASK = "dailySyncStartTask"; // For scheduling next day's start

    @pragma('vm:entry-point')
    void callbackDispatcher() {
      Workmanager().executeTask((task, inputData) async {
        LoggerService.info("Native background task: $task started.");

        final String? uid = inputData?['uid'];
        final String? projectId = inputData?['projectId'];

        if (uid == null || projectId == null) {
          LoggerService.error("WorkManager: Missing UID or Project ID for task $task");
          return Future.value(false);
        }

        try {
          // Initialize Firebase for the specific project
          await Firebase.initializeApp(
            options: FirebaseProjectConfigService.getOptionsForProject(projectId),
            name: projectId,
          );
          final FirebaseFirestore firestoreInstance = FirebaseFirestore.instanceFor(app: FirebaseProjectConfigService.getFirebaseApp(projectId));
          final UserService userService = UserService(firestoreInstance: firestoreInstance);
          final LocalStorageService localStorageService = LocalStorageService(); // Initialize local storage

          if (task == HOURLY_COIN_SYNC_TASK) {
            final int locallyEarnedCoins = await localStorageService.getLocallyEarnedCoins(uid);
            final int? dailySyncStartTimeMillis = await localStorageService.getDailySyncStartTime(uid);

            if (dailySyncStartTimeMillis != null) {
              final DateTime dailySyncStartTime = DateTime.fromMillisecondsSinceEpoch(dailySyncStartTimeMillis);
              final Duration elapsed = DateTime.now().difference(dailySyncStartTime);

              if (elapsed.inHours < 12) {
                if (locallyEarnedCoins > 0) {
                  await userService.updateCoins(uid, locallyEarnedCoins); // Update Firestore
                  await localStorageService.resetLocallyEarnedCoins(uid); // Reset local coins
                  LoggerService.info("WorkManager: Synced $locallyEarnedCoins coins for $uid in $projectId. Elapsed: ${elapsed.inHours}h");
                } else {
                  LoggerService.info("WorkManager: No local coins to sync for $uid in $projectId. Elapsed: ${elapsed.inHours}h");
                }
              } else {
                // 12-hour window passed, cancel hourly task and schedule next day's start
                LoggerService.info("WorkManager: 12-hour window passed for $uid. Cancelling hourly sync.");
                await Workmanager().cancelByUniqueName('hourly_sync_$uid');
                await localStorageService.clearDailySyncStartTime(uid); // Clear start time

                // Schedule a one-time task for tomorrow to restart the cycle
                final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
                final DateTime nextDayStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6); // e.g., 6 AM tomorrow
                Duration initialDelay = nextDayStart.difference(DateTime.now());

                if (initialDelay.isNegative) { // If 6 AM tomorrow is already passed, schedule for day after
                  final DateTime dayAfterTomorrow = tomorrow.add(const Duration(days: 1));
                  final DateTime dayAfterTomorrowStart = DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 6);
                  initialDelay = dayAfterTomorrowStart.difference(DateTime.now());
                }

                await Workmanager().registerOneOffTask(
                  'daily_start_sync_$uid',
                  DAILY_SYNC_START_TASK,
                  initialDelay: initialDelay,
                  inputData: {'uid': uid, 'projectId': projectId},
                  constraints: Constraints(networkType: NetworkType.CONNECTED),
                );
                LoggerService.info("WorkManager: Scheduled next daily sync start for $nextDayStart.");
              }
            } else {
              LoggerService.warning("WorkManager: Daily sync start time not found for $uid. This should not happen for HOURLY_COIN_SYNC_TASK.");
            }
          } else if (task == DAILY_SYNC_START_TASK) {
            // This task is triggered to start the daily 12-hour cycle
            LoggerService.info("WorkManager: Starting daily sync cycle for $uid in $projectId.");
            await localStorageService.setDailySyncStartTime(uid, DateTime.now().millisecondsSinceEpoch);
            // Schedule the hourly sync
            await Workmanager().registerPeriodicTask(
              'hourly_sync_$uid',
              HOURLY_COIN_SYNC_TASK,
              initialDelay: const Duration(hours: 1), // First sync after 1 hour
              frequency: const Duration(hours: 1),
              inputData: {'uid': uid, 'projectId': projectId},
              constraints: Constraints(networkType: NetworkType.CONNECTED),
            );
          }
        } catch (e, s) {
          LoggerService.error("WorkManager: Error executing task $task for $uid in $projectId", e, s);
          // FirebaseCrashlytics.instance.recordError(e, s, reason: 'WorkManager task failed'); // Uncomment if Crashlytics is initialized in background
          return Future.value(false); // Indicate failure
        }
        return Future.value(true); // Indicate success
      });
    }
    ```
*   **Files:** `lib/background_tasks.dart`, `lib/user_service.dart` (ensure `updateCoins` is robust), `lib/local_storage_service.dart`.
*   **Impact:** This is the core logic for hourly updates, local coin synchronization, and managing the 12-hour window.

### Step 7: Schedule the Initial `WorkManager` Task from Flutter

*   **Action:** When a user logs in or registers, schedule the *initial* `DAILY_SYNC_START_TASK`. This one-time task will then kick off the periodic hourly sync.
    *   **Initial Scheduling:** Schedule the `DAILY_SYNC_START_TASK` to run at a specific time (e.g., 6 AM) on the *next day* after login/registration.
*   **File:** `lib/auth_service.dart` (after successful login/registration) or `lib/main.dart`.
*   **Impact:** Ensures your background tasks are scheduled and persist across app restarts, initiating the daily cycle.

**Example Scheduling in `AuthService` (after user login/registration):**
```dart
import 'package:workmanager/workmanager.dart';
// ... other imports

// In AuthService, after successful login/registration:
Future<void> _scheduleDailyCoinSync(String uid, String projectId) async {
  // Cancel any existing tasks for this user to prevent duplicates
  await Workmanager().cancelByUniqueName('daily_start_sync_$uid');
  await Workmanager().cancelByUniqueName('hourly_sync_$uid');

  // Schedule the first daily sync start for tomorrow at 6 AM
  final DateTime now = DateTime.now();
  DateTime nextDayStart = DateTime(now.year, now.month, now.day, 6).add(const Duration(days: 1));
  if (nextDayStart.isBefore(now)) { // If 6 AM tomorrow is already passed, schedule for day after
    nextDayStart = nextDayStart.add(const Duration(days: 1));
  }
  final Duration initialDelay = nextDayStart.difference(now);

  await Workmanager().registerOneOffTask(
    'daily_start_sync_$uid',
    DAILY_SYNC_START_TASK,
    initialDelay: initialDelay,
    inputData: {'uid': uid, 'projectId': projectId},
    constraints: Constraints(networkType: NetworkType.CONNECTED),
  );
  LoggerService.info("Scheduled initial daily sync start for $uid at $nextDayStart.");
}
```

### Step 8: Update UI to Display Combined Total Balance

*   **Action:** Modify UI elements that display the user's total coin balance (e.g., in `SpinWheelGameScreen`, `profile_screen.dart`) to always show the sum of:
    *   The user's current `coins` balance from Firestore (obtained via `UserDataProvider`).
    *   The `locallyEarnedCoins` from `LocalStorageService`.
    *   This means your UI will need to listen to both the `UserDataProvider` (for Firestore updates) and potentially a stream/notifier from `LocalStorageService` (or re-read `SharedPreferences` on relevant UI updates) to get the most up-to-date local balance.
*   **Impact:** Provides immediate and accurate feedback to the user for all earned coins, while the database update is deferred and batched hourly.

---

This plan provides a robust way to implement your specific scheduling requirements using `WorkManager`, leveraging local storage to reduce immediate Firestore interactions and manage the daily sync window.
