import 'package:flutter/material.dart';
import '../controllers/friend_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/friend_list_tile.dart';
import '../models/friend.dart';
import '../models/user.dart';

class HomePage extends StatefulWidget {
  final String userId; // Pass the signed-in user's ID

  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FriendController _controller = FriendController();
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _filteredFriends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    List<Friend> friends = await _controller.getFriendsByUserId(widget.userId);
    setState(() {
      _filteredFriends = friends;
      _isLoading = false;
    });
  }

  Future<void> _onSearchChanged(String query) async {
    List<Friend> friends = await _controller.searchFriends(widget.userId, query);
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String phoneNumber = phoneController.text;

              if (phoneNumber.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Phone number cannot be empty.")),
                );
                return;
              }

              // Check if the user exists with the given phone number
              UserController userController = UserController();
              User? friend = await userController.getUserByPhoneNumber(phoneNumber);

              if (friend == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No user found with this phone number.")),
                );
                Navigator.pop(context);
                return;
              }

              // Add the friend relationship
              await _controller.addFriend(widget.userId, friend.id);

              // Reload the friends list
              await _loadFriends();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${friend.name} has been added as a friend!")),
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
