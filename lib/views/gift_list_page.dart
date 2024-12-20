import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_gift_controller.dart';
import '../models/gift.dart';
import '../models/event.dart';
import 'gift_details_page.dart';
import '../controllers/firestore_controllers/firestore_gift_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GiftListPage extends StatefulWidget {
  final Event event; // The selected event
  final String userId; // The current user's ID
  final String? pledgerId;

  GiftListPage({Key? key, required this.event, required this.userId, this.pledgerId}) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final SqliteGiftController _sqliteGiftController = SqliteGiftController();
  final FirestoreGiftController _firestoreGiftController = FirestoreGiftController();
  List<Gift>? _gifts; // Null indicates loading
  String _sortCriteria = "Name";

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    final giftsData = await _firestoreGiftController.getGifts(widget.event.id);
    setState(() {
      _gifts = giftsData.map((data) {
        return Gift(
          id: data['id'],
          eventId: data['eventId'],
          name: data['name'],
          description: data['description'],
          category: data['category'],
          price: data['price'],
          status: data['status'],
          pledgedBy: data['pledgedByUserId'],
        );
      }).toList();
    });
  }

  Future<void> _sortGifts(String criteria) async {
    setState(() {
      _sortCriteria = criteria;

      if (criteria == "Name") {
        _gifts!.sort((a, b) => a.name.compareTo(b.name));
      } else if (criteria == "Category") {
        _gifts!.sort((a, b) => a.category.compareTo(b.category));
      } else if (criteria == "Status") {
        _gifts!.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  Future<void> _addGift() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(eventId: widget.event.id),
      ),
    );
    await _loadGifts();
  }

  Future<void> _editGift(Gift gift) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(eventId: widget.event.id, gift: gift),
      ),
    );
    await _loadGifts();
  }

  Future<void> _pledgeGift(String giftId) async {
    try {
      await FirebaseFirestore.instance.collection('Gifts').doc(giftId).update({
        'status': 'Pledged',
        'pledgedByUserId': widget.pledgerId,
      });

      await _sqliteGiftController.pledgeGift(giftId, widget.pledgerId!);

      await _loadGifts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift pledged successfully!")),
      );
    } catch (e) {
      print("Error pledging gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pledge gift. Please try again.")),
      );
    }
  }

  Future<void> _purchaseGift(String giftId) async {
    await _sqliteGiftController.purchaseGift(giftId);
    await FirebaseFirestore.instance
        .collection('Gifts')
        .doc(giftId)
        .update({'status': 'Purchased'});
    await _loadGifts();
  }

  Future<void> _unpledgeGift(String giftId) async {
    try {
      await FirebaseFirestore.instance.collection('Gifts').doc(giftId).update({
        'status': 'Available',
        'pledgedByUserId': null,
      });

      await _sqliteGiftController.unpledgeGift(giftId);

      await _loadGifts();

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
        title: Text("${widget.event.name} Gifts"),
        backgroundColor: Colors.blue.shade200,
        actions: [
          DropdownButton<String>(
            value: _sortCriteria,
            icon: Icon(Icons.sort, color: Colors.white),
            dropdownColor: Colors.blue.shade200,
            onChanged: (value) {
              if (value != null) {
                _sortGifts(value);
              }
            },
            items: ["Name", "Category", "Status"]
                .map((criteria) => DropdownMenuItem(
              value: criteria,
              child: Text(criteria),
            ))
                .toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _gifts == null
              ? Center(child: CircularProgressIndicator())
              : _gifts!.isNotEmpty
              ? ListView.builder(
            itemCount: _gifts!.length,
            itemBuilder: (context, index) {
              final gift = _gifts![index];
              return Card(
                color: gift.status == "Pledged"
                    ? Colors.green[100]
                    : gift.status == "Purchased"
                    ? Colors.red[100]
                    : null,
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    gift.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${gift.category} - \$${gift.price.toStringAsFixed(2)}",
                  ),
                  trailing: gift.status != "Purchased"
                      ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "Edit") {
                        _editGift(gift);
                      } else if (value == "Delete") {
                        setState(() {
                          _firestoreGiftController.deleteGift(gift.id);
                          _sqliteGiftController.deleteGift(gift.id);
                          _loadGifts();
                        });
                      } else if (value == "Pledge") {
                        _pledgeGift(gift.id);
                      } else if (value == "Unpledge") {
                        _unpledgeGift(gift.id);
                      } else if (value == "Purchase") {
                        _purchaseGift(gift.id);
                      }
                    },
                    itemBuilder: (context) => [
                      if (widget.pledgerId == null &&
                          (gift.status != "Pledged" && gift.status != "Purchased"))
                        ...[
                          PopupMenuItem(
                            value: "Edit",
                            child: Text("Edit"),
                          ),
                          PopupMenuItem(
                            value: "Delete",
                            child: Text("Delete"),
                          ),
                        ],
                      if (widget.pledgerId != null &&
                          (gift.status != "Pledged" && gift.status != "Purchased"))
                        PopupMenuItem(
                          value: "Pledge",
                          child: Text("Pledge"),
                        ),
                      if (gift.status == "Pledged" &&
                          ((widget.pledgerId != null && gift.pledgedBy == widget.pledgerId) ||
                              (widget.pledgerId == null &&
                                  widget.userId == widget.event.creatorId)))
                        PopupMenuItem(
                          value: "Unpledge",
                          child: Text("Unpledge"),
                        ),
                      if (gift.status == "Pledged" &&
                          widget.pledgerId != null &&
                          gift.pledgedBy == widget.pledgerId)
                        PopupMenuItem(
                          value: "Purchase",
                          child: Text("Purchase"),
                        ),
                    ],
                  )
                      : null,
                ),
              );
            },
          )
              : Center(
            child: Text(
              "No gifts found for this event.",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.pledgerId == null
          ? FloatingActionButton(
        onPressed: _addGift,
        backgroundColor: Colors.amber,
        child: Icon(Icons.add, color: Colors.black),
      )
          : null,
    );
  }
}
