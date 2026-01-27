import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String status;

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
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      organizerId: data['organizerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      instructions: data['instructions'] ?? '',
      requiredVolunteers: data['requiredVolunteers'] ?? 0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      categories: List<String>.from(data['categories'] ?? const []),
      registeredVolunteersUids: List<String>.from(data['registeredVolunteersUids'] ?? const []),
      status: data['status'] ?? 'active',
    );
  }
}
  