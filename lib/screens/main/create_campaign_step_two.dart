import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';

class CreateCampaignStepTwo extends StatefulWidget {
  const CreateCampaignStepTwo({super.key});

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