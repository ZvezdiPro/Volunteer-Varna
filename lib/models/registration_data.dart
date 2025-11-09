class RegistrationData {
  
  String email = '';
  String password = '';

  String firstName = '';
  String lastName = '';
  List<String> interests = [];

  // Optional fields
  String bio = '';
  String avatarUrl = '';
  String? phoneNumber;   
  DateTime? dateOfBirth; 

  // Validation fields (if the information is correct)
  bool get isStepOneValid => email.isNotEmpty && password.length >= 6;
  bool get isStepTwoValid => firstName.isNotEmpty && lastName.isNotEmpty;
  bool get isStepThreeValid => interests.isNotEmpty;
}