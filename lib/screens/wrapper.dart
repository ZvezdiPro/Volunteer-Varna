import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/screens/authenticate/authentication.dart';
import 'package:volunteer_app/screens/main/main_page.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<VolunteerUser?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return MainPage();
    }
  }
}