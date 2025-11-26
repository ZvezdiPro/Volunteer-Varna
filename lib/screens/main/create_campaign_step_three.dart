import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/models/campaign_data.dart';
import 'package:volunteer_app/shared/constants.dart';


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
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 40.0, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form (
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Heading
            Text('Стъпка 3: Детайли', style: mainHeadingStyle, textAlign: TextAlign.center),
            SizedBox(height: 30.0),
            
            // Required Volunteers
            // TODO: Make it a field with increment/decrement buttons
            Text('Необходим брой доброволци', style: textFormFieldHeading),
            SizedBox(height: 10.0),
            TextFormField(
              decoration: textInputDecoration.copyWith(labelText: 'Брой доброволци', hintText: 'Въведете брой'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Моля, въведете брой доброволци';
                }
                if (int.tryParse(val) == null || int.parse(val) <= 0) {
                  return 'Моля, въведете валиден положителен брой';
                }
                return null;
              },
              onChanged: (val) => widget.data.requiredVolunteers = int.tryParse(val) ?? 0,
            ),

            SizedBox(height: 20.0),

            // Instructions (optional)
            Text('Инструкции (опционално)', style: textFormFieldHeading),
            SizedBox(height: 10.0),
            TextFormField(
              decoration: textInputDecoration.copyWith(labelText: 'Допълнителни инструкции', hintText: 'Например: носете ръкавици и чували'),
              onChanged: (val) => widget.data.instructions = val,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),

            SizedBox(height: 20.0),

            // Upload image (optional)
            Text('Изображение за кампанията', style: textFormFieldHeading),
            SizedBox(height: 10.0),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file, color: Colors.white),
              label: Text('Качете изображение', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenPrimary,
              ),
              onPressed: () {
                // TODO: Implement image upload functionality
                // Update widget.data.imagePath accordingly
              },
            ),

          ]
        ),
      )
    );
  }
}