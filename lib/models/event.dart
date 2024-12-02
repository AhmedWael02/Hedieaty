class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String category;
  final String status;
  final String creatorId;
  final bool isPublished;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.category,
    required this.status,
    required this.creatorId,
    this.isPublished = false,
  });
}
