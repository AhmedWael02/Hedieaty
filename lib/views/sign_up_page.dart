import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers//sqlite_user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/firestore_controllers/firetore_user_controller.dart';


class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SqliteUserController _sqliteUserController = SqliteUserController();
  final FirestoreUserController _firestoreUserController = FirestoreUserController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _themePreference = "Light Mode"; // Default preference
  bool _notificationsEnabled = true; // Default notification setting

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;
      String name = _nameController.text;
      String phoneNumber = _phoneController.text;


      try {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Save user data to Firestore
        await _firestoreUserController.addOrUpdateUser(userCredential.user!.uid, {
          'email': email,
          'name': name,
          'phoneNumber': phoneNumber,
          'notificationsEnabled': true,
          'themePreference': 'Light Mode',
        });

        Navigator.pushReplacementNamed(context, '/signIn');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-up successful!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-up failed: $e")),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Name"),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter your name" : null,
                ),
                SizedBox(height: 12),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) =>
                  value == null || !value.contains('@') ? "Enter a valid email" : null,
                ),
                SizedBox(height: 12),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6
                      ? "Password must be at least 6 characters"
                      : null,
                ),
                SizedBox(height: 12),

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                  value == null || value.isEmpty ? "Enter your phone number" : null,
                ),
                SizedBox(height: 12),

                // Theme Preference Dropdown
                DropdownButtonFormField<String>(
                  value: _themePreference,
                  decoration: InputDecoration(labelText: "Theme Preference"),
                  items: ["Light Mode", "Dark Mode"]
                      .map((theme) => DropdownMenuItem(
                    value: theme,
                    child: Text(theme),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _themePreference = value!;
                    });
                  },
                ),
                SizedBox(height: 12),

                // Notifications Toggle
                SwitchListTile(
                  title: Text("Enable Notifications"),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  secondary: Icon(_notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off),
                ),
                SizedBox(height: 24),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
