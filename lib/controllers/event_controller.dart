import '../models/event.dart';

class EventController {
  final List<Event> _events = [
    Event(
      id: "1",
      name: "Birthday Party",
      category: "Personal",
      date: DateTime(2024, 12, 20),
      status: "Upcoming",
      creatorId: "4",
    ),
    Event(
      id: "2",
      name: "Wedding",
      category: "Celebration",
      date: DateTime(2024, 12, 25),
      status: "Upcoming",
      creatorId: "1",
    ),
    Event(
      id: "3",
      name: "Project Deadline",
      category: "Work",
      date: DateTime(2024, 12, 15),
      status: "Current",
      creatorId: "1",
    ),
  ];


  List<Event> getEventsByUserId(String userId) {
    return _events.where((event) => event.creatorId == userId).toList();
  }

  List<Event> sortEvents(String userId, String criteria) {
    List<Event> sortedEvents = getEventsByUserId(userId);
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
