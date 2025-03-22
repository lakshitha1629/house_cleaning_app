import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SignUp {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> SignupUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("✅User signed up successfully!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('❌The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('❌The account already exists for that email.');
      }
    } catch (e) {
      print('❌Error: $e');

  }
}


}