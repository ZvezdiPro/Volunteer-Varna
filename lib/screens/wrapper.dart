import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/screens/authenticate/authenticate.dart';
import 'package:volunteer_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<VolunteerUser?>(context);
    print(user);

    // Returns home or authenticate widget based on authentication state
    if (user == null) {
      return Authenticate();
    }
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Work in progress'),
        ),
      );
    }
  }
}