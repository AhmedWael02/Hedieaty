import '../models/friend.dart';
import 'database_helper.dart';

class FriendController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Friend>> getFriendsByUserId(String userId) async {
    final friends = await _dbHelper.getFriendsByUserId(userId);
    return friends.map((friendMap) {
      return Friend(
        id: friendMap['friendId'],
        name: '', // Retrieve name if needed from Users table
        profileUrl: '', // Profile URL logic here if applicable
        upcomingEvents: 0, // Calculate based on events table if needed
      );
    }).toList();
  }



  Future<List<Friend>> searchFriends(String userId, String query) async {
    // Fetch friends for the given user ID from the database
    List<Friend> friends = await getFriendsByUserId(userId);

    // Filter the friends list based on the query
    return friends
        .where((friend) =>
        friend.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> addFriend(String userId, String friendId) async {
    await _dbHelper.insertFriend(userId, friendId);
  }


}
