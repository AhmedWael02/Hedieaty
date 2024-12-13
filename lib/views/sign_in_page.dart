import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers//sqlite_user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/firestore_controllers/firetore_user_controller.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final SqliteUserController _sqliteUserController = SqliteUserController();
  final FirestoreUserController _firestoreUserController = FirestoreUserController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;


      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // Fetch user data from Firestore
        final userData = await _firestoreUserController.getUser(userCredential.user!.uid);

        if (userData != null) {
          Navigator.pushReplacementNamed(context, '/homePage',
              arguments: userCredential.user!.uid);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Sign-in successful!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User data not found.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-in failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) =>
                value == null || !value.contains('@') ? "Enter a valid email" : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) =>
                value == null || value.length < 6 ? "Password must be at least 6 characters" : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signIn,
                child: Text("Sign In"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signUp');
                },
                child: Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}