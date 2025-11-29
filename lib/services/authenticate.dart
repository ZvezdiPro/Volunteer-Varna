import 'package:firebase_auth/firebase_auth.dart';
import 'package:volunteer_app/models/registration_data.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user object based on Firebase User
  VolunteerUser? _userFromFirebaseUser(User? user) {
      return user != null ? VolunteerUser.forAuth(uid: user.uid) : null;
    }

  Future<VolunteerUser?> _volunteerFromFirebaseUser(User? user, RegistrationData data) async {
    return user != null ? VolunteerUser(
      uid: user.uid,
      email: data.email,
      firstName: data.firstName,
      lastName: data.lastName,
      interests: data.interests, 
      experiencePoints: 0,
      userLevel: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      bio: data.bio,
      avatarUrl: data.avatarUrl,
      phoneNumber: data.phoneNumber,
      dateOfBirth: data.dateOfBirth,
    ) : null;
  } 

  Stream<VolunteerUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
    // Same as .map((User? user) => _userFromFirebaseUser(user));
    }

  Future<VolunteerUser?> registerWithEmailAndPassword(String email, String password, RegistrationData data) async {
    try {
      // Attempt to create the user
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Get the newly created firebase (authenticated) user (could be null)
      User? user = result.user;
      // Create a new document for the user with the uid using the registration data
      await DatabaseService(uid: user!.uid).updateUserData(data);
      // Return the VolunteerUser object using both Firebase User (for the uid) and registration data
      return await _volunteerFromFirebaseUser(user, data);
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<VolunteerUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      // Fetch and return the VolunteerUser object from the database
      return await DatabaseService(uid: user!.uid).getVolunteerUser();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
  
}