import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';
import '../models/event.dart';
import 'gift_details_page.dart'; // Uncomment this when Gift Details Page is ready

class GiftListPage extends StatefulWidget {
  final Event event; // Accept the selected event

  GiftListPage({Key? key, required this.event}) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftController _controller = GiftController();
  late List<Gift> _gifts;
  String _sortCriteria = "Name";

  @override
  void initState() {
    super.initState();
    // Fetch gifts specific to the selected event
    _gifts = _controller.sortGiftsForEvent(widget.event.id, _sortCriteria);
  }

  void _sortGifts(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      _gifts = _controller.sortGiftsForEvent(widget.event.id, criteria);
    });
  }

  void _addGift() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(eventId: widget.event.id),
      ),
    ).then((_) => setState(() {
          _gifts = _controller.sortGiftsForEvent(widget.event.id, _sortCriteria);
        }));
  }

  void _editGift(Gift gift) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(gift: gift, eventId: widget.event.id),
      ),
    ).then((_) => setState(() {
          _gifts = _controller.sortGiftsForEvent(widget.event.id, _sortCriteria);
        }));
  }


  void _pledgeGift(String id) {
    setState(() {
      _controller.pledgeGift(id);
      _gifts = _controller.sortGiftsForEvent(widget.event.id, _sortCriteria);
    });
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
      body: ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
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
                      _gifts = _controller.sortGiftsForEvent(widget.event.id, _sortCriteria);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGift,
        child: Icon(Icons.add),
      ),
    );
  }
}
