import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Начална страница'),
      //   backgroundColor: Colors.green,
      // ),
      body: const Center(
        child: Text('Добре дошли в приложението за доброволци!'),
      ),
    );
  }
}