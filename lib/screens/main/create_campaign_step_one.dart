import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';

class CreateCampaignStepOne extends StatefulWidget {
  const CreateCampaignStepOne({super.key});

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