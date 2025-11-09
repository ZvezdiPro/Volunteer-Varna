import 'package:firebase_auth/firebase_auth.dart';
import 'package:volunteer_app/models/volunteer.dart';
// import 'package:volunteer_app/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user object based on Firebase User
  VolunteerUser? _userFromFirebaseUser(User? user) {
      return user != null ? VolunteerUser.forAuth(uid: user.uid) : null;
    }

  Stream<VolunteerUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
    // Same as .map((User? user) => _userFromFirebaseUser(user));
    }

  Future<VolunteerUser?> registerWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = result.user;
    return _userFromFirebaseUser(user);
  } catch (e) {
    print(e.toString());
    return null;
  }
  }

  // Sign in with email and password
  Future<VolunteerUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebaseUser(result.user);
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