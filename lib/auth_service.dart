import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register with email and password
  Future<dynamic> registerWithEmailAndPassword(String email, String password, {String? referralCode}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await UserService().createUserData(user.uid, email, referralCode: referralCode);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign in with email and password
  Future<dynamic> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // print(e.toString()); // Avoid print in production code
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges();
  }
}
