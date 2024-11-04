import 'package:flutter/material.dart';
import '../controllers/gift_controller.dart';
import '../models/gift.dart';

class GiftDetailsPage extends StatefulWidget {
  final String eventId; // ID of the event this gift belongs to
  final Gift? gift; // Optional: If null, it's adding a new gift; otherwise, editing

  GiftDetailsPage({Key? key, required this.eventId, this.gift}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final GiftController _controller = GiftController();

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  String _status = "Available";

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.gift?.name ?? "");
    _descriptionController =
        TextEditingController(text: widget.gift?.description ?? "");
    _categoryController =
        TextEditingController(text: widget.gift?.category ?? "");
    _priceController =
        TextEditingController(text: widget.gift?.price.toString() ?? "");
    _status = widget.gift?.status ?? "Available";
  }

  void _saveGift() {
    if (_formKey.currentState!.validate()) {
      final newGift = Gift(
        id: widget.gift?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: widget.eventId, // Link gift to event
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        status: _status,
      );

      if (widget.gift == null) {
        // Add new gift
        _controller.addGift(newGift);
      } else {
        // Update existing gift
        _controller.updateGift(newGift);
      }

      Navigator.pop(context); // Return to previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? "Add Gift" : "Edit Gift"),
      ),
      body: Padding(
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
