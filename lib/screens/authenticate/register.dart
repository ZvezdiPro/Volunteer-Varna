import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:volunteer_app/services/authenticate.dart';
// TODO: Import database service file
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
  // TODO: Add database service instance here
  final RegistrationData _data = RegistrationData(); // To keep the user data before creating an object

  // The PageController keeps track of which page the user is on
  PageController pageController = PageController();
  
  bool loading = false;
  int _currentPage = 0;
  String _authError = '';

  @override
  void initState() {
    super.initState();
  }

  // There are a total of three registration screens
  final int totalSteps = 3;

  // Method to go to the next page
  void nextStep() {
    if (_currentPage < totalSteps - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      // Финална стъпка
      _submitRegistration();
    }
  }

  // Method to go back to the previous page
  void previousStep() {
    if (_currentPage > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  // Submit registration method
  Future<void> _submitRegistration() async {
    setState(() {
      loading = true;
    });
    
    // Firebase Authentication
    VolunteerUser? authUser = await _auth.registerWithEmailAndPassword(_data.email, _data.password);

    if (authUser == null) {
      setState(() {
        _authError = 'Неуспешна регистрация! Проверете имейла и паролата.';
        loading = false;
      });
      return; 
    }

    // Creating a new VolunteerUser
    final VolunteerUser newUser = VolunteerUser(
      uid: authUser.uid,
      email: _data.email, 
      firstName: _data.firstName, 
      lastName: _data.lastName,
      interests: _data.interests,
      phoneNumber: _data.phoneNumber,
      dateOfBirth: _data.dateOfBirth,
      bio: _data.bio,
      avatarUrl: _data.avatarUrl,
      
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // TODO: Update user data in the database (something like the line below:)
    // await _dbService.updateUserData(newUser);

    // Switches to the Sign-In page
    // TODO: Go to the Home screen
    widget.toggleView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      
      body: Stack(
        children: [
          // The registration pages
          PageView(
            controller: pageController,
            // The value of _currentPage changes whenever _currentPage changes
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              RegisterStepOne(data: _data, nextStep: nextStep, toggleView: widget.toggleView),
              RegisterStepTwo(),
              RegisterStepThree(),
            ],
          ),

          // The dot indicator of the progress
          Container(
            alignment: Alignment(0, 0.85),
            child: SmoothPageIndicator(
              controller: pageController,
              count: 3,
              onDotClicked: (index) => pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeIn
              )
            )
          )
        ]
      )
    );
  }
}