import 'package:flutter/material.dart';
import 'package:volunteer_app/models/campaign_data.dart';
import 'package:volunteer_app/shared/constants.dart';

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

  final GlobalKey<FormFieldState> _titleKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _descriptionKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 40.0, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Page title
            Text(
              'Стъпка 1: Основна информация',
              style: mainHeadingStyle,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 40.0),

            // Campaign title input
            Text('Име на кампанията', style: textFormFieldHeading),
            SizedBox(height: 10.0),
            TextFormField(
              key: _titleKey,
              initialValue: widget.data.title,
              decoration: textInputDecoration.copyWith(labelText: 'Име', hintText: 'Например: Почистване на плажа'),
              validator: (val) => val!.isEmpty ? 'Въведете име' : null,
              onChanged: (val) {
                widget.data.title = val.trim();
                _titleKey.currentState?.validate();
              },
            ),

            SizedBox(height: 20.0),

            // Description input
            Text('Кратко описание', style: textFormFieldHeading),
            SizedBox(height: 10.0),
            TextFormField(
              key: _descriptionKey,
              initialValue: widget.data.description,
              decoration: textInputDecoration.copyWith(labelText: 'Въведете описание', hintText: 'Ще съберем пластмасови отпадъци от плажната ивица и ще ги рециклираме.'),
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              validator: (val) => val!.isEmpty ? 'Въведете описание' : null,
              onChanged: (val) {
                widget.data.description = val.trim();
                _descriptionKey.currentState?.validate();
              }
            ),
          ],
        ),
      ),
    );
  }
}