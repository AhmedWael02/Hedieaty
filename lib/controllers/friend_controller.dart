import '../models/friend.dart';
import '../models/user.dart';
import 'database_helper.dart';

class FriendController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Friend>> getFriendsByUserId(String userId) async {
    final friends = await _dbHelper.getFriendsByUserId(userId);

    List<Friend> friendList = [];
    for (var friendMap in friends) {
      String friendId = friendMap['friendId'];
      User? user = await _getUserById(friendId);
      int upcomingEventsCount = await _countUpcomingEvents(friendId);

      friendList.add(Friend(
        id: friendId,
        name: user?.name ?? "Unknown",
        profileUrl: '', // Add logic if needed for profile URL
        upcomingEvents: upcomingEventsCount,
      ));
    }

    return friendList;
  }

  Future<User?> _getUserById(String userId) async {
    final db = await _dbHelper.database;
    final users = await db.query('Users', where: 'id = ?', whereArgs: [userId]);

    if (users.isNotEmpty) {
      final userMap = users.first;
      return User(
        id: userMap['id'] as String,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        phoneNumber: userMap['phoneNumber'] as String,
        password: userMap['password'] as String,
        themePreference: userMap['themePreference'] as String,
        notificationsEnabled: userMap['notificationsEnabled'] == 1,
      );
    }
    return null;
  }

  Future<int> _countUpcomingEvents(String userId) async {
    final db = await _dbHelper.database;
    final events = await db.query(
      'Events',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, 'Upcoming'],
    );

    return events.length;
  }

  Future<void> addFriend(String userId, String friendId) async {
    await _dbHelper.insertFriend(userId, friendId);
  }

  Future<List<Friend>> searchFriends(String userId, String query) async {
    List<Friend> friends = await getFriendsByUserId(userId);

    return friends
        .where((friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
