import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserController {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Fetch user data by UID
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _firestore.collection('Users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Add or update user data
  Future<void> addOrUpdateUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('Users').doc(uid).set(userData, SetOptions(merge: true));
  }


  Future<Map<String, dynamic>?> getUserByPhoneNumber(String phoneNumber) async {
    final snapshot = await _firestore
        .collection('Users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1) // Ensure only one user is returned
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      data['id'] = snapshot.docs.first.id; // Include document ID as 'id'
      return data;
    }

    return null; // Return null if no user found
  }

}