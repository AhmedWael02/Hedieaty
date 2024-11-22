class User {
  String id;
  String name;
  String email;
  String phoneNumber;
  String password;
  String themePreference;
  bool notificationsEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.themePreference = "Light Mode",
    this.notificationsEnabled = true,
  });
}
