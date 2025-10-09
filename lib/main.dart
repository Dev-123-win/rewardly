import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'firebase_project_config_service.dart'; // Import FirebaseProjectConfigService
import 'providers/user_data_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Crashlytics
import 'dart:ui'; // Import for PlatformDispatcher
import 'models/auth_result.dart'; // Import AuthResult

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize all sharded Firebase projects
  await FirebaseProjectConfigService.initializeAllFirebaseProjects();

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  MobileAds.instance.initialize(); // Initialize AdMob
  await RemoteConfigService().initialize(); // Initialize Remote Config
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
