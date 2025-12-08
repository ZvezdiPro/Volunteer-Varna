import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/widgets/event_card.dart';

class CampaignList extends StatefulWidget {
  const CampaignList({super.key});

  @override
  State<CampaignList> createState() => _CampaignListState();
}

class _CampaignListState extends State<CampaignList> {
  @override
  Widget build(BuildContext context) {
    
    final campaigns = Provider.of<List<Campaign>>(context);

    return ListView.builder(
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        return CampaignCard(campaign: campaigns[index]);
      },
    );
  }
}