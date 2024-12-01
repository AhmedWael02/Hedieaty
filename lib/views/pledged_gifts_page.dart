import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';

class PledgedGiftsPage extends StatefulWidget {
  final String userId; // Use userId instead of userName

  PledgedGiftsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final GiftController _controller = GiftController();
  List<Gift>? _pledgedGifts; // Null indicates loading

  @override
  void initState() {
    super.initState();
    // Fetch all pledged gifts for the user
    _loadPledgedGifts();
  }

  Future<void> _loadPledgedGifts() async {
    List<Gift> gifts = await _controller.getPledgedGifts(widget.userId);
    setState(() {
      _pledgedGifts = gifts;
    });
  }

  Future<void> _unpledgeGift(String giftId) async {
    await _controller.unpledgeGift(giftId); // Unpledge the gift
    await _loadPledgedGifts(); // Refresh the list
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
                  IconButton(
                    icon: Icon(Icons.undo, color: Colors.red),
                    tooltip: "Unpledge",
                    onPressed: () => _unpledgeGift(gift.id),
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
