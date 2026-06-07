import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
  }
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }
  Future<UserCredential> createAccount(String email, String password) async {
    String appName = 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}';
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: appName,
      options: Firebase.app().options,
    );
    try {
      UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await secondaryApp.delete();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      await secondaryApp.delete();
      throw _handleAuthError(e.code);
    } catch (e) {
      await secondaryApp.delete();
      throw e.toString();
    }
  }
  Future<UserCredential> createTeacherAccount(String email, String password) => createAccount(email, password);
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}