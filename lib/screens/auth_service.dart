import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// **AuthService Class**
/// Handles authentication functionalities using Firebase Authentication.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "45384462772-ia06jsdakisp6vhuf6pa3sf1n3kbv0cr.apps.googleusercontent.com", // Add your Web Client ID here
  );

  /// **Checks if a user is logged in**
  bool isUserLoggedIn() {
    return _auth.currentUser != null && _auth.currentUser!.emailVerified;
  }

  /// **Gets the current logged-in user**
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// **Signs up a user and sends an email verification**
  Future<bool> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();
      return true;
    } catch (e) {
      print("Sign Up Error: $e");
      return false;
    }
  }

  /// **Logs in a user only if email is verified**
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user!.emailVerified) {
        return userCredential.user;
      } else {
        await userCredential.user!.sendEmailVerification();
        print("Please verify your email first.");
        return null;
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  /// **Logs out the user (Google & Email)**
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// **Reset Password via Email**
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true; // Email sent successfully
    } catch (e) {
      print("Password Reset Error: $e");
      return false; // Failed to send email
    }
  }

  /// **Google Sign-In Authentication**
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user!.emailVerified) {
        return userCredential.user;
      } else {
        print("Please verify your email first.");
        return null;
      }
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }
}
