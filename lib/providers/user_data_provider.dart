import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/user_service.dart';
import 'dart:developer' as developer;

class UserDataProvider with ChangeNotifier {
  final UserService _userService = UserService();
  DocumentSnapshot? _userData;

  DocumentSnapshot? get userData => _userData;

  UserDataProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      loadUserData(user);
    });
  }

  Future<void> loadUserData(User? user) async {
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await _userService.getUserData(user.uid).first;
        _userData = snapshot;
        notifyListeners();
      } catch (e, stackTrace) {
        developer.log('Error loading user data', error: e, stackTrace: stackTrace);
      }
    } else {
      _userData = null;
      notifyListeners();
    }
  }
}
