import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/volunteer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final VolunteerUser? volunteer = Provider.of<VolunteerUser?>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Моят Профил')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Здравей, ${volunteer!.firstName}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Имейл: ${volunteer.email}'),
            Text('Ниво: ${volunteer.userLevel}'),
            Text('Точки опит: ${volunteer.experiencePoints}'),
          ],
        ),
      ),
    );
  }
}