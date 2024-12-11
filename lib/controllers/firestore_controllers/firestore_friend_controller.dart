import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/friend.dart';

class FirestoreFriendController {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch friends for a specific user
  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final snapshot = await _firestore.collection('Friends')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Include document ID
      return data;
    }).toList();
  }

  Future<void> addFriend(String userId, String friendId) async {
    await _firestore.collection('Friends').doc('$userId\_$friendId').set({
      'userId': userId,
      'friendId': friendId,
    });
  }

  Future<int> countUpcomingEvents(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where('creatorId', isEqualTo: userId) // Match user ID
          .where('status', isEqualTo: 'Upcoming') // Match status
          .where('isPublished', isEqualTo: true) // Match published status
          .get();

      return querySnapshot.size; // Return the count of matching documents
    } catch (e) {
      print("Error counting upcoming events: $e");
      return 0; // Return 0 in case of an error
    }
  }


  Future<List<Friend>> searchFriends(String userId, String query) async {
    try {
      // Fetch friends for the user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Friends')
          .where('userId', isEqualTo: userId) // Filter by userId
          .get();

      // Extract friendIds from the Friends collection
      final friendIds = querySnapshot.docs.map((doc) => doc['friendId'] as String).toList();

      // Fetch details for all friendIds from the Users collection
      final List<Friend> friends = [];
      for (var friendId in friendIds) {
        final userDoc = await FirebaseFirestore.instance.collection('Users').doc(friendId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          friends.add(Friend(
            id: friendId,
            name: userData['name'],
            profileUrl: userData['profileUrl'] ?? '', // Add profile URL if implemented
            upcomingEvents: 0, // You can calculate upcoming events if needed
          ));
        }
      }

      // Filter friends by query
      return friends
          .where((friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print("Error searching friends: $e");
      return [];
    }
  }





}