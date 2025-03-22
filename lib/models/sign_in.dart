import 'package:firebase_auth/firebase_auth.dart';

class SignIn {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> SignInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("✅User signed in successfully!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('❌No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('❌Wrong password provided for that user.');
      }
    } catch (e) {
      print('❌Error: $e');
    }
  }
}