import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/models/campaign_data.dart';


class CreateCampaignStepThree extends StatefulWidget {
  final CampaignData data;
  final GlobalKey<FormState> formKey;

  const CreateCampaignStepThree({
    super.key,
    required this.data,
    required this.formKey,
  });

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