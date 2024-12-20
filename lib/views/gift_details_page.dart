import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_gift_controller.dart';
import '../models/gift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GiftDetailsPage extends StatefulWidget {
  final String eventId;
  final Gift? gift;

  GiftDetailsPage({Key? key, required this.eventId, this.gift}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final SqliteGiftController _sqliteGiftController = SqliteGiftController();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name ?? "");
    _descriptionController = TextEditingController(text: widget.gift?.description ?? "");
    _categoryController = TextEditingController(text: widget.gift?.category ?? "");
    _priceController = TextEditingController(
        text: widget.gift != null ? widget.gift!.price.toStringAsFixed(2) : "");
    _status = widget.gift?.status ?? "Available";
  }

  Future<void> _saveGift() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newGift = Gift(
        id: widget.gift?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: widget.eventId,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        status: _status,
      );

      final giftData = {
        'eventId': widget.eventId,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'status': _status,
        'pledgedByUserId': widget.gift?.pledgedBy,
      };

      try {
        if (widget.gift == null) {
          await FirebaseFirestore.instance.collection('Gifts').add(giftData);
          await _sqliteGiftController.addGift(newGift);
        } else {
          await FirebaseFirestore.instance
              .collection('Gifts')
              .doc(widget.gift!.id)
              .set(giftData, SetOptions(merge: true));
          await _sqliteGiftController.updateGift(newGift);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gift ${widget.gift == null ? "added" : "updated"} successfully!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save gift. Please try again.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? "Add Gift" : "Edit Gift"),
        backgroundColor: Colors.blue.shade200,
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
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Gift Name",
                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Name is required" : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: "Category",
                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: "Price",
                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Price is required";
                        }
                        if (double.tryParse(value) == null) {
                          return "Enter a valid price";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      items: ["Available", "Pledged"]
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Status",
                        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _saveGift,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.green,
                          ),
                          child: Text("Save"),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
