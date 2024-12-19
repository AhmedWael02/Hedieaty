import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_gift_controller.dart';
import '../models/gift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/firestore_controllers/firestore_gift_controller.dart';

class GiftDetailsPage extends StatefulWidget {
  final String eventId; // ID of the event this gift belongs to
  final Gift? gift; // Optional: If null, it's adding a new gift; otherwise, editing

  GiftDetailsPage({Key? key, required this.eventId, this.gift}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final SqliteGiftController _sqliteGiftController = SqliteGiftController();
  final FirestoreGiftController _firestoreGiftController = FirestoreGiftController();

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing gift data or defaults
    _nameController = TextEditingController(text: widget.gift?.name ?? "");
    _descriptionController = TextEditingController(text: widget.gift?.description ?? "");
    _categoryController = TextEditingController(text: widget.gift?.category ?? "");
    _priceController = TextEditingController(
        text: widget.gift != null ? widget.gift!.price.toStringAsFixed(2) : "");
    _status = widget.gift?.status ?? "Available";
  }

/*  Future<void> _saveGift() async {
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

      try {
        if (widget.gift == null) {
          await _controller.addGift(newGift); // Add new gift
        } else {
          await _controller.updateGift(newGift); // Update existing gift
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gift ${widget.gift == null ? "added" : "updated"} successfully!")),
        );

        Navigator.pop(context); // Return to the previous page
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
  }*/

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
        'pledgedByUserId': widget.gift?.pledgedBy, // Keep pledger info if editing
      };

      try {
        if (widget.gift == null) {
          // Add a new gift
          await FirebaseFirestore.instance.collection('Gifts').add(giftData);
          await _sqliteGiftController.addGift(newGift);
        } else {
          // Update existing gift
          await FirebaseFirestore.instance
              .collection('Gifts')
              .doc(widget.gift!.id)
              .set(giftData, SetOptions(merge: true));
          await _sqliteGiftController.updateGift(newGift);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gift ${widget.gift == null ? "added" : "updated"} successfully!")),
        );
        Navigator.pop(context); // Return to the previous page
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
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
                  decoration: InputDecoration(labelText: "Gift Name"),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Name is required" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: "Category"),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: "Price"),
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
                  decoration: InputDecoration(labelText: "Status"),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _saveGift,
                      child: Text("Save"),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
