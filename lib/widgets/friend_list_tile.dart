import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendListTile extends StatelessWidget {
  final Friend friend;

  const FriendListTile({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(friend.profileUrl),
      ),
      title: Text(friend.name),
      subtitle: Text("Upcoming Events: ${friend.upcomingEvents}"),
      onTap: () {
        // Navigate to the friend's gift list page
      },
    );
  }
}
