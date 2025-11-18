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

  // Pages keys for the forms on each page
  final GlobalKey<FormState> _stepOneFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _stepTwoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _stepThreeFormKey = GlobalKey<FormState>();

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

  GlobalKey<FormState> _getCurrentFormKey() {
    switch (_currentPage) {
      case 0: return _stepOneFormKey;
      case 1: return _stepTwoFormKey;
      case 2: return _stepThreeFormKey;
      default: return _stepOneFormKey;
    }
  }

  // Method to go to the next page
  void nextStep() {
    final currentFormKey = _getCurrentFormKey();
    if (currentFormKey.currentState!.validate()) {
      // If not on the last page, go to the next
      if (_currentPage < totalSteps - 1) {
        pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
      // If on the last page (interests), finish the registration
      else {
        if (_data.interests.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green[400],
              content: Text('Моля, изберете поне един интерес.', style: TextStyle(color: Colors.black))
              ),
          );
          return;
        }
        _submitRegistration();
      }
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

    widget.toggleView();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: backgroundGrey,
      resizeToAvoidBottomInset: false,
      
      body: Stack(
        children: [
          // The registration pages
          PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            // The value of _currentPage changes when a page is selected
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              RegisterStepOne(data: _data, formKey: _stepOneFormKey, toggleView: widget.toggleView),
              RegisterStepTwo(data: _data, formKey: _stepTwoFormKey),
              RegisterStepThree(data: _data, formKey: _stepThreeFormKey),
            ],
          ),

          // Navigation
          Container(
            alignment: Alignment(0, 0.85),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Go to the previous page
                  SizedBox(
                    width: 100,
                    child: GestureDetector(
                      onTap: previousStep,
                      // The text will appear with an animation
                      child: AnimatedOpacity(
                        opacity: _currentPage > 0 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          'Назад',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _currentPage > 0 ? greenPrimary : Colors.transparent,
                          ),
                        ),
                      )
                    ),
                  ),

                  // Dot indicator              
                  SmoothPageIndicator(
                    controller: pageController,
                    count: totalSteps,
                    effect: JumpingDotEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: greenPrimary,
                      dotColor: Colors.grey.shade400,
                    ),
                    onDotClicked: (index) {
                      // If it's forward, make the validation
                      if (index > _currentPage) {
                        nextStep();
                      }
                      else {
                        pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn
                        );
                      }
                    }
                  ),

                  // Go to the next page
                  SizedBox(
                    width: 100,
                    child: GestureDetector(
                      onTap: nextStep,
                      // If we're on the last step, show different text
                      child: Text(
                        _currentPage == totalSteps - 1 ? 'Край' : 'Напред',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: greenPrimary,
                        ),
                      )
                    ),
                  ),
                ],
              ),
            )
          )
        ]
      )
    );
  }
}