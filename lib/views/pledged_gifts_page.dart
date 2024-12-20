import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_gift_controller.dart';
import '../controllers/firestore_controllers/firestore_gift_controller.dart';
import '../models/gift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PledgedGiftsPage extends StatefulWidget {
  final String userId; // Use userId instead of userName

  PledgedGiftsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final SqliteGiftController _sqliteGiftController = SqliteGiftController();
  final FirestoreGiftController _firestoreGiftController = FirestoreGiftController();
  List<Gift>? _pledgedGifts; // Null indicates loading

  @override
  void initState() {
    super.initState();
    // Fetch all pledged gifts for the user
    _loadPledgedGifts();
  }

  Future<void> _loadPledgedGifts() async {
    try {
      // Fetch pledged gifts using Firestore
      final gifts = await _firestoreGiftController.getPledgedGifts(widget.userId);

      setState(() {
        _pledgedGifts = gifts;
      });
    } catch (e) {
      print("Error loading pledged gifts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load pledged gifts. Please try again.")),
      );
    }
  }


  Future<void> _purchaseGift(String giftId) async {
    await _sqliteGiftController.purchaseGift(giftId);
    await FirebaseFirestore.instance
        .collection('Gifts')
        .doc(giftId)
        .update({'status': 'Purchased'});
    await     _loadPledgedGifts(); // Reload gifts after purchasing
  }

  Future<void> _unpledgeGift(String giftId) async {
    try {
      await FirebaseFirestore.instance.collection('Gifts').doc(giftId).update({
        'status': 'Available',
        'pledgedByUserId': null, // Clear the pledgedByUserId
      });

      await _sqliteGiftController.unpledgeGift(giftId);

      await _loadPledgedGifts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift unpledged successfully!")),
      );
    } catch (e) {
      print("Error unpledging gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to unpledge gift. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Pledged Gifts"),
      ),
      body: _pledgedGifts == null
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : _pledgedGifts!.isNotEmpty
          ? ListView.builder(
        itemCount: _pledgedGifts!.length,
        itemBuilder: (context, index) {
          final gift = _pledgedGifts![index];
          return Card(
            color: gift.status == "Pledged" ? Colors.green[100] : Colors.red[100],
            elevation: 3,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.card_giftcard, color: Colors.amber),
              title: Text(gift.name,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                "Category: ${gift.category}\nDescription: ${gift.description}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "\$${gift.price.toStringAsFixed(2)}",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                  SizedBox(width: 10),


                  // Unpledge Icon (if the gift isn't Purchased)
                  if (gift.status != "Purchased")
                    IconButton(
                      icon: Icon(Icons.undo, color: Colors.red),
                      tooltip: "Unpledge",
                      onPressed: () => _unpledgeGift(gift.id),
                    ),

                  // Purchase Icon (if the gift isn't Purchased)
                  if (gift.status != "Purchased")
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.blue),
                      tooltip: "Purchase",
                      onPressed: () => _purchaseGift(gift.id), // Add your purchase logic
                    ),

                ],
              ),
            ),
          );
        },
      )
          : Center(
        child: Text(
          "You have not pledged any gifts yet.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
