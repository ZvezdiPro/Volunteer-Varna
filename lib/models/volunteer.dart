class VolunteerUser {

  // Required fields
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> interests;

  // Optional fields
  final String? bio;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;

  // Automatically created
  final int experiencePoints;
  final int userLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor for temporary test and authentication
  VolunteerUser.forAuth({required this.uid})
    : email = '',
      firstName = '',
      lastName = '',
      interests = const [],
      experiencePoints = 0,
      userLevel = 1,
      createdAt = DateTime.now(),
      updatedAt = DateTime.now(),
      bio = null,
      avatarUrl = null,
      phoneNumber = null,
      dateOfBirth = null;

  // Full Constructor
  VolunteerUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.interests, 
    this.experiencePoints = 0,
    this.userLevel = 1,
    required this.createdAt,
    required this.updatedAt,
    this.bio,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
  });
}