import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
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
  final EventController _controller = EventController();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late DateTime _selectedDate;
  String _status = "Upcoming";

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.event?.name ?? '');
    _categoryController =
        TextEditingController(text: widget.event?.category ?? '');
    _selectedDate = widget.event?.date ?? DateTime.now();
    _status = widget.event?.status ?? "Upcoming";
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        id: widget.event?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        category: _categoryController.text,
        date: _selectedDate,
        status: _status,
        creatorId: widget.event?.creatorId ?? widget.userId, // Retain existing creatorId or use userId
      );

      if (widget.event == null) {
        _controller.addEvent(newEvent);
      } else {
        _controller.updateEvent(newEvent);
      }

      Navigator.pop(context);
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
                Text("Date: ${_selectedDate.toLocal()}".split(' ')[0]),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text("Select Date"),
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
                        Navigator.pop(context);
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
