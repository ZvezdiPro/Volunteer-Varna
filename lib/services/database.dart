import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volunteer_app/models/registration_data.dart';

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
}