import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/screens/main/create_campaign.dart';
import 'package:volunteer_app/services/database.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/widgets/campaign_list.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Campaign>>.value(
      value: DatabaseService().campaigns,
      initialData: [],
      child: Scaffold(
        body: Container(
          color: backgroundGrey,
          child: CampaignList()
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
        
      ),
    );
  }
}