flutter_easyloading is a Flutter package for authentication loading animation. It provides a simple and customizable loading indicator that can be easily integrated into Flutter applications.

The loading_animation_widget Flutter package provides a collection of pre-designed and customizable loading animations. best for to replace the skeleton loader animation.



another_flutter_splash_screen; for customized splash screen the best .


hugeicons:  for custom icons pack
iconsax also for icons pack


tooltip package for expalin the features


Use onboarding tours: For complex UIs or very important actions, consider implementing an on-demand, step-by-step onboarding tour that guides the user through the interface, explaining the key features as needed.

// Small icons (lists, chips, badges)
HugeIcon(
  icon: HugeIcons.strokeRoundedHome,
  size: 20.0,
)

// Default/Medium (buttons, app bars)
HugeIcon(
  icon: HugeIcons.strokeRoundedHome,
  size: 24.0,  // ← Most common default
)

// Large (prominent actions, featured content)
HugeIcon(
  icon: HugeIcons.strokeRoundedHome,
  size: 32.0,
)

// Extra Large (hero sections, empty states)
HugeIcon(
  icon: HugeIcons.strokeRoundedHome,
  size: 48.0,
)
Pro tip: Start with Flutter's built-in responsive tools (LayoutBuilder, MediaQuery, Flexible, Expanded) before adding packages. Many apps don't need external dependencies for responsive design.

Purple is often associated with royalty, creativity, and luxury.

Blue is a popular choice for financial and tech companies because it conveys trust, stability, and intelligence.

Gold symbolizes wealth, success, and prestige, making it a strong accent color for a financial app.

 Flutter Bottomsheet for bottom slide things
 


 elevation: 2.0, // This creates a soft shadow
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.0),



    Yes, the GitHub Actions script is designed to run automatically at a particular time, or more accurately, on a recurring schedule.

In the `plan2.md` file, under __Step 7: Create a GitHub Actions Workflow to Send FCM Messages and Process Referrals__, you'll see this section in the YAML configuration:

```yaml
on:
  schedule:
    - cron: '0 * * * *' # Runs every hour
```

Let's break down what `cron: '0 * * * *'` means:

- __`cron` syntax:__ This is a standard way to define schedules in Unix-like systems, and GitHub Actions uses it. It consists of five fields: `minute hour day_of_month month day_of_week`.

- __`0 * * * *`:__

  - `0`: This means "at minute 0" (i.e., at the start of the hour).
  - `*`: This is a wildcard, meaning "every" for that field.
  - So, `0 * * * *` translates to: "At minute 0 of every hour, of every day of the month, of every month, of every day of the week."

__In plain English:__ This configuration tells GitHub Actions to run the workflow __every hour, exactly at the top of the hour (e.g., 1:00 PM, 2:00 PM, 3:00 PM, etc.)__.

__Important Considerations:__

- __GitHub's Scheduling Accuracy:__ While `cron` specifies an exact time, GitHub Actions' scheduler might have slight delays (a few minutes) due to system load. It's generally reliable for hourly tasks but not guaranteed to be precise to the second.
- __Time Zone:__ GitHub Actions `schedule` events run on __UTC time__. You'll need to adjust your `cron` expression if you want it to align with a specific local time zone. For example, if you want it to run at 6 AM India Standard Time (IST, which is UTC+5:30), you'd need to calculate the equivalent UTC time.
- __Workflow Execution:__ When the scheduled time arrives, GitHub Actions will start a new "job" (a virtual machine) to execute the steps defined in your workflow, including running your Node.js script to send FCM messages and process referrals.

So, yes, it runs automatically on a schedule you define, making it a server-side, hands-off way to trigger your background tasks.



I have successfully implemented the FCM + GitHub Workflow for hourly coin synchronization, DAU tracking, and referral rewards as per the `plan2.md` document.

Here's a summary of the changes made:

__Flutter App Modifications:__

- Added `firebase_messaging` package to `pubspec.yaml`.
- Verified Android configuration (`android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`).
- Created `lib/local_storage_service.dart` for local coin storage and management.
- Integrated `LocalStorageService` into `lib/providers/user_data_provider.dart` for combined coin balance display and optimized DAU tracking.
- Modified coin earning logic in `lib/screens/home/spin_wheel_game_screen.dart` to update local storage.
- Implemented client-side DAU tracking in `lib/providers/user_data_provider.dart` and `lib/main.dart`.
- Configured Firebase Cloud Messaging in `lib/main.dart` including background message handling, foreground message listening, and token refresh.
- Updated `lib/auth_service.dart` to store FCM tokens on user registration and sign-in, and `lib/user_service.dart` to accept the `fcmToken` parameter.
- Updated `lib/screens/home/profile_screen.dart` to display the combined total coin balance from Firestore and local storage.
- Replaced `LoggerService` calls with `print` statements in `lib/main.dart`, `lib/auth_service.dart`, and `lib/user_service.dart` to resolve "Undefined name" errors.

__GitHub Actions Workflow and Background Script:__

- Created `process_background_tasks.js` script to handle hourly coin sync and referral reward processing using the Firebase Admin SDK.
- Created `.github/workflows/hourly-sync-and-referrals.yml` to schedule the execution of `process_background_tasks.js` hourly.

__Pending User Action:__

- __You need to generate Firebase service account private keys for each of your 5 Firebase projects and store their JSON content as GitHub Secrets.__ The GitHub Actions workflow (`.github/workflows/hourly-sync-and-referrals.yml`) is configured to use these secrets (e.g., `FIREBASE_ADMIN_SDK_PROD01`, `FIREBASE_ADMIN_SDK_PROD02`, etc.).

Once the GitHub Secrets are configured, the hourly background tasks will run automatically.



Analyze the project or lib folder and GOAL: slight modification the app currently uses five firebase project , so i thought can i add a few more , adding few more firebase projects , need to make heacy adjustment in the app or what i want to just confirm


Analyze the project or lib folder and GOAL: read @/plan2.md file and check all the thing mentioned in it is already implemented in the app