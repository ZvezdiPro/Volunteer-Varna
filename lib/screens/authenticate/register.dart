import 'package:flutter/material.dart';
import 'package:volunteer_app/services/authenticate.dart';
import 'package:volunteer_app/shared/constants.dart';
import 'package:volunteer_app/shared/colors.dart';

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
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        backgroundColor: greenPrimary,
        elevation: 0.0,
        title: const Text('Регистрация'),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text('Влезте'),
            onPressed: () {
              // Toggle to register view
              widget.toggleView();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
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
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Парола'),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Въведете парола с най-малко 6 знака' : null,
                onChanged: (val) {
                  // Handle password input change
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentAmber,
                  foregroundColor: backgroundGrey,
                ),
                child: Text('Регистрация'),
                onPressed: () async {
                  // Handle sign-in button press
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                    if (result == null) {
                      setState(() {
                        error = 'Моля въведете валиден имейл адрес';
                        loading = false;
                      });
                    }
                  }
                },
              ),

              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),

            ],
          )
        ),
      ),
    );
  }
}