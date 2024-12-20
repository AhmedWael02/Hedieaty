import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_user_controller.dart';
import '../controllers/firestore_controllers/firetore_user_controller.dart';
import '../controllers/firestore_controllers/firestore_event_controller.dart';
import '../models/user.dart';
import '../controllers/sqlite_controllers/sqlite_event_controller.dart';
import '../models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {

  final String userId; // Pass the signed-in user ID

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SqliteUserController _sqliteUserController = SqliteUserController();
  final SqliteEventController _sqliteEventController = SqliteEventController();
  final FirestoreUserController _firestoreUserController = FirestoreUserController();
  final FirestoreEventController _firestoreEventController = FirestoreEventController();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _selectedTheme;
  late bool _notificationsEnabled;

  User? _currentUser;
  List<Event>? _userEvents; // Null indicates data is still loading

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserEvents();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch user data from Firestore
      final userData = await _firestoreUserController.getUser(widget.userId);

      if (userData != null) {
        setState(() {
          _currentUser = User(
            id: widget.userId,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            password: '', // Firestore doesn't store the password
            themePreference: userData['themePreference'] ?? 'Light Mode',
            notificationsEnabled: userData['notificationsEnabled'] ?? true,
          );
          _nameController = TextEditingController(text: _currentUser!.name);
          _emailController = TextEditingController(text: _currentUser!.email);
          _phoneController = TextEditingController(text: _currentUser!.phoneNumber);
          _selectedTheme = _currentUser!.themePreference;
          _notificationsEnabled = _currentUser!.notificationsEnabled;
        });
      } else {
        throw Exception("User not found in Firestore.");
      }
    } catch (e) {
      print("Error loading user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load user data. Please try again.")),
      );
    }
  }



  Future<void> _loadUserEvents() async {
    List<Event> events = [];
    final eventsData = await _firestoreEventController.getEvents(
        widget.userId);
    setState(() {
      events = eventsData.map((data) {
        return Event(
          id: data['id'],
          name: data['name'],
          date: (data['date'] as Timestamp).toDate(),
          location: data['location'],
          description: data['description'],
          category: data['category'],
          status: data['status'],
          creatorId: data['creatorId'],
        );
      }).toList();
      // _events.sort((a, b) => a.name.compareTo(b.name));
    });
    setState(() {
      _userEvents = events;
    });
  }

  Future<void> _saveChanges() async {
    if (_currentUser != null) {
      try {
        // Update the current user object
        _currentUser = User(
          id: _currentUser!.id,
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          password: _currentUser!.password, // Password remains unchanged
          themePreference: _selectedTheme,
          notificationsEnabled: _notificationsEnabled,
        );

        // Prepare data for Firestore
        final userData = {
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'phoneNumber': _currentUser!.phoneNumber,
          'themePreference': _currentUser!.themePreference,
          'notificationsEnabled': _currentUser!.notificationsEnabled,
        };

        // Save changes to Firestore
        await _firestoreUserController.addOrUpdateUser(_currentUser!.id, userData);
        await _sqliteUserController.editUser(_currentUser!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );

        setState(() {}); // Refresh UI if needed
      } catch (e) {
        print("Error saving user changes: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save changes. Please try again.")),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Personal Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              decoration: InputDecoration(labelText: "Theme Preference"),
              items: ["Light Mode", "Dark Mode"]
                  .map((theme) => DropdownMenuItem(
                value: theme,
                child: Text(theme),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                  _updateTheme();
                });
              },
            ),
            SizedBox(height: 12),
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
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text("Save Changes"),
            ),

            Divider(height: 40),
            Text("My Created Events",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _userEvents == null
                ? Center(child: CircularProgressIndicator())
                : _userEvents!.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _userEvents!.length,
              itemBuilder: (context, index) {
                final event = _userEvents![index];
                return Card(
                  child: ListTile(
                    title: Text(event.name),
                    subtitle: Text(
                        "Category: ${event.category} - Status: ${event.status}"),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/giftList',
                        arguments: {
                          'event': event,
                          'userId': widget.userId,
                        },
                      );
                    },
                  ),
                );
              },
            )
                : Center(child: Text("You have not created any events yet.")),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/pledgedGifts',
                  arguments: widget.userId,
                );
              },
              icon: Icon(Icons.card_giftcard),
              label: Text("View My Pledged Gifts"),
            )


          ],
        ),
      ),
    );
  }

  void _updateTheme() {
    if (_selectedTheme == "Dark Mode") {
      // Switch to dark theme
      ThemeMode.dark;
    } else {
      // Switch to light theme
      ThemeMode.light;
    }
  }

}
