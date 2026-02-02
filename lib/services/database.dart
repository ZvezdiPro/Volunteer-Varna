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

  Future<void> updateUserData(RegistrationData data, {bool isOAuthLogin = false}) async {
    final docRef = volunteerCollection.doc(uid);
    final documentSnapshot = await docRef.get();

    // If the doc exists and it's a Google/Facebook login, we only update the updatedAt field
    // Because the user data is already in the database
    if (documentSnapshot.exists && isOAuthLogin) {
      return await docRef.update({
        'updatedAt': DateTime.now(),
      });
    }
    
    // We create a dictionary to hold the user data
    Map<String, dynamic> userData = {
      'email': data.email,
      'firstName': data.firstName,
      'lastName': data.lastName,
      'updatedAt': DateTime.now(),
      'avatarUrl': data.avatarUrl,
    };

    // Optional fields
    if (data.bio != null && data.bio!.isNotEmpty) userData['bio'] = data.bio;
    if (data.phoneNumber != null && data.phoneNumber!.isNotEmpty) userData['phoneNumber'] = data.phoneNumber;
    if (data.dateOfBirth != null) userData['dateOfBirth'] = data.dateOfBirth;

    // If the document does not exist, we set the createdAt and other initial fields
    if (!documentSnapshot.exists) {
      userData['createdAt'] = DateTime.now();
      userData['experiencePoints'] = 0;
      userData['userLevel'] = 1;
      userData['interests'] = data.interests;
      // If the user hasn't put values to these optional fields
      // Then we set them to default values (empty string or null)
      if (!userData.containsKey('bio')) {
        userData['bio'] = "";
      }
      if (!userData.containsKey('phoneNumber')) {
        userData['phoneNumber'] = null;
      }
      if (!userData.containsKey('dateOfBirth')) {
        userData['dateOfBirth'] = null;
      }
    }
    
    return await docRef.set(userData, SetOptions(merge: true));
  }

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

  Future<void> updateLastSeen() async {
    return await volunteerCollection.doc(uid).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

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

  Stream<VolunteerUser> get volunteerUserData {
    return volunteerCollection.doc(uid).snapshots().map((doc) {
      return VolunteerUser.fromFirestore(doc);
    });
  }

  // Stream to get all campaigns from Firestore and map them to Campaign objects
  Stream<List<Campaign>> get campaigns {
    return campaignCollection.snapshots().map(_campaignListFromSnapshot);
  }

  // Stream to get campaigns the logged-in volunteer is registered for
  Stream<List<Campaign>> get registeredCampaigns {
    return campaignCollection.where('registeredVolunteersUids', arrayContains: uid).snapshots().map(_campaignListFromSnapshot);
  }
  
  List<Campaign> _campaignListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Campaign.fromFirestore(doc);
    }).toList();
  }

  // Method for registering a volunteer for a campaign
  Future<void> registerUserForCampaign(String campaignId) async {
    // Get the document reference for the campaign
    DocumentReference campaignRef = campaignCollection.doc(campaignId);

    return await campaignRef.update({
      'registeredVolunteersUids': FieldValue.arrayUnion([uid])
    });
  }

  // Check if a volunteer document exists
  Future<bool> checkUserExists() async {
    final docSnapshot = await volunteerCollection.doc(uid).get();
    return docSnapshot.exists;
  }

  Future<void> editUserProfileData({
    required String firstName,
    required String lastName,
    required String bio,
    required List<String> interests,
  }) async {
    return await volunteerCollection.doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'interests': interests,
      'updatedAt': DateTime.now(),
    });
  }
}