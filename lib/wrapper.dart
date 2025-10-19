import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:provider/provider.dart';
import 'dart:async'; // Import for StreamSubscription
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus
import 'screens/auth/authenticate.dart';
import 'screens/home/home.dart';
import 'widgets/exit_confirmation_overlay.dart';
import 'screens/no_internet_screen.dart'; // Import NoInternetScreen
import 'logger_service.dart'; // Import LoggerService
import 'models/auth_result.dart'; // Import AuthResult
import 'providers/user_data_provider.dart'; // Import UserDataProvider

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  DateTime? _lastPressedAt;
  bool _showExitConfirmation = false;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (mounted) {
      setState(() {
        // Check if any of the connection types indicate no internet
        if (result.contains(ConnectivityResult.none)) {
          _connectionStatus = ConnectivityResult.none;
        } else if (result.contains(ConnectivityResult.wifi)) {
          _connectionStatus = ConnectivityResult.wifi;
        } else if (result.contains(ConnectivityResult.mobile)) {
          _connectionStatus = ConnectivityResult.mobile;
        } else if (result.contains(ConnectivityResult.ethernet)) {
          _connectionStatus = ConnectivityResult.ethernet;
        } else if (result.contains(ConnectivityResult.bluetooth)) {
          _connectionStatus = ConnectivityResult.bluetooth;
        } else if (result.contains(ConnectivityResult.vpn)) {
          _connectionStatus = ConnectivityResult.vpn;
        } else {
          _connectionStatus = ConnectivityResult.other; // Fallback for other or unknown
        }
      });
    }
  }

  Future<void> _onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) {
      return;
    }
    if (_showExitConfirmation) {
      // If the confirmation is already showing, and back is pressed again,
      // it means the user wants to exit.
      SystemNavigator.pop(); // Exit the app
      return;
    }

    if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = DateTime.now();
      _showExitConfirmationDialog(); // Show the custom dialog
      return;
    }
    SystemNavigator.pop(); // Exit the app on double back press
  }

  void _showExitConfirmationDialog() {
    setState(() {
      _showExitConfirmation = true;
    });
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make background transparent to show custom shape
      builder: (BuildContext context) {
        return ExitConfirmationOverlay(
          onCancel: _cancelExit,
          onExit: _exitApp,
        );
      },
    ).whenComplete(() {
      // Reset state if the bottom sheet is dismissed by other means (e.g., swipe down if allowed)
      if (mounted) {
        setState(() {
          _showExitConfirmation = false;
          _lastPressedAt = null;
        });
      }
    });
  }

  void _cancelExit() {
    Navigator.of(context).pop(); // Dismiss the bottom sheet
    setState(() {
      _showExitConfirmation = false;
      _lastPressedAt = null;
    });
  }

  void _exitApp() {
    Navigator.of(context).pop(); // Dismiss the bottom sheet first
    SystemNavigator.pop(); // Exit the app
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus == ConnectivityResult.none) {
      return NoInternetScreen(onRetry: _checkConnectivity);
    }

    final authResult = Provider.of<AuthResult?>(context);
    LoggerService.info('Wrapper rebuilding. User: ${authResult?.uid ?? 'null'}');

    Widget content;
    if (authResult?.uid == null) {
      content = const Authenticate();
    } else {
      // Ensure UserDataProvider is available before calling its methods
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      // Call the daily activity check when the user is authenticated and data is loaded
      // This will run on app startup/login and periodically as the Wrapper rebuilds
      // (e.g., due to connectivity changes, though UserDataProvider itself will handle data updates)
      if (!userDataProvider.isLoading && userDataProvider.userData != null) {
        userDataProvider.checkDailyActivityAndReferralReward();
      }
      content = const Home();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _onPopInvokedWithResult(didPop, result),
      child: Stack(
        children: [
          content,
          // The ExitConfirmationOverlay is now shown via showModalBottomSheet,
          // so it's no longer directly in the Stack here.
        ],
      ),
    );
  }
}
