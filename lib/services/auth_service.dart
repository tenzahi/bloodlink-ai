import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔐 REGISTER
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Register error: $e");
      return null;
    }
  }

  // 🔵 LOGIN
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // 🔴 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 👤 GET CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}