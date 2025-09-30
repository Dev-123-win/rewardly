import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Import for StreamSubscription
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus
import 'screens/auth/authenticate.dart';
import 'screens/home/home.dart';
import 'widgets/exit_confirmation_overlay.dart';
import 'screens/no_internet_screen.dart'; // Import NoInternetScreen

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
      setState(() {
        _showExitConfirmation = false;
      });
      return;
    }

    if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = DateTime.now();
      setState(() {
        _showExitConfirmation = true;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  void _cancelExit() {
    setState(() {
      _showExitConfirmation = false;
      _lastPressedAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus == ConnectivityResult.none) {
      return NoInternetScreen(onRetry: _checkConnectivity);
    }

    final user = Provider.of<User?>(context);

    Widget content;
    if (user == null) {
      content = const Authenticate();
    } else {
      content = const Home();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _onPopInvokedWithResult(didPop, result),
      child: Stack(
        children: [
          content,
          if (_showExitConfirmation)
            ExitConfirmationOverlay(onCancel: _cancelExit),
        ],
      ),
    );
  }
}
