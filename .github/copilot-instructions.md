# AI Agent Instructions for Rewardly Flutter App

## Project Overview
Rewardly is a Flutter mobile app using Firebase for backend services. Key characteristics:
- Multi-project Firebase architecture with sharding across 5 separate Firebase projects for scalability
- Authentication, real-time data sync, and background task processing
- Heavy focus on performance monitoring and error logging
- Material Design 3 theming with custom gradients and typography

## Core Architecture

### Firebase Project Sharding
- User data is sharded across 5 Firebase projects (`rewardly-new`, `rewardly-9fe76`, etc.)
- New users are assigned to projects via round-robin in `FirebaseProjectConfigService`
- Authentication operations check all shards to locate user data
- Each shard maintains its own Firestore instance

### Key Services
- `AuthService`: Manages multi-shard authentication with RxDart streams
- `UserService`: Handles user data operations in sharded Firestore DBs
- `RemoteConfigService`: Manages feature flags and dynamic configuration
- `LoggerService`: Centralized logging with Crashlytics integration
- `DeviceService`: Device identification and validation
- `FirebaseProjectConfigService`: Manages Firebase project sharding

### Background Processing
- FCM (Firebase Cloud Messaging) for push notifications
- Background handlers for coin synchronization (`_firebaseMessagingBackgroundHandler` in `main.dart`)
- Local storage for offline data persistence

## Development Workflows

### Setting Up
1. Ensure Flutter SDK ≥3.9.0 is installed
2. Install dependencies: `flutter pub get`
3. Configure Firebase: Each shard needs its own `google-services.json`

### Testing
- Use `flutter test` for unit tests
- Widget tests in `test/widget_test.dart`
- Run integration tests with `flutter drive`

### Common Tasks
```dart
// Adding a new Firebase shard
// 1. Add config in lib/firebase_configs/
// 2. Register in FirebaseProjectConfigService._projectOptions

// Implementing new background task
// 1. Add handler in _firebaseMessagingBackgroundHandler
// 2. Register task type in message data
```

## Critical Patterns

### Authentication Flow
- Users can exist in any shard - auth operations check all shards
- Device ID validation prevents multiple accounts (configurable via `_enableDeviceIdCheck`)
- FCM tokens are updated on sign-in/registration

### Error Handling
```dart
try {
  // Operation
} on FirebaseAuthException catch (e, s) {
  LoggerService.error('Context: ${e.code}', e, s);
  FirebaseCrashlytics.instance.recordError(e, s);
  return friendlyErrorMessage(e.code);
}
```

### UI/UX Conventions
- Use `AnimatedTap` widget for touch feedback
- Neuromorphic design constants in `neuromorphic_constants.dart`
- Loading states use Shimmer effect (`shimmer_loading.dart`)
- Typography system uses Poppins (headers) and Lato (body)

## Integration Points
- Google Mobile Ads for monetization
- Firebase services (Auth, Firestore, FCM, Crashlytics)
- In-app WebView for external content
- Share functionality via share_plus

## Known Limitations
- Firebase sharding currently Android-only
- Device ID check disabled by default (`_enableDeviceIdCheck = false`)
- Background sync limited to 12-hour window