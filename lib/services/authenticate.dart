import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:volunteer_app/models/registration_data.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auth change user stream
  // Maps the Firebase User to a VolunteerUser using asyncMap
  // and the helper method which uses the id to fetch the full data
  Stream<VolunteerUser?> get user {
    // We use the asyncMap() because of the async method _fullUserFromFirebaseUser
    return _auth.authStateChanges().asyncMap(_fullUserFromFirebaseUser);
  }

  // Create user object based on Firebase User
  // The method is asynchronous because it fetches additional data from Firestore (which takes time)
  Future<VolunteerUser?> _fullUserFromFirebaseUser(User? user) async {
    if (user == null) {
      return null; 
    }
    // Get the VolunteerUser from the database using the uid
    return await DatabaseService(uid: user.uid).getVolunteerUser();
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

  Future<bool> googleLogin() async {
    final user = await GoogleSignIn().signIn();

    if (user == null) {
      return false; 
    }

    GoogleSignInAuthentication userAuth = await user.authentication;

    var credential = GoogleAuthProvider.credential(
      idToken: userAuth.idToken, 
      accessToken: userAuth.accessToken
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    return await FirebaseAuth.instance.currentUser != null;
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