import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundGrey,
        child: Center(
          child: Text('Добре дошли в приложението за доброволци!'),
        ),
      ),
    );
  }
}