import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../controllers/sqlite_controllers/sqlite_event_controller.dart';
import '../models/event.dart';

class EventDetailsPage extends StatefulWidget {
  final Event? event; // Null if adding a new event
  final String userId;

  EventDetailsPage({Key? key, this.event, required this.userId})
      : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final SqliteEventController _sqliteEventController = SqliteEventController();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _status;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with existing event data or defaults
    _nameController = TextEditingController(text: widget.event?.name ?? '');
    _categoryController = TextEditingController(text: widget.event?.category ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _selectedDate = widget.event?.date ?? DateTime.now();
    _status = widget.event?.status ?? "Upcoming";
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      final updatedEvent = Event(
        id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        category: _categoryController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        status: _status,
        creatorId: widget.event?.creatorId ?? widget.userId,
        isPublished: widget.event?.isPublished ?? false,
      );

      if (widget.event == null) {
        await _sqliteEventController.addEvent(updatedEvent);
      } else {
        await _sqliteEventController.updateEvent(updatedEvent);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event ${widget.event == null ? "added" : "updated"} successfully!")),
      );

      Navigator.pop(context, true); // Indicate changes were made
    }
  }



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? "Add Event" : "Edit Event"),
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
                  decoration: InputDecoration(labelText: "Event Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the event name";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: "Category"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the event category";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Location Field
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: "Location"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the event location";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                SizedBox(height: 16),

                // Date Picker
                Row(
                  children: [
                    Text("Date: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: TextStyle(color: Colors.blue),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text("Change Date"),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _status,
                  items: ["Upcoming", "Current", "Past"]
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
                      onPressed: _saveEvent,
                      child: Text("Save"),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, false); // Indicate no changes
                      },
                      child: Text("Cancel"),
                    ),


                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
