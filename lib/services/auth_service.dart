import 'dart:io' show Platform;
import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Móvil (Android/iOS)
        final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
        //if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.idToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential.user;
      } else {
        // Web, Windows, MacOS, Linux
        final UserCredential userCredential =
            await _auth.signInWithPopup(GoogleAuthProvider());
        return userCredential.user;
      }
    } catch (e) {
      printToConsole("Error en Google Sign-In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
