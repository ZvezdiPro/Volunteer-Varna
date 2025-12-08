import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/services/database.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/widgets/campaign_list.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    
    final VolunteerUser? volunteer = Provider.of<VolunteerUser?>(context);
    final databaseService = DatabaseService(uid: volunteer!.uid);

    return StreamProvider<List<Campaign>>.value(
      value: databaseService.registeredCampaigns,
      initialData: [],
      child: Scaffold(
        backgroundColor: backgroundGrey,
        // If the user is not registered for any campaigns, show a message
        body: Consumer<List<Campaign>>(
          builder: (context, registeredCampaigns, _) {
            if (registeredCampaigns.isEmpty) {
              return Center(
                child: Text(
                  'Все още не сте записани за кампании.',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              );
            } else {
              return CampaignList(showRegisterButton: false);
            }
          },
        ),
      ),
    );
  }
}