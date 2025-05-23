// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_remote_datasource.dart';
import 'package:flutter/services.dart';


class AuthService {
  final AuthRemoteDataSource _remote = AuthRemoteDataSource();

  Future<User?> loginWithEmail(String email, String password) async {
    final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, password: password);
    return userCred.user;
  }

  Future<User?> loginWithGoogle() async {
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null;

  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
  final token = await userCred.user?.getIdToken(true);

  if (token != null) {
    await Clipboard.setData(ClipboardData(text: token));
    print("📋 JWT token copied to clipboard.");
  }

  return userCred.user;
}


    Future<void> verifyUserSession(User user) async {
    final jwt = await user.getIdToken();
    
    // 🔍 Call backend and decode user profile
    final userData = await _remote.getUserData(jwt!);
    print("🔍 userData from backend: $userData");

    // ✅ Check internal_id safely
    final internalId = userData['internal_id'] ?? user.email ?? user.uid;
    if (internalId is! String) {
      throw Exception("internal_id is missing or not a string: $internalId");
    }

    // ✅ Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('internal_id', internalId);
    await prefs.setString('authToken', jwt);
  }


  Future<void> signUpWithEmail(String email, String password) async {
    final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, password: password);
    final user = userCred.user!;
    await user.sendEmailVerification();
    await user.reload();
    if (!user.emailVerified) throw Exception("Email not verified.");

    final jwt = await user.getIdToken(true);
    final username = email.split('@')[0];
    await _remote.createUser(jwt!, username);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('internal_id', username);
    await prefs.setString('authToken', jwt);
  }

  Future<void> signUpWithGoogle({required String schoolName}) async {
    final user = await loginWithGoogle();
    if (user == null) throw Exception("Google sign-up failed");

    final jwt = await user.getIdToken(true);
    final username = user.email!.split('@')[0];

    await _remote.createUser(jwt!, username);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('internal_id', username);
    await prefs.setString('authToken', jwt);
    await prefs.setString('school', schoolName); // ✅ save school locally
  }

}