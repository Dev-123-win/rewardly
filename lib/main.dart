import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'firebase_project_config_service.dart'; // Import FirebaseProjectConfigService
import 'providers/user_data_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Crashlytics
import 'dart:ui'; // Import for PlatformDispatcher
import 'models/auth_result.dart'; // Import AuthResult
import 'ad_service.dart'; // Import AdService
import 'package:firebase_messaging/firebase_messaging.dart'; // Import FirebaseMessaging
import 'package:cloud_firestore/cloud_firestore.dart'; // Import CloudFirestore
import 'local_storage_service.dart'; // Import LocalStorageService
import 'user_service.dart'; // Import UserService
import 'package:firebase_core/firebase_core.dart'; // Explicitly import firebase_core
import 'logger_service.dart'; // Import LoggerService

import 'remote_config_service.dart';
import 'wrapper.dart';
import 'theme_provider.dart';

// Define custom gradient for the app
const LinearGradient appGradient = LinearGradient(
  colors: [
    Color(0xFF8A2BE2), // Purple (Blue Violet)
    Color(0xFF4169E1), // Blue (Royal Blue)
    Color(0xFFFFD700), // Gold
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Ensure Consistent AuthService Instance in main.dart:
final AuthService _authService = AuthService();

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use Firebase services in your background callback,
  // you must first initialize Firebase.
  await FirebaseProjectConfigService.initializeAllFirebaseProjects();

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
  // Initialize the default Firebase app first
  await Firebase.initializeApp();

  // Set system UI overlay style for a white status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.lightBlue, // Set status bar color to white
    statusBarIconBrightness: Brightness.light, // Use dark icons for better visibility on white
    statusBarBrightness: Brightness.light, // For iOS
  ));
  // Initialize all sharded Firebase projects
  await FirebaseProjectConfigService.initializeAllFirebaseProjects();

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize AdService (which in turn initializes MobileAds)
  await AdService().initialize();
  await RemoteConfigService().initialize(); // Initialize Remote Config

  // Configure Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  LoggerService.info('User granted permission: ${settings.authorizationStatus}');

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    LoggerService.info('Got a message whilst in the foreground!');
    LoggerService.info('Message data: ${message.data}');

    if (message.notification != null) {
      LoggerService.info('Message also contained a notification: ${message.notification}');
      // You can display a local notification here if needed
    }
    // Potentially trigger UI updates or data fetches based on message.data
  });

  // Handle token refresh
  messaging.onTokenRefresh.listen((fcmToken) {
    LoggerService.info('FCM Token refreshed: $fcmToken');
    // TODO: Send this token to your backend or update in Firestore for the current user
    // This will be handled in AuthService/UserService when a user is logged in.
  }).onError((err) {
    LoggerService.error('Error refreshing FCM token: $err');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        StreamProvider<AuthResult?>.value(
          value: _authService.user, // Use the consistent instance
          initialData: null,
        ),
        ChangeNotifierProxyProvider<AuthResult?, UserDataProvider>(
          create: (context) => UserDataProvider(),
          update: (context, authResult, userDataProvider) => userDataProvider!
            ..updateUser(authResult?.uid, projectId: authResult?.projectId),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rewardly App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A2BE2), // Use purple as the seed color
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Set AppBar background to white
          foregroundColor: Colors.black, // Set AppBar text/icon color to black for contrast
          elevation: 0, // Remove shadow
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Set BottomNavigationBar background to white
          selectedItemColor: Color(0xFF8A2BE2), // Use primary color for selected item
          unselectedItemColor: Colors.grey, // Use grey for unselected items
        ),
        fontFamily: 'Lato', // Default font for body text
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontFamily: 'Lato'),
          titleSmall: TextStyle(fontFamily: 'Lato'),
          bodyLarge: TextStyle(fontFamily: 'Lato'),
          bodyMedium: TextStyle(fontFamily: 'Lato'),
          labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A2BE2), // Use purple as the seed color
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Set AppBar background to white for dark theme too
          foregroundColor: Colors.black, // Set AppBar text/icon color to black for contrast
          elevation: 0, // Remove shadow
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Set BottomNavigationBar background to white for dark theme too
          selectedItemColor: Color(0xFF8A2BE2), // Use primary color for selected item
          unselectedItemColor: Colors.grey, // Use grey for unselected items
        ),
        fontFamily: 'Lato',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
          displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
          displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
          headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
          headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
          titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
          titleMedium: TextStyle(fontFamily: 'Lato'),
          titleSmall: TextStyle(fontFamily: 'Lato'),
          bodyLarge: TextStyle(fontFamily: 'Lato'),
          bodyMedium: TextStyle(fontFamily: 'Lato'),
          labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900),
        ),
      ),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: const Wrapper(),
    );
  }
}
