import 'package:flutter/material.dart';

class RegisterStepThree extends StatefulWidget {
  const RegisterStepThree({super.key});

  @override
  State<RegisterStepThree> createState() => _RegisterStepThreeState();
}

class _RegisterStepThreeState extends State<RegisterStepThree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: Center(
          child: Text('Това е третият екран за регистрация'),
        )
      ),
    );
  }
}