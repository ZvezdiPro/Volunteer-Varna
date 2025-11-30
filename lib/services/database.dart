import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volunteer_app/models/registration_data.dart';
import 'package:volunteer_app/models/volunteer.dart';

class DatabaseService {
  
  final String? uid;
  DatabaseService({ this.uid });

  final CollectionReference volunteerCollection = FirebaseFirestore.instance.collection('volunteers');

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
}