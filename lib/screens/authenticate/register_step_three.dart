import 'package:flutter/material.dart';
import 'package:volunteer_app/models/registration_data.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/shared/constants.dart';

class RegisterStepThree extends StatefulWidget {

  final RegistrationData data;
  final VoidCallback nextStep;
  final VoidCallback previousStep;

  const RegisterStepThree({
    super.key, 
    required this.data, 
    required this.nextStep,
    required this.previousStep,
  });

  @override
  State<RegisterStepThree> createState() => _RegisterStepThreeState();
}

class _RegisterStepThreeState extends State<RegisterStepThree> {
  final _stepThreeFormKey = GlobalKey<FormState>();
  
  final List<String> availableInterests = [
    'Образование', 'Екология', 'Животни', 'Грижа за деца', 'Спорт', 'Здраве',
    'Грижа за възрастни', 'Изкуство и култура', 'Помощ в извънредни ситуации'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
      child: Form(
        key: _stepThreeFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 150.0),
            Text('Стъпка 3: Избор на интереси', style: mainHeadingStyle),
            SizedBox(height: 30.0),

            Text(
              'Изберете областите, в които искате да доброволствате (1 до 5):', 
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700)
            ),

            SizedBox(height: 20.0),

            // Contains all the interests in buttons which are clickable in order to make a selection
            Wrap(
              spacing: 8.0, 
              runSpacing: 8.0, 
              children: availableInterests.map((interest) {
                final isSelected = widget.data.interests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: greenPrimary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  checkmarkColor: Colors.white,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        if (widget.data.interests.length < 5) {
                          widget.data.interests.add(interest);
                        }
                        else {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Може да изберете максимум 5 интереса!')),
                          );
                        }
                      }
                      else {
                        widget.data.interests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            SizedBox(height: 20.0),

            // Finish registration!
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              ),
              child: const Text('Завършване на регистрацията'),
              onPressed: () {
                // If all validator fields return null (meaning everything is OK), go to the next step
                // Which in this case is submitting the registration
                if (_stepThreeFormKey.currentState!.validate()) {
                  widget.nextStep();
                }
              },
            ),
          ]
        )
      )
    );
  }
}