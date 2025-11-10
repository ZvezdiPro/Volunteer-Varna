import 'package:flutter/material.dart';
import 'package:volunteer_app/services/authenticate.dart';
import 'package:volunteer_app/shared/constants.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/shared/loading.dart';

class RegisterStepOne extends StatefulWidget {
  // const Register({super.key});

  final Function toggleView;
  RegisterStepOne({required this.toggleView});

  @override
  State<RegisterStepOne> createState() => _RegisterStepOneState();
}

class _RegisterStepOneState extends State<RegisterStepOne> {

  final AuthService _auth = AuthService();
  final _stepOneFormKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String repeatedPassword = '';
  String error = '';

  bool _isPasswordVisible = false;
  bool _isRepeatedPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: backgroundGrey,
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _stepOneFormKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 160.0),
                const Text('Регистрация', style: mainHeadingStyle),
                SizedBox(height: 30.0),

                // Email input
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Имейл'),
                  validator: (val) => val!.isEmpty ? 'Моля въведете имейл' : null,
                  onChanged: (val) {
                    // Handle email input change
                    setState(() {
                      email = val;
                    });
                  },
                ),

                SizedBox(height: 20.0),

                // Password input
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Парола',
                    suffixIcon: IconButton(
                      // The icon changes depending on whether the password is visible or not
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: greenPrimary
                      ), 
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      })
                    ),
                  obscureText: !_isPasswordVisible,
                  validator: (val) => val!.length < 6 ? 'Въведете парола с най-малко 6 знака' : null,
                  onChanged: (val) {
                    // Handle password input change
                    setState(() {
                      password = val;
                    });
                  },
                ),

                SizedBox(height: 20.0),
                
                // Repeat password field
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Повторете паролата',
                    suffixIcon: IconButton(
                      // The icon changes depending on whether the password is visible or not
                      icon: Icon(
                        _isRepeatedPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: greenPrimary
                      ), 
                      onPressed: () {
                        setState(() {
                          _isRepeatedPasswordVisible = !_isRepeatedPasswordVisible;
                        });
                      })
                    ),
                  obscureText: !_isRepeatedPasswordVisible,
                  validator: (val) => val != password ? 'Паролите не съвпадат' : null,
                  onChanged: (val) {
                    // Handle password input change
                    setState(() {
                      repeatedPassword = val;
                    });
                  },
                ),

                SizedBox(height: 20.0),

                // Move forward to next screen button
                ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                ),
                child: const Text('Напред към вход  на лични данни'),
                onPressed: () {
                  // TODO: Move to the next screen

                },
                ),
            
            const SizedBox(height: 20.0),

                SizedBox(height: 20.0),

                // Switch to sign-in page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Имате регистрация?'),
                    GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0), 
                      child: const Text(
                        'Влезте!',
                        style: TextStyle(
                          color: greenPrimary, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.toggleView();
                    },
                  ),
                  ],
                ),

                // Error message
                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),

            ],
          )
        ),
      ),
    )
    );
  }
}