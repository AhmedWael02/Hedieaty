import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendListTile extends StatelessWidget {
  final Friend friend;
  final String userId;

  const FriendListTile({super.key, required this.friend,required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friend.profileUrl.isNotEmpty
            ? NetworkImage(friend.profileUrl)
            : AssetImage('assets/images/placeholder.png') as ImageProvider, // Placeholder image
        radius: 25,
      ),
      title: Text(
        friend.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Upcoming Events: ${friend.upcomingEvents}"),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/eventList',
          arguments: {'userId': friend.id,'pledgerId':userId},
        );
        // Navigate to the friend's gift list page
      },
    );
  }
}
