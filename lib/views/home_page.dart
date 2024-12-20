import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_friend_controller.dart';
import '../controllers/sqlite_controllers/sqlite_user_controller.dart';
import '../widgets/friend_list_tile.dart';
import '../models/friend.dart';
import '../models/user.dart';
import '../controllers/firestore_controllers/firestore_friend_controller.dart';
import '../controllers/firestore_controllers/firetore_user_controller.dart';

class HomePage extends StatefulWidget {
  final String userId; // Pass the signed-in user's ID

  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SqliteFriendController _sqliteFriendController = SqliteFriendController();
  final FirestoreFriendController _firestoreFriendController = FirestoreFriendController();
  final FirestoreUserController _firestoreUserController = FirestoreUserController();
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _filteredFriends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final friendsData = await _firestoreFriendController.getFriends(widget.userId);

      _filteredFriends = friendsData.map((data) {
        return Friend(
          id: data['friendId'],
          name: "Fetching...", // Placeholder
          profileUrl: 'assets/images/placeholder.png',
          upcomingEvents: 0,
        );
      }).toList();

      for (var friend in _filteredFriends) {
        final userData = await _firestoreUserController.getUser(friend.id);
        if (userData != null) {
          friend.name = userData['name'];
        }

        // Count upcoming events for each friend
        friend.upcomingEvents = await _firestoreFriendController.countUpcomingEvents(friend.id);
      }

      setState(() {});
    } catch (e) {
      print("Error loading friends: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  Future<void> _onSearchChanged(String query) async {
    List<Friend> friends = await _firestoreFriendController.searchFriends(widget.userId, query);
    setState(() {
      _filteredFriends = friends;
    });
  }


  void _addFriend() {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Friend"),
        content: TextField(
          controller: phoneController,
          decoration: InputDecoration(hintText: "Enter phone number"),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final phoneNumber = phoneController.text.trim();

              if (phoneNumber.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Phone number cannot be empty.")),
                );
                return;
              }

              // Fetch user by phone number
              final userData = await _firestoreUserController.getUserByPhoneNumber(phoneNumber);
              if (userData == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No user found with this phone number.")),
                );
                return;
              }

              // Add friend relationship
              await _firestoreFriendController.addFriend(widget.userId, userData['id']);
              await _sqliteFriendController.addFriend(widget.userId, userData['id']);

              // Reload the friends list
              await _loadFriends();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${userData['name']} has been added as a friend!")),
              );

              Navigator.pop(context); // Close the dialog
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }



  void _createEvent() {
    Navigator.pushNamed(
      context,
      '/eventList',
      arguments: {'userId': widget.userId},
    );
  }

  void _viewProfile() {
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: widget.userId,
    );
  }

  void _signOut() {
    // Redirect to Sign In page
    Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You have been signed out.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hedieaty'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addFriend,
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: _viewProfile,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut, // Sign out logic
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredFriends.isNotEmpty
                    ? ListView.builder(
                  itemCount: _filteredFriends.length,
                  itemBuilder: (context, index) {
                    return FriendListTile(friend: _filteredFriends[index],userId: widget.userId,);
                  },
                )
                    : Center(child: Text("No friends found.")),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.5 - 40,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.amber,
              onPressed: _createEvent,
              label: Text(
                "Create Your Own List",
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(Icons.create, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
