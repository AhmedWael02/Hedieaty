import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import 'event_details_page.dart';

class EventListPage extends StatefulWidget {

  final String userId; // Accept user ID as a parameter
  final String? pledgerId;

  EventListPage({Key? key, required this.userId, this.pledgerId}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _controller = EventController();
  List<Event> _events = [];
  String _sortCriteria = "Name";

  @override
  void initState() {
    super.initState(); // Filter events by user ID
    _loadEvents(); // Load events for the user when the page is initialized
  }

  Future<void> _loadEvents() async {
    List<Event> events = await _controller.sortEvents(widget.userId, _sortCriteria);
    setState(() {
      _events = events;
    });
  }

  void _sortEvents(String criteria) async {
    setState(() {
      _sortCriteria = criteria;
    });
    await _loadEvents(); // Reload events based on new sort criteria
  }

  Future<void> _addEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(
          userId: widget.userId, // Pass the current user ID
        ),
      ),
    );
    await _loadEvents(); // Reload events after adding a new one
  }

  Future<void> _editEvent(Event event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(
          event: event,
          userId: widget.userId, // Pass the current user ID
        ),
      ),
    );
    await _loadEvents(); // Reload events after editing
  }


  Future<void> _deleteEvent(String id) async {
    await _controller.deleteEvent(id);
    await _loadEvents(); // Reload events after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event List"),
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
                _sortEvents(value);
              }
            },
          ),
        ],
      ),
      body: _events.isNotEmpty
          ? ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            child: ListTile(
              title: Text(event.name),
              subtitle: Text("${event.category} - ${event.status}"),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "Edit") {
                    _editEvent(event);
                  } else if (value == "Delete") {
                    _deleteEvent(event.id);
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
                ],
              ),
              onTap: () {
                // Navigate to the Gift List Page
                Navigator.pushNamed(
                  context,
                  '/giftList',
                  arguments: {
                    'event': event,
                    'userId': widget.userId, // Pass the actual userId here
                    'pledgerId': widget.pledgerId,
                  },
                );
              },
            ),
          );
        },
      )

          : Center(child: Text("No events found. Add one to get started!")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: Icon(Icons.add),
      ),
    );
  }
}
