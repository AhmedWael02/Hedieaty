import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_user_controller.dart';
import '../controllers/firestore_controllers/firetore_user_controller.dart';
import '../controllers/firestore_controllers/firestore_event_controller.dart';
import '../models/user.dart';
import '../models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SqliteUserController _sqliteUserController = SqliteUserController();
  final FirestoreUserController _firestoreUserController = FirestoreUserController();
  final FirestoreEventController _firestoreEventController = FirestoreEventController();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _selectedTheme;
  late bool _notificationsEnabled;

  User? _currentUser;
  List<Event>? _userEvents;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserEvents();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _firestoreUserController.getUser(widget.userId);

      if (userData != null) {
        setState(() {
          _currentUser = User(
            id: widget.userId,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            password: '',
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
    final eventsData = await _firestoreEventController.getEvents(widget.userId);
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
    });
    setState(() {
      _userEvents = events;
    });
  }

  Future<void> _saveChanges() async {
    if (_currentUser != null) {
      try {
        _currentUser = User(
          id: _currentUser!.id,
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          password: _currentUser!.password,
          themePreference: _selectedTheme,
          notificationsEnabled: _notificationsEnabled,
        );

        final userData = {
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'phoneNumber': _currentUser!.phoneNumber,
          'themePreference': _currentUser!.themePreference,
          'notificationsEnabled': _currentUser!.notificationsEnabled,
        };

        await _firestoreUserController.addOrUpdateUser(_currentUser!.id, userData);
        await _sqliteUserController.editUser(_currentUser!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );

        setState(() {});
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
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.blue.shade200,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Personal Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedTheme,
                  decoration: InputDecoration(
                    labelText: "Theme Preference",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: ["Light Mode", "Dark Mode"]
                      .map((theme) => DropdownMenuItem(
                    value: theme,
                    child: Text(theme),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTheme = value!;
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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    backgroundColor: Colors.green,
                  ),
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
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                    : Center(
                  child: Text(
                    "You have not created any events yet.",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/pledgedGifts',
                      arguments: widget.userId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  ),
                  icon: Icon(Icons.card_giftcard, color: Colors.black),
                  label: Text(
                    "View My Pledged Gifts",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
