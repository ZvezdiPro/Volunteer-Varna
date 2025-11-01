import 'package:flutter/material.dart';
import 'package:volunteer_app/screens/main/home.dart';
import 'package:volunteer_app/services/authenticate.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AuthService _auth = AuthService();
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer App Home'),
        backgroundColor: Colors.green,
        actions: [
            TextButton.icon(
              icon: Icon(Icons.logout),
              label: Text('logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
      ),
      body: <Widget>
      [
        HomeScreen(),
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
    );        
  }
}