import '../models/friend.dart';

class FriendController {
  final List<Friend> _friends = [
    Friend(
      id: "1",
      name: "Alice",
      profileUrl: "https://via.placeholder.com/150",
      upcomingEvents: 2,
    ),
    Friend(
      id: "2",
      name: "Bob",
      profileUrl: "https://via.placeholder.com/150",
      upcomingEvents: 0,
    ),
    Friend(
      id: "3",
      name: "Charlie",
      profileUrl: "https://via.placeholder.com/150",
      upcomingEvents: 1,
    ),
  ];

  List<Friend> get friends => List.unmodifiable(_friends);

  List<Friend> searchFriends(String query) {
    return _friends
        .where((friend) =>
        friend.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
