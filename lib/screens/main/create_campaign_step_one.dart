import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/models/campaign_data.dart';

class CreateCampaignStepOne extends StatefulWidget {
  final CampaignData data;
  final GlobalKey<FormState> formKey;

  const CreateCampaignStepOne({
    super.key,
    required this.data,
    required this.formKey,
  });

  @override
  State<CreateCampaignStepOne> createState() => _CreateCampaignStepOneState();
}

class _CreateCampaignStepOneState extends State<CreateCampaignStepOne> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGrey,
      child: Center(
        child: Text('Първа стъпка при добавяне на кампания'),
      ),
    );
  }
}