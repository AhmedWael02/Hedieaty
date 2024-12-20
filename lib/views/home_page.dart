import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_friend_controller.dart';
import '../widgets/friend_list_tile.dart';
import '../models/friend.dart';
import '../controllers/firestore_controllers/firestore_friend_controller.dart';
import '../controllers/firestore_controllers/firetore_user_controller.dart';

class HomePage extends StatefulWidget {
  final String userId;

  HomePage({required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final SqliteFriendController _sqliteFriendController = SqliteFriendController();
  final FirestoreFriendController _firestoreFriendController = FirestoreFriendController();
  final FirestoreUserController _firestoreUserController = FirestoreUserController();
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _filteredFriends = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
    _loadFriends();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          name: "Fetching...",
          profileUrl: 'assets/images/placeholder.png',
          upcomingEvents: 0,
        );
      }).toList();

      for (var friend in _filteredFriends) {
        final userData = await _firestoreUserController.getUser(friend.id);
        if (userData != null) {
          friend.name = userData['name'];
        }

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

              final userData = await _firestoreUserController.getUserByPhoneNumber(phoneNumber);
              if (userData == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No user found with this phone number.")),
                );
                return;
              }

              await _firestoreFriendController.addFriend(widget.userId, userData['id']);
              await _sqliteFriendController.addFriend(widget.userId, userData['id']);

              await _loadFriends();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${userData['name']} has been added as a friend!")),
              );

              Navigator.pop(context);
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
    Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You have been signed out.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hedieaty"),
        backgroundColor: Colors.blue.shade300,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: _viewProfile,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Text(
                      "Welcome to Hedieaty",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search friends...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _filteredFriends.isNotEmpty
                        ? ListView.builder(
                      itemCount: _filteredFriends.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: FriendListTile(
                            friend: _filteredFriends[index],
                            userId: widget.userId,
                          ),
                        );
                      },
                    )
                        : Center(
                      child: Text(
                        "No friends found.",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
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
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _addFriend,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person_add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
