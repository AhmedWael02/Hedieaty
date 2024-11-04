class User {
  String id;
  String name;
  String email;
  String phoneNumber;
  String themePreference;
  bool notificationsEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.themePreference = "Light Mode",
    this.notificationsEnabled = true,
  });
}
