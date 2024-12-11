import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreEventController {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all events created by a user
  Future<List<Map<String, dynamic>>> getEvents(String userId) async {
    final snapshot = await _firestore.collection('Events')
        .where('creatorId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add the document ID as 'id'
      return data;
    }).toList();
  }



}