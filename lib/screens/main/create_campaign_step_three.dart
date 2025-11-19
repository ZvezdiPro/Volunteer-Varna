import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';

class CreateCampaignStepThree extends StatefulWidget {
  const CreateCampaignStepThree({super.key});

  @override
  State<CreateCampaignStepThree> createState() => _CreateCampaignStepThreeState();
}

class _CreateCampaignStepThreeState extends State<CreateCampaignStepThree> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGrey,
      child: Center(
        child: Text('Трета стъпка при добавяне на кампания'),
      ),
    );
  }
}