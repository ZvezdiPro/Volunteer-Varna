import 'package:flutter/material.dart';
import 'package:volunteer_app/screens/main/home.dart';
import 'package:volunteer_app/screens/main/events_page.dart';
import 'package:volunteer_app/screens/main/chats.dart';
import 'package:volunteer_app/screens/main/profile.dart';
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

      // Appbar at the top
      appBar: AppBar(
        title: Text('Основна страница'),
        backgroundColor: Colors.green,
        actions: [
            TextButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Излезте'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
      ),

      // The four pages to navigate between
      body: <Widget>
      [
        HomeScreen(),
        EventsPage(),
        ChatsScreen(),
        ProfilePage(),
      ][currentPageIndex],

      // Navigation bar at the bottom
      bottomNavigationBar: NavigationBar(destinations: 
        [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Начало',
          ),
          NavigationDestination(  
            icon: Icon(Icons.event),
            label: 'Събития',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Чатове'
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Профил',
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