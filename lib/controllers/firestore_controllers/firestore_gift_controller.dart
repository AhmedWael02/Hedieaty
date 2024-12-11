import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/gift.dart';

class FirestoreGiftController {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all gifts for a specific event
  Future<List<Map<String, dynamic>>> getGifts(String eventId) async {
    final snapshot = await _firestore.collection('Gifts')
        .where('eventId', isEqualTo: eventId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Include document ID
      return data;
    }).toList();
  }

  Future<List<Gift>> getPledgedGifts(String userId) async {
    try {
      // Query Firestore for gifts pledged by the user
      final snapshot = await FirebaseFirestore.instance
          .collection('Gifts')
          .where('pledgedByUserId', isEqualTo: userId) // Filter by pledged user ID
          .get();

      // Map Firestore documents to Gift objects
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Gift(
          id: doc.id,
          eventId: data['eventId'],
          name: data['name'],
          description: data['description'],
          category: data['category'],
          price: data['price'],
          status: data['status'],
          pledgedBy: data['pledgedByUserId'],
        );
      }).toList();
    } catch (e) {
      print("Error fetching pledged gifts: $e");
      return [];
    }
  }


  Future<void> deleteGift(String id) async {
    await FirebaseFirestore.instance.collection('Gifts').doc(id).delete();
  }



}