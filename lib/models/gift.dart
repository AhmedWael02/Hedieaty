class Gift {
  final String id;
  final String eventId; // New field to link the gift to an event
  final String name;
  final String description;
  final String category;
  final double price;
  String status; // "Available", "Pledged"
  String? pledgedBy; // User who pledged the gift

  Gift({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.status = "Available",
    this.pledgedBy,
  });
}
