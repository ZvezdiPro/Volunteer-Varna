class Campaign {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final String location;
  final String instructions; // Not required
  final int requiredVolunteers;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> categories;
  final List<String> registeredVolunteersUids;

  Campaign({
    required this.id,
    required this.organizerId, 
    required this.title,
    required this.description,
    required this.location,
    required this.requiredVolunteers,
    required this.startDate,
    required this.endDate,
    required this.imageUrl, 
    required this.createdAt,
    required this.updatedAt,
    required this.categories,
    this.instructions = '',
    this.registeredVolunteersUids = const [],
  });
}
  