import '../models/event.dart';
import 'database_helper.dart';

class EventController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Event>> getEventsByUserId(String userId) async {
    final events = await _dbHelper.getEventsByUserId(userId);
    return events.map((eventMap) {
      return Event(
        id: eventMap['id'],
        name: eventMap['name'],
        date: DateTime.parse(eventMap['date']),
        location: eventMap['location'],
        description: eventMap['description'],
        category: eventMap['category'],
        status: eventMap['status'],
        creatorId: eventMap['userId'],
        isPublished: eventMap['isPublished'] == 1,
      );
    }).toList();
  }


  Future<List<Event>> sortEvents(String userId, String criteria) async {
    // Fetch events for the given user ID
    List<Event> events = await getEventsByUserId(userId);

    // Sort the events based on the criteria
    if (criteria == "Name") {
      events.sort((a, b) => a.name.compareTo(b.name));
    } else if (criteria == "Category") {
      events.sort((a, b) => a.category.compareTo(b.category));
    } else if (criteria == "Status") {
      events.sort((a, b) => a.status.compareTo(b.status));
    }

    return events;
  }


  Future<void> addEvent(Event event) async {
    await _dbHelper.insertEvent({
      'id': event.id,
      'name': event.name,
      'date': event.date.toIso8601String(),
      'location': event.location,
      'description': event.description,
      'category': event.category,
      'status': event.status,
      'userId': event.creatorId,
      'isPublished' : event.isPublished ? 1 : 0,
    });
  }

  Future<void> deleteEvent(String id) async {
    final db = await _dbHelper.database;
    await db.delete('Events', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateEvent(Event event) async {
    final db = await _dbHelper.database;
    await db.update(
      'Events',
      {
        'name': event.name,
        'date': event.date.toIso8601String(),
        'location': event.location,
        'description': event.description,
        'category': event.category,
        'status': event.status,
        'userId': event.creatorId,
        'isPublished' : event.isPublished ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> publishEvent(String eventId, bool isPublished) async {
    final db = await _dbHelper.database;
    await db.update(
      'Events',
      {'isPublished': isPublished ? 1 : 0},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }


}
