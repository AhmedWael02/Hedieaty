import 'package:flutter/material.dart';
import '../controllers/friend_controller.dart';
import '../widgets/friend_list_tile.dart';
import '../models/friend.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FriendController _controller = FriendController();
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = _controller.friends;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredFriends = _controller.searchFriends(query);
    });
  }

  void _addFriend() {
    // Placeholder: Add functionality to add a friend using a phone number.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Friend"),
        content: TextField(
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
            onPressed: () {
              // Add friend logic here
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _createEvent() {
    // Navigate to the Create Event/Gift List screen
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
                child: ListView.builder(
                  itemCount: _filteredFriends.length,
                  itemBuilder: (context, index) {
                    return FriendListTile(friend: _filteredFriends[index]);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.5 - 40,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.amber,
              onPressed: (){},
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
