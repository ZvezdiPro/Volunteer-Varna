import 'package:flutter/material.dart';
import 'package:volunteer_app/models/campaign_data.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/shared/constants.dart';
import 'package:volunteer_app/shared/loading.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// TODO: Import database service file

import 'package:volunteer_app/screens/main/create_campaign_step_one.dart';
import 'package:volunteer_app/screens/main/create_campaign_step_two.dart';
import 'package:volunteer_app/screens/main/create_campaign_step_three.dart';


class CreateCampaign extends StatefulWidget {
  const CreateCampaign({super.key});

  @override
  State<CreateCampaign> createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaign> {
  final CampaignData _data = CampaignData();
  final PageController _pageController = PageController();

  bool _loading = false;
  int _currentPage = 0;
  final int totalSteps = 3;

  final GlobalKey<FormState> _stepOneFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _stepTwoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _stepThreeFormKey = GlobalKey<FormState>();

  GlobalKey<FormState> _getCurrentFormKey() {
    switch (_currentPage) {
      case 0: return _stepOneFormKey;
      case 1: return _stepTwoFormKey;
      case 2: return _stepThreeFormKey;
      default: return _stepOneFormKey;
    }
  }

  void nextStep() {
    // If we aren't on the last page, go to the next
    if (_currentPage < totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeIn
      );
    }
    else {
      Navigator.pop(context);
    }
  }
  
  void previousStep() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeIn
      );
    }
  }

  void _submitCampaign() async {
    setState(() {
      _loading = true;
      });
    
    // TODO: Create a Campaign object using the data and add it to the DB
    // Needs to call the constructor AND use the organiserID usign the Auth service
    // Needs to be in a try-catch block so that errors can be displayed
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? const Loading() : Scaffold (
      backgroundColor: backgroundGrey,
      resizeToAvoidBottomInset: false,

      // AppBar at the top
      appBar: AppBar(
        title: const Text('Добавяне на кампания', style: appBarHeadingStyle),
        centerTitle: true,
        backgroundColor: backgroundGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () { Navigator.of(context).pop(); }
        ),
      ),

      body: Stack(
        children: [
          // The Campaign creation pages
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            // The value of _currentPage changes when a page is selected
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              CreateCampaignStepOne(data: _data, formKey: _stepOneFormKey),
              CreateCampaignStepTwo(data: _data, formKey: _stepTwoFormKey),
              CreateCampaignStepThree(data: _data, formKey: _stepThreeFormKey)
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
                    controller: _pageController,
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
                        _pageController.animateToPage(
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
      ),
      
    );
  }
}