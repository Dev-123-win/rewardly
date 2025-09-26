import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_service.dart';
import 'dart:developer' as developer;

class UserDataProvider with ChangeNotifier {
  final UserService _userService = UserService();
  DocumentSnapshot? _userData;
  bool _isLoading = true; // Add a loading state

  DocumentSnapshot? get userData => _userData;
  bool get isLoading => _isLoading;

  UserDataProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      loadUserData(user);
    });
  }

  Future<void> loadUserData(User? user) async {
    _isLoading = true; // Set loading to true at the start
    notifyListeners(); // Notify listeners to rebuild with loading state
    if (user != null) {
      try {
        _userService.getUserData(user.uid).listen((snapshot) {
          _userData = snapshot;
          _isLoading = false; // Set loading to false when data is loaded
          notifyListeners();
        });
      } catch (e, stackTrace) {
        developer.log('Error loading user data', error: e, stackTrace: stackTrace);
        _isLoading = false; // Ensure loading is set to false even on error
        notifyListeners();
      }
    } else {
      _userData = null;
      _isLoading = false; // Also set loading to false when user is null
      notifyListeners();
    }
  }
}
