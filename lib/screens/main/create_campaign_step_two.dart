import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/models/campaign_data.dart';

class CreateCampaignStepTwo extends StatefulWidget {
  final CampaignData data;
  final GlobalKey<FormState> formKey;

  const CreateCampaignStepTwo({
    super.key,
    required this.data,
    required this.formKey,
  });

  @override
  State<CreateCampaignStepTwo> createState() => _CreateCampaignStepTwoState();
}

class _CreateCampaignStepTwoState extends State<CreateCampaignStepTwo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGrey,
      child: Center(
        child: Text('Втора стъпка при добавяне на кампания'),
      ),
    );
  }
}