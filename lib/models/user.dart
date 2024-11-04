class User {
  String name;
  String email;
  String phoneNumber;
  String themePreference;
  bool notificationsEnabled;

  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.themePreference = "Light Mode",
    this.notificationsEnabled = true,
  });
}
