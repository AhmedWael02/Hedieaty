import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';
import '../models/event.dart';
import 'gift_details_page.dart'; // Uncomment this when Gift Details Page is ready

class GiftListPage extends StatefulWidget {
  final Event event; // The selected event
  final String userId; // The current user's ID

  GiftListPage({Key? key, required this.event, required this.userId}) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _controller = GiftController();
  List<Gift>? _gifts; // Null indicates loading
  String _sortCriteria = "Name";

  @override
  void initState() {
    super.initState();
    // Fetch gifts specific to the selected event
    _loadGifts(); // Load gifts when the page initializes
  }

  Future<void> _loadGifts() async {
    List<Gift> gifts = await _controller.sortGiftsForEvent(widget.event.id, _sortCriteria);
    setState(() {
      _gifts = gifts;
    });
  }

  Future<void> _sortGifts(String criteria) async {
    setState(() {
      _sortCriteria = criteria;
    });
    await _loadGifts(); // Reload gifts after sorting
  }

  Future<void> _addGift() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(eventId: widget.event.id),
      ),
    );
    await _loadGifts(); // Reload gifts after adding
  }

  Future<void> _editGift(Gift gift) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(gift: gift, eventId: widget.event.id),
      ),
    );
    await _loadGifts(); // Reload gifts after editing
  }


  Future<void> _pledgeGift(String id) async {
    await _controller.pledgeGift(id, widget.userId); // Use dynamic userId
    await _loadGifts(); // Reload gifts after pledging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.event.name} Gifts"),
        actions: [
          DropdownButton<String>(
            value: _sortCriteria,
            items: ["Name", "Category", "Status"]
                .map((criteria) => DropdownMenuItem(
              value: criteria,
              child: Text(criteria),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _sortGifts(value);
              }
            },
          ),
        ],
      ),
      body: _gifts == null
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching gifts
          : _gifts!.isNotEmpty
          ? ListView.builder(
        itemCount: _gifts!.length,
        itemBuilder: (context, index) {
          final gift = _gifts![index];
          return Card(
            color: gift.status == "Pledged" ? Colors.green[100] : null,
            child: ListTile(
              title: Text(gift.name),
              subtitle: Text("${gift.category} - \$${gift.price.toStringAsFixed(2)}"),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "Edit") {
                    _editGift(gift); // Uncomment when GiftDetailsPage is implemented
                  } else if (value == "Delete") {
                    setState(() {
                      _controller.deleteGift(gift.id);
                      _loadGifts();
                    });
                  } else if (value == "Pledge") {
                    _pledgeGift(gift.id);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "Edit",
                    child: Text("Edit"),
                  ),
                  PopupMenuItem(
                    value: "Delete",
                    child: Text("Delete"),
                  ),
                  if (gift.status != "Pledged")
                    PopupMenuItem(
                      value: "Pledge",
                      child: Text("Pledge"),
                    ),
                ],
              ),
            ),
          );
        },
      )
          : Center(child: Text("No gifts found for this event.")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGift,
        child: Icon(Icons.add),
      ),
    );
  }
}
