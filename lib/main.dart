import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/screens/wrapper.dart';
import 'package:volunteer_app/services/authenticate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VolunteerApp());
}

class VolunteerApp extends StatefulWidget {
  const VolunteerApp({super.key});

  @override
  State<VolunteerApp> createState() => _VolunteerAppState();
}

class _VolunteerAppState extends State<VolunteerApp> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamProvider<VolunteerUser?>.value (
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Volunteer App',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        // The wrapper widget decides which page to show based on authentication state
        home: Wrapper(),
      )
    );
  }
}