import 'package:flutter/material.dart';
import 'package:volunteer_app/screens/main/create_campaign.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/shared/constants.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Това е страницата за събития!'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add_task),
        label: Text('Добави събитие'),
        backgroundColor: greenPrimary,
        foregroundColor: Colors.white,
        // When pressed, "push" the CreateCampaign screen
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateCampaign(), 
            ),
          );
        },
      ),
      
    );
  }
}