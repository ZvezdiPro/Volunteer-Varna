import 'package:flutter/material.dart';

class RegisterStepTwo extends StatefulWidget {
  const RegisterStepTwo({super.key});

  @override
  State<RegisterStepTwo> createState() => _RegisterStepTwoState();
}

class _RegisterStepTwoState extends State<RegisterStepTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Center(
          child: Text('Това е вторият екран за регистрация'),
        )
      ),
    );
  }
}