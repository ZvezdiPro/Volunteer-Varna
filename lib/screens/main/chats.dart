import 'package:flutter/material.dart';
import 'package:volunteer_app/shared/colors.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundGrey,
        child: Center(
          child: Text('Това е страницата за потребителските чатове!'),
        ),
      ),
    );
  }
}