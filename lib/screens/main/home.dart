import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/services/database.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoToEvents;

  const HomeScreen({super.key, required this.onGoToEvents});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _currentUid;
  late DatabaseService _dbService;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid ?? ''; 
    _dbService = DatabaseService(uid: _currentUid);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundGrey,
      // StreamBuilder for user's data
      child: StreamBuilder<VolunteerUser>(
        stream: _dbService.volunteerUserData,
        builder: (context, userSnapshot) {
          
          String firstName = 'доброволец';
          if (userSnapshot.hasData && userSnapshot.data != null) {
            firstName = userSnapshot.data!.firstName;
          }
          
          List<String> userInterests = [];
          if (userSnapshot.hasData && userSnapshot.data != null) {
            userInterests = userSnapshot.data!.interests;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Здравей, $firstName! 👋',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 25),

                // Campaign listener
                StreamBuilder<List<Campaign>>(
                  stream: _dbService.campaigns,
                  builder: (context, campaignSnapshot) {
                    if (campaignSnapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(child: CircularProgressIndicator(color: greenPrimary)),
                      );
                    }

                    if (campaignSnapshot.hasError) {
                      return Center(child: Text('Възникна грешка: ${campaignSnapshot.error}'));
                    }

                    if (!campaignSnapshot.hasData || campaignSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text('Все още няма активни кампании.', style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    }

                    List<Campaign> allCampaigns = campaignSnapshot.data!;

                    List<Campaign> activeCampaigns = allCampaigns
                        .where((campaign) => campaign.status == 'active' && campaign.endDate.isAfter(DateTime.now()))
                        .toList();

                    if (activeCampaigns.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text('В момента няма активни кампании.', style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    }

                    activeCampaigns.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    Campaign latestCampaign = activeCampaigns.first;

                    // If there are more than 1 active campaigns which the user's interested in
                    // pick a random one from the remaining list (excluding the latest)
                    Campaign? recommendedCampaign;
                    if (activeCampaigns.length > 1) {
                      List<Campaign> remainingCampaigns = activeCampaigns.sublist(1);
                      List<Campaign> matchingCampaigns = remainingCampaigns.where((campaign) {
                        return campaign.categories.any((category) => userInterests.contains(category));
                      }).toList();
                      if (matchingCampaigns.isNotEmpty) {
                        // If there are campaigns matching the user's interests, pick a random one from that list
                        recommendedCampaign = matchingCampaigns[Random().nextInt(matchingCampaigns.length)];
                      } else {
                        // Otherwise, just pick a random campaign from the remaining active campaigns
                        recommendedCampaign = remainingCampaigns[Random().nextInt(remainingCampaigns.length)];
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Последно добавена кампания'),
                        SizedBox(
                          width: double.infinity,
                          child: CampaignCard(campaign: latestCampaign),
                        ),
                        const SizedBox(height: 30),

                        if (recommendedCampaign != null) ...[
                          _buildSectionTitle('Може да ти хареса'),
                          SizedBox(
                            width: double.infinity,
                            child: CampaignCard(campaign: recommendedCampaign),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ],
                    );
                  },
                ),

                // User's activity (placeholder for now)
                _buildSectionTitle('Твоята активност'),
                const SizedBox(height: 15),
                _buildActivitySection(),
                const SizedBox(height: 30),

                // Button to go to the Events page
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), 
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: widget.onGoToEvents,
                      child: const Text(
                        'Открий още кампании!',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildActivitySection() {
    // TODO: Implement actual activity data and UI (for now it's just a placeholder)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Тук ще бъде информацията за дейността на потребителя',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}