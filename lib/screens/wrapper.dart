import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/screens/authenticate/authentication.dart';
import 'package:volunteer_app/screens/main/main_page.dart';
import 'package:volunteer_app/services/database.dart';
import 'package:volunteer_app/shared/loading.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  Future<VolunteerUser?> _getProfileForUser(User user) async {
    if (user.isAnonymous) {
      return VolunteerUser.forAuth(uid: user.uid);
    }
    return DatabaseService(uid: user.uid).getVolunteerUser();
  }

  @override
  Widget build(BuildContext context) {
    // Access the current Firebase User from the Provider
    final firebaseUser = Provider.of<User?>(context);

    if (firebaseUser == null) {
      return Authenticate();
    }

    // If the user is logged in, fetch the full VolunteerUser data from Firestore based on the uid
    return FutureBuilder<VolunteerUser?>(
      future: _getProfileForUser(firebaseUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading(); 
        }

        if (snapshot.hasData) {
          // Provides the VolunteerUser to the MainPage
          return Provider<VolunteerUser>.value(
            value: snapshot.data!,
            child: MainPage(),
          );
        }

        return Loading(); 
      },
    );
  }
}