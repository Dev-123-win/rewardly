import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/user_service.dart';

class UserDataProvider with ChangeNotifier {
  final UserService _userService = UserService();
  DocumentSnapshot? _userData;

  DocumentSnapshot? get userData => _userData;

  UserDataProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userService.getUserData(user.uid).listen((snapshot) {
          _userData = snapshot;
          notifyListeners();
        });
      } else {
        _userData = null;
        notifyListeners();
      }
    });
  }
}
