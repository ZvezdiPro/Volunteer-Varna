import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/registration_data.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/models/campaign_data.dart';

class DatabaseService {
  
  final String? uid;
  DatabaseService({ this.uid });

  final CollectionReference volunteerCollection = FirebaseFirestore.instance.collection('volunteers');
  final CollectionReference campaignCollection = FirebaseFirestore.instance.collection('campaigns');

  // Method to create or update volunteer user data
  Future updateUserData(RegistrationData data) async {
    return await volunteerCollection.doc(uid).set({
    'email': data.email,
    'firstName': data.firstName,
    'lastName': data.lastName,
    'interests': data.interests, 
    'experiencePoints': 0,
    'userLevel': 1,
    'createdAt': DateTime.now(),
    'updatedAt': DateTime.now(),
    'bio': data.bio,
    'avatarUrl': data.avatarUrl,
    'phoneNumber': data.phoneNumber,
    'dateOfBirth': data.dateOfBirth,
    });
  }

  // Method to create or update campaign data
  Future updateCampaignData(CampaignData data) async {
    DocumentReference docRef = campaignCollection.doc();
    String campaignId = docRef.id;
    return await campaignCollection.doc(campaignId).set({
    'title': data.title,
    'organizerId': uid,
    'description': data.description,
    'location': data.location,
    'instructions': data.instructions,
    'requiredVolunteers': data.requiredVolunteers,
    'startDate': data.startDate,
    'endDate': data.endDate,
    'imageUrl': data.imageUrl,
    'categories': data.categories,
    'createdAt': DateTime.now(),
    'updatedAt': DateTime.now(),
    'registeredVolunteersUids': const[]
    });
  }

  // Method to get volunteer user data as a VolunteerUser object
  Future<VolunteerUser?> getVolunteerUser() async {
    if (uid == null) return null;
    // Get the document snapshot for the user with the given uid
    DocumentSnapshot doc = await volunteerCollection.doc(uid).get();
    if (doc.exists) {
      // Uses the factory constructor to create a VolunteerUser from the document snapshot
      return VolunteerUser.fromFirestore(doc);
    } else {
      return null;
    }
  }

  // Stream to get all campaigns from Firestore and map them to Campaign objects
  Stream<List<Campaign>> get campaigns {
    return campaignCollection.snapshots().map(_campaignListFromSnapshot);
  }

  // Stream campaigns the current user has registered for (For "My Campaigns" Screen)
  Stream<List<Campaign>> get registeredCampaigns {
    if (uid == null) return Stream.value([]); 

    return campaignCollection
        .where('registeredVolunteersUids', arrayContains: uid)
        .snapshots()
        .map(_campaignListFromSnapshot);
  }

  // Stream campaigns where the user is either the organizer or a registered volunteer
  Stream<List<Campaign>> get userChats {
    if (uid == null) return Stream.value([]);

    return campaignCollection
      .where(Filter.or(
        Filter('organizerId', isEqualTo: uid),       
        Filter('registeredVolunteersUids', arrayContains: uid) 
      ))
      .snapshots()
      .map(_campaignListFromSnapshot);
  }
  
  // Helper method to convert QuerySnapshot to List<Campaign>
  List<Campaign> _campaignListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Campaign.fromFirestore(doc);
    }).toList();
  }

  // Method for registering a volunteer for a campaign
  Future<void> registerUserForCampaign(String campaignId) async {
    DocumentReference campaignRef = campaignCollection.doc(campaignId);
    return await campaignRef.update({
      'registeredVolunteersUids': FieldValue.arrayUnion([uid])
    });
  }
    
  // Method to check if a volunteer user exists
  Future<bool> checkUserExists() async {
    final querySnapshot = await volunteerCollection.where('uid', isEqualTo: uid).get();
    return querySnapshot.docs.isNotEmpty;
  }
}