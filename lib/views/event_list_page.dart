import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import 'event_details_page.dart';

class EventListPage extends StatefulWidget {

  final String userId; // Accept user ID as a parameter

  EventListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _controller = EventController();
  late List<Event> _events;
  String _sortCriteria = "Name";

  @override
  void initState() {
    super.initState(); // Filter events by user ID
    _events = _controller.sortEvents(widget.userId,_sortCriteria);
  }

  void _sortEvents(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      _events = _controller.sortEvents(widget.userId,_sortCriteria);// Re-sort after filtering
    });
  }

  void _addEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(
          userId: widget.userId, // Pass the current user ID
        ),
      ),
    ).then((_) => setState(() {
      _events = _controller.sortEvents(widget.userId,_sortCriteria);
    }));
  }

  void _editEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(
          event: event,
          userId: widget.userId, // Pass the current user ID
        ),
      ),
    ).then((_) => setState(() {

      _events = _controller.sortEvents(widget.userId,_sortCriteria);
    }));
  }


  void _deleteEvent(String id) {
    setState(() {
      _controller.deleteEvent(id);
      _events = _controller.sortEvents(widget.userId,_sortCriteria);
    });
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
      body: ListView.builder(
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
                  arguments: event, // Passing the event details as arguments
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: Icon(Icons.add),
      ),
    );
  }
}
