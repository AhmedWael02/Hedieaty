import 'package:flutter/material.dart';
import '../controllers/sqlite_controllers/sqlite_event_controller.dart';
import '../models/event.dart';
import 'event_details_page.dart';
import 'package:intl/intl.dart';
import '../controllers/firestore_controllers/firestore_event_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventListPage extends StatefulWidget {

  final String userId; // Accept user ID as a parameter
  final String? pledgerId;

  EventListPage({Key? key, required this.userId, this.pledgerId}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final SqliteEventController _sqliteEventController = SqliteEventController();
  final FirestoreEventController _firestoreEventController = FirestoreEventController();
  List<Event> _publishedEvents = [];
  List<Event> _unPublishedEvents = [];
  List<Event> _shownEvents = [];
  String _sortCriteria = "Name";

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (widget.pledgerId == null) {
      // Fetch unpublished events from SQLite
      List<Event> unPublishedEvents = await _sqliteEventController.getUnpublishedEventsByUserId(widget.userId);

      // Fetch published events from Firestore
      final eventsData = await _firestoreEventController.getEvents(widget.userId);
      List<Event> publishedEvents = eventsData.map((data) {
        return Event(
          id: data['id'],
          name: data['name'],
          date: (data['date'] as Timestamp).toDate(),
          location: data['location'],
          description: data['description'],
          category: data['category'],
          status: data['status'],
          creatorId: data['creatorId'],
          isPublished: true,
        );
      }).toList();

      // Merge unpublished and published events
      setState(() {
        _unPublishedEvents = unPublishedEvents;
        _publishedEvents = publishedEvents;

        // Combine and deduplicate events
        _shownEvents = [..._unPublishedEvents];
        for (var publishedEvent in _publishedEvents) {
          final index = _shownEvents.indexWhere((e) => e.id == publishedEvent.id);
          if (index == -1) {
            _shownEvents.add(publishedEvent);
          }
        }
      });
    } else {
      final eventsData = await _firestoreEventController.getEvents(widget.userId);
      setState(() {
        _shownEvents = eventsData
            .map((data) {
          return Event(
            id: data['id'],
            name: data['name'],
            date: (data['date'] as Timestamp).toDate(),
            location: data['location'],
            description: data['description'],
            category: data['category'],
            status: data['status'],
            creatorId: data['creatorId'],
            isPublished: data['isPublished'],
          );
        })
            .where((event) => event.isPublished)
            .toList(); // Only show published events for pledger
      });
    }
  }






  Future<void> _sortEvents(String criteria) async {
    if (widget.pledgerId == null) {
      setState(() {
        _sortCriteria = criteria;
      });
      await _loadEvents(); }

    else {
      setState(() {
        _sortCriteria = criteria;

        if (criteria == "Name") {
          _shownEvents.sort((a, b) => a.name.compareTo(b.name));
        } else if (criteria == "Category") {
          _shownEvents.sort((a, b) => a.category.compareTo(b.category));
        } else if (criteria == "Status") {
          _shownEvents.sort((a, b) => a.status.compareTo(b.status));
        }
      });
    }
  }

  Future<void> _addEvent () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EventDetailsPage(
              userId: widget.userId,
            ),
      ),
    );
    await _loadEvents();
  }





  Future<void> _editEvent(Event event) async {
    if (widget.pledgerId == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsPage(
            event: event,
            userId: widget.userId,
          ),
        ),
      );

      if (result == true) {
        // Reload events to update the tile
        await _loadEvents();
      }
    }
  }







  Future<void> _deleteEvent(String id) async {
      await _sqliteEventController.deleteEvent(id);
      await FirebaseFirestore.instance.collection('Events').doc(id).delete();
      await _loadEvents(); // Reload events after deletion
    }


  Future<void> _publishEvent(String eventId) async {
    try {
      // Fetch the event from SQLite
      final event = await _sqliteEventController.getEventById(eventId);

      if (event == null) {
        throw Exception("Event not found in local database.");
      }

      // Convert event to Firestore-compatible format
      final eventData = {
        'name': event.name,
        'category': event.category,
        'date': Timestamp.fromDate(event.date),
        'location': event.location,
        'description': event.description,
        'status': event.status,
        'creatorId': event.creatorId,
        'isPublished': true, // Set isPublished to true
      };

      // Check if the event exists in Firestore
      final docRef = FirebaseFirestore.instance.collection('Events').doc(eventId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Update the existing event
        await docRef.set(eventData, SetOptions(merge: true));
      } else {
        // Create a new event
        await docRef.set(eventData);
      }

      // Update SQLite and UI
      await _sqliteEventController.publishEvent(eventId, true);
      setState(() {
        final eventIndex = _shownEvents.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          _shownEvents[eventIndex] = Event(
            id: event.id,
            name: event.name,
            date: event.date,
            location: event.location,
            description: event.description,
            category: event.category,
            status: event.status,
            creatorId: event.creatorId,
            isPublished: true,
          );
        }
      });

      print("Event published successfully.");
    } catch (e) {
      print("Failed to publish event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to publish event. Please try again.")),
      );
    }
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
      body: _shownEvents.isNotEmpty
          ? ListView.builder(
        itemCount: _shownEvents.length,
        itemBuilder: (context, index) {
          final event = _shownEvents[index];

          // Skip unpublished events if pledgerId is not null
          if (!event.isPublished && widget.pledgerId != null) {
            return SizedBox.shrink();
          }

          else {
            return Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 4,
              child: ListTile(
                title: Text(
                  event.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text("Category: ${event.category}"),
                    Text("Status: ${event.status}"),
                    Text("Date: ${DateFormat('dd MMM yyyy').format(
                        event.date)}"),
                    Text("Location: ${event.location}"),
                    Text("Description: ${event.description}"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!event.isPublished && widget.pledgerId == null)
                      IconButton(
                        icon: Icon(Icons.publish, color: Colors.blue),
                        tooltip: "Publish",
                        onPressed: () => _publishEvent(event.id),
                      ),
                    if (widget.pledgerId == null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == "Edit") {
                            _editEvent(event);

                          } else if (value == "Delete") {
                            _deleteEvent(event.id);
                          }
                        },
                        itemBuilder: (context) =>
                        [
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
          }
        },
      )

          : Center(child: Text("No events found. Add one to get started!")),
      floatingActionButton: widget.pledgerId == null
          ? FloatingActionButton(
        onPressed: _addEvent,
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
