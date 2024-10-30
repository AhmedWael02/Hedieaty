import '../models/event.dart';

class EventController {
  final List<Event> _events = [
    Event(
      id: "1",
      name: "Birthday Party",
      category: "Personal",
      date: DateTime(2024, 12, 20),
      status: "Upcoming",
    ),
    Event(
      id: "2",
      name: "Wedding",
      category: "Celebration",
      date: DateTime(2024, 12, 25),
      status: "Upcoming",
    ),
    Event(
      id: "3",
      name: "Project Deadline",
      category: "Work",
      date: DateTime(2024, 12, 15),
      status: "Current",
    ),
  ];

  List<Event> get events => List.unmodifiable(_events);

  List<Event> sortEvents(String criteria) {
    List<Event> sortedEvents = List.from(_events);
    if (criteria == "Name") {
      sortedEvents.sort((a, b) => a.name.compareTo(b.name));
    } else if (criteria == "Category") {
      sortedEvents.sort((a, b) => a.category.compareTo(b.category));
    } else if (criteria == "Status") {
      sortedEvents.sort((a, b) => a.status.compareTo(b.status));
    }
    return sortedEvents;
  }

  void addEvent(Event event) {
    _events.add(event);
  }

  void deleteEvent(String id) {
    _events.removeWhere((event) => event.id == id);
  }

  void updateEvent(Event updatedEvent) {
    final index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
    }
  }
}
