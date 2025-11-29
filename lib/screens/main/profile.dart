import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundGrey,
        child: Center(
          child: Text('Това е страницата за потребителския профил!'),
        ),
      ),
    );
  }
}