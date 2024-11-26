import '../models/user.dart';
import 'database_helper.dart';
import 'dart:convert'; // For utf8.encode
import 'package:crypto/crypto.dart'; // For sha256

class UserController {

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Hash the password using SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    return sha256.convert(bytes).toString(); // Hash and convert to string
  }

  Future<User?> getUserById(String id) async {
  final users = await _dbHelper.getUsers();
  final userMap = users.firstWhere((user) => user['id'] == id, orElse: () => {});
  if (userMap.isEmpty) return null;
  return User(
  id: userMap['id'],
  name: userMap['name'],
  email: userMap['email'],
  phoneNumber: userMap['phoneNumber'],
  password: userMap['password'],
  themePreference: userMap['themePreference'],
  notificationsEnabled: userMap['notificationsEnabled'] == 1,
  );
  }

  Future<void> saveUser(User user) async {
  await _dbHelper.insertUser({
  'id': user.id,
  'name': user.name,
  'email': user.email,
  'phoneNumber': user.phoneNumber,
  'password': user.password, // Assuming hashed password
  'themePreference': user.themePreference,
  'notificationsEnabled': user.notificationsEnabled ? 1 : 0,
  });
  }

  Future<void> editUser(User user) async {
    await _dbHelper.updateUser({
      'name': user.name,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'themePreference': user.themePreference,
      'notificationsEnabled': user.notificationsEnabled ? 1 : 0,
    }, user.id);
  }



  Future<List<User>> getAllUsers() async {
  final users = await _dbHelper.getUsers();
  return users.map((userMap) {
  return User(
  id: userMap['id'],
  name: userMap['name'],
  email: userMap['email'],
  phoneNumber: userMap['phoneNumber'],
  password: userMap['password'],
  themePreference: userMap['themePreference'],
  notificationsEnabled: userMap['notificationsEnabled'] == 1,
  );
  }).toList();
  }


  Future<String?> signIn(String email, String password) async {
    try {
      String hashedPassword = hashPassword(password);
      final users = await _dbHelper.getUsers();
      final userMap = users.firstWhere(
            (user) => user['email'] == email && user['password'] == hashedPassword,
        orElse: () => {},
      );

      if (userMap.isNotEmpty) {
        return userMap['id'] as String; // Return user ID on success
      }
      return null; // Return null if no match
    } catch (e) {
      print("Error during sign-in: $e");
      return null; // Handle error case
    }
  }



  // Sign up method to save user details
  Future<bool> signUp(String email, String password, String name, String phone,
      String themePreference, bool notificationsEnabled) async {
    if (email.isNotEmpty &&
        password.isNotEmpty &&
        name.isNotEmpty &&
        phone.isNotEmpty) {
      String hashedPassword = hashPassword(password);

      User newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phoneNumber: phone,
        password: hashedPassword, // Save hashed password
        themePreference: themePreference,
        notificationsEnabled: notificationsEnabled,
      );

      try {
        // Use the existing saveUser function
        await saveUser(newUser);
        return true; // Sign-up successful
      } catch (e) {
        print("Error during sign-up: $e");
        return false; // Sign-up failed
      }
    }
    return false; // Invalid input
  }


}



