class Friend {
  final String id;
  String name;
  final String profileUrl;
  int upcomingEvents;

  Friend({
    required this.id,
    required this.name,
    required this.profileUrl,
    this.upcomingEvents =0,
  });
}
