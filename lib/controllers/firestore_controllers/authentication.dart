// authentication.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'firetore_user_controller.dart';

class Authentication {
  final FirestoreUserController _firestoreUserController = FirestoreUserController();

  Future<String?> signIn(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final userData = await _firestoreUserController.getUser(userCredential.user!.uid);

      if (userData != null) {
        return userCredential.user!.uid;
      } else {
        throw Exception("User data not found.");
      }
    } catch (e) {
      throw Exception("Sign-in failed: $e");
    }
  }


  Future<void> signUp(String email, String password, String name, String phoneNumber) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestoreUserController.addOrUpdateUser(userCredential.user!.uid, {
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'notificationsEnabled': true,
        'themePreference': 'Light Mode',
      });
    } catch (e) {
      throw Exception("Sign-up failed: $e");
    }
  }
}
