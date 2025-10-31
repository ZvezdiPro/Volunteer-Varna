import 'package:flutter/material.dart';

void main() {
  runApp(const VolunteerApp());
}

class VolunteerApp extends StatefulWidget {
  const VolunteerApp({super.key});

  @override
  State<VolunteerApp> createState() => _VolunteerAppState();
}

class _VolunteerAppState extends State<VolunteerApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volunteer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Volunteer App Home'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Text('Welcome to the Volunteer App!'),
        ),
      ),
    );
  }
}