import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_app/models/registration_data.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/shared/constants.dart';

class RegisterStepTwo extends StatefulWidget {

  final RegistrationData data;
  final VoidCallback nextStep;
  final VoidCallback previousStep;

  const RegisterStepTwo({
    super.key, 
    required this.data, 
    required this.nextStep,
    required this.previousStep
  });

  @override
  State<RegisterStepTwo> createState() => _RegisterStepTwoState();
}

class _RegisterStepTwoState extends State<RegisterStepTwo> {
  final _stepTwoFormKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {

    // Format the birth date to an output string
    final dateText = widget.data.dateOfBirth == null 
        ? 'Рождена дата (по избор)'
        : DateFormat('dd.MM.yyyy').format(widget.data.dateOfBirth!);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
      child: Form(
        key: _stepTwoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 150.0),
            Text('Стъпка 2: Лични Данни', style: mainHeadingStyle),
            SizedBox(height: 20.0),

            // First name input
            TextFormField(
              initialValue: widget.data.firstName,
              decoration: textInputDecoration.copyWith(hintText: 'Име'),
              validator: (val) => val!.isEmpty ? 'Моля, въведете име' : null,
              onChanged: (val) => widget.data.firstName = val, 
            ),

            SizedBox(height: 20.0),

            // Surname input
            TextFormField(
              initialValue: widget.data.lastName,
              decoration: textInputDecoration.copyWith(hintText: 'Фамилия'),
              validator: (val) => val!.isEmpty ? 'Моля, въведете фамилия' : null,
              onChanged: (val) => widget.data.lastName = val, 
            ),

            SizedBox(height: 20.0),

            // Phone number input
            TextFormField(
              initialValue: widget.data.phoneNumber,
              keyboardType: TextInputType.phone,
              decoration: textInputDecoration.copyWith(hintText: 'Телефонен номер (по избор)', hintStyle: TextStyle(color: Colors.grey[600])),
              onChanged: (val) => widget.data.phoneNumber = val.isEmpty ? null : val, 
            ),

            SizedBox(height: 20.0),

            // Select birthday
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade100, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: widget.data.dateOfBirth == null ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.0),

            // Biography input
            TextFormField(
              initialValue: widget.data.bio,
              maxLines: 5,
              decoration: textInputDecoration.copyWith(hintText: 'Разкажи за себе си... (по избор)', hintStyle: TextStyle(color: Colors.grey[600])),
              onChanged: (val) => widget.data.bio = val.isEmpty ? null : val, 
            ),
            
            SizedBox(height: 15.0),

            // Go to the third page button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              ),
              child: const Text('Напред към избор на интереси'),
              onPressed: () {
                // If all validator fields return null (meaning everything is OK), go to the next step
                if (_stepTwoFormKey.currentState!.validate()) {
                  widget.nextStep();
                }
              },
            ),

          ],
        )
      )
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: greenPrimary, 
            colorScheme: ColorScheme.light(primary: greenPrimary),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        widget.data.dateOfBirth = pickedDate;
      });
    }
  }
}