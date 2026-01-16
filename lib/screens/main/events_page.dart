import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/screens/main/create_campaign.dart';
import 'package:volunteer_app/services/database.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/widgets/campaign_list.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _searchQuery = '';
  String _selectedCategory = 'Всички'; 

  final List<String> _categories = ['Всички',
    'Образование', 'Екология', 'Животни', 'Грижа за деца', 'Спорт', 'Здраве',
    'Грижа за възрастни', 'Изкуство и култура', 'Помощ в извънредни ситуации'
  ];

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Campaign>>.value(
      value: DatabaseService().campaigns,
      initialData: const [],
      child: Scaffold(
        backgroundColor: backgroundGrey,
        
        body: Consumer<List<Campaign>>(
          builder: (context, allCampaigns, child) {
            // Filter the campaigns based on the search query
            List<Campaign> filteredCampaigns = allCampaigns.where((campaign) {
              final titleLower = campaign.title.toLowerCase();
              final searchLower = _searchQuery.toLowerCase();
              return titleLower.contains(searchLower);
            }).toList();

            return Column(
              children: [
                // Search bar and category filters
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  color: backgroundGrey,
                  child: Column(
                    children: [
                      // Search bar
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Търси по име на кампания...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: blueSecondary, width: 1.0),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10.0),

                      // Scrolling list of filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                    // TODO: Apply filtering logic based on selected category
                                  });
                                },
                                selectedColor: greenPrimary.withAlpha(30),
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: isSelected ? greenPrimary : Colors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                side: isSelected 
                                  ? const BorderSide(color: greenPrimary) 
                                  : BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // List of campaigns
                Expanded(
                  child: Provider<List<Campaign>>.value(
                    value: filteredCampaigns,
                    child: !_auth.currentUser!.isAnonymous
                      ? CampaignList()
                      : CampaignList(showRegisterButton: false),
                  ),
                ),
              ],
            );
          },
        ),

        floatingActionButton: !_auth.currentUser!.isAnonymous
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_task),
              label: const Text('Добави събитие'),
              backgroundColor: greenPrimary,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateCampaign(),
                  ),
                );
              },
            )
          : null,
      ),
    );
  }
}