import '../models/user.dart';

class UserController {
  // Dummy initial user data
  User _user = User(
    name: "John Doe",
    email: "johndoe@example.com",
    phoneNumber: "+1234567890",
  );

  // Getter to retrieve user data
  User get user => _user;

  // Update user details
  void updateUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String themePreference,
    required bool notificationsEnabled,
  }) {
    _user.name = name;
    _user.email = email;
    _user.phoneNumber = phoneNumber;
    _user.themePreference = themePreference;
    _user.notificationsEnabled = notificationsEnabled;
  }
}
