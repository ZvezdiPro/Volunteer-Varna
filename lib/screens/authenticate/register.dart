import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:volunteer_app/services/authenticate.dart';
// TODO: Import database service file
import 'package:volunteer_app/shared/constants.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/shared/loading.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/models/registration_data.dart';

import 'package:volunteer_app/screens/authenticate/register_step_one.dart';
import 'package:volunteer_app/screens/authenticate/register_step_two.dart';
import 'package:volunteer_app/screens/authenticate/register_step_three.dart';

class Register extends StatefulWidget {
  // const Register({super.key});

  final Function toggleView;
  Register({required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String repeatedPassword = '';
  String error = '';

  // The PageController keeps track of which page the user is on
  PageController pageController = PageController();
  
  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: backgroundGrey,
      
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            children: [
              RegisterStepOne(toggleView: widget.toggleView),
              RegisterStepTwo(),
              RegisterStepThree(),
            ],
          ),
          Container(
            alignment: Alignment(0, 0.85),
            child: SmoothPageIndicator(controller: pageController, count: 3)
          )
        ]
      )
    );
  }
}