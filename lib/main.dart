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
  int currentPageIndex = 0;

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
        body: <Widget>
        [
          Center(child: Text('Home Page')),
          Center(child: Text('Events Page')),
          Center(child: Text('Profile Page')),
        ][currentPageIndex],
        bottomNavigationBar: NavigationBar(destinations: 
          [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(  
              icon: Icon(Icons.event),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
        ),
      ),
    );
  }
}