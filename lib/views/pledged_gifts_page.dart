import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';

class PledgedGiftsPage extends StatefulWidget {
  final String userName;

  PledgedGiftsPage({Key? key, required this.userName}) : super(key: key);

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final GiftController _controller = GiftController();
  late List<Gift> _pledgedGifts;

  @override
  void initState() {
    super.initState();
    // Fetch all pledged gifts for the user
    _pledgedGifts = _controller.getPledgedGifts(widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Pledged Gifts"),
      ),
      body: _pledgedGifts.isNotEmpty
          ? ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = _pledgedGifts[index];
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
              trailing: Text(
                "\$${gift.price.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.green, fontSize: 16),
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
