import 'package:flutter/material.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';
import '../controllers/event_controller.dart';
import '../controllers/gift_controller.dart';
import '../models/event.dart';

class ProfilePage extends StatefulWidget {

  final String userId; // Pass the signed-in user ID

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserController _userController = UserController();
  final EventController _eventController = EventController();
  final GiftController _giftController = GiftController();

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
    User? user = await _userController.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _currentUser = user;
        _nameController = TextEditingController(text: user.name);
        _emailController = TextEditingController(text: user.email);
        _phoneController = TextEditingController(text: user.phoneNumber);
        _selectedTheme = user.themePreference;
        _notificationsEnabled = user.notificationsEnabled;
      });
    }
  }

  Future<void> _loadUserEvents() async {
    List<Event> events = await _eventController.getEventsByUserId(widget.userId);
    setState(() {
      _userEvents = events;
    });
  }

  Future<void> _saveChanges() async {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _currentUser!.password, // Password remains unchanged
        themePreference: _selectedTheme,
        notificationsEnabled: _notificationsEnabled,
      );

      await _userController.editUser(_currentUser!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );

      setState(() {}); // Refresh UI if needed
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
