import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:volunteer_app/models/registration_data.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  int loginType = 0;

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

  Future<VolunteerUser?> googleLogin() async {
    final user = await _googleSignIn.signIn();

    if (user == null) {
      return null; 
    }

    GoogleSignInAuthentication userAuth = await user.authentication;

    var credential = GoogleAuthProvider.credential(
      idToken: userAuth.idToken, 
      accessToken: userAuth.accessToken
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    if (_auth.currentUser != null) {
      if (await DatabaseService(uid: _auth.currentUser!.uid).checkUserExists()) {
        // User exists, fetch and return the VolunteerUser
        return await DatabaseService(uid: _auth.currentUser!.uid).getVolunteerUser();
      } 
      else {
        // New user, create a new document in Firestore
        RegistrationData data = RegistrationData();
        data.email = _auth.currentUser!.email ?? '';
        data.firstName = _auth.currentUser!.displayName?.split(' ').first ?? '';
        data.lastName = _auth.currentUser!.displayName?.split(' ').last ?? '';
        data.avatarUrl = _auth.currentUser!.photoURL ?? '';

        await DatabaseService(uid: _auth.currentUser!.uid).updateUserData(data);
        return await _volunteerFromFirebaseUser(_auth.currentUser, data);
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    final User? user = _auth.currentUser;
    String providerId = user!.providerData[0].providerId;

    switch (providerId) {
      case 'google.com':
        await _signOutGoogle();
        break;
      case 'password': // Email/Password login
        await _signOutFirebaseOnly();
        break;
        // TODO: Add other providers as needed
        // case 'facebook.com':
        //   // Implement Facebook sign-out logic here
        //   print('Signing out from Facebook...');
        //   await _signOutFacebook();
        //   break;
      default:
        // Handle other providers or default to Firebase sign-out
        await _signOutFirebaseOnly();
        break;
    }
  }

  // --- Specific Sign-Out Functions ---

  // 1. Sign out for Google-authenticated users
  Future<void> _signOutGoogle() async {
    try {
      // 1. Clear the Google session
      await _googleSignIn.signOut();
      // 2. Clear the Firebase session
      print('Google user signed out successfully.');
      await _auth.signOut();
    } catch (e) {
      print('Error signing out Google: $e');
    }
  }

  // 2. Sign out for Email/Password or other simple providers
  Future<void> _signOutFirebaseOnly() async {
    try {
      await _auth.signOut();
      print('User signed out successfully (Firebase only).');
    } catch (e) {
      print('Error signing out Firebase: $e');
    }
  }
  
}