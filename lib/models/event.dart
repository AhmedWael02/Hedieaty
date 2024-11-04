class Event {
  final String id;
  final String name;
  final String category;
  final DateTime date;
  final String status;
  final String creatorId;

  Event({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.status,
    required this.creatorId,
  });
}
