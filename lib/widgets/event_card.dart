import 'package:flutter/material.dart';
import 'package:volunteer_app/models/campaign.dart';

class CampaignCard extends StatefulWidget {
  
  final Campaign campaign;
  CampaignCard({required this.campaign});

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(widget.campaign.title),
          subtitle: Text(widget.campaign.description),
        ),
      ),
    );
  }
}