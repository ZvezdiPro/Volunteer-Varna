import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/volunteer.dart';
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
  final List<String> _selectedCategories = [];
  DateTime? _selectedDate;
  bool _showSavedOnly = false;

  final List<String> _categories = [
    'Образование', 'Екология', 'Животни', 'Грижа за деца', 'Спорт', 'Здраве',
    'Грижа за възрастни', 'Изкуство и култура', 'Помощ в извънредни ситуации'
  ];

  // Helper method to show date picker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: greenPrimary, 
              onPrimary: Colors.white, 
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _openCategoryFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              color: blueSecondary.withAlpha(20),
              height: 400,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: const Text("Изберете категории", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategories.clear();
                          });
                          setState(() {});
                        },
                        child: const Text("Изчисти", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategories.contains(category);
                        
                        return CheckboxListTile(
                          title: Text(category),
                          value: isSelected,
                          activeColor: greenPrimary,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                            setState(() {}); 
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userUid = _auth.currentUser?.uid;
    
    return StreamProvider<List<Campaign>>.value(
      value: DatabaseService().campaigns,
      initialData: const [],
      child: Scaffold(
        backgroundColor: backgroundGrey,
        
        body: StreamBuilder<VolunteerUser?>(
          stream: DatabaseService(uid: userUid).volunteerUserData,
          builder: (context, userSnapshot) {
            VolunteerUser? user = userSnapshot.data;
            return Consumer<List<Campaign>>(
              builder: (context, allCampaigns, child) {
                // Filter the campaigns based on the search query
                List<Campaign> filteredCampaigns = allCampaigns.where((campaign) {
                  // Searching by name
                  final matchesSearch = campaign.title.toLowerCase().contains(_searchQuery.toLowerCase());

                  // Category Filter (if the list is empty, show all)
                  // Since campaign.categories is a list, we check if there's an intersection
                  bool matchesCategory = true;
                  if (_selectedCategories.isNotEmpty) {
                     matchesCategory = campaign.categories.any((cat) => _selectedCategories.contains(cat));
                  }

                  // Date filter
                  bool matchesDate = true;
                  if (_selectedDate != null) {
                    matchesDate = 
                      campaign.startDate.year == _selectedDate!.year &&
                      campaign.startDate.month == _selectedDate!.month &&
                      campaign.startDate.day == _selectedDate!.day;
                  }

                  // Saved campaigns filter
                  bool matchesSaved = true;
                  if (_showSavedOnly) {
                     if (user != null) {
                       matchesSaved = user.bookmarkedCampaignsIds.contains(campaign.id);
                     } else {
                       matchesSaved = false;
                     }
                  }

                  return matchesSearch && matchesCategory && matchesDate && matchesSaved;
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
                              children: [
                                // Category filter
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FilterChip(
                                    label: Row(
                                      children: [
                                        Text(_selectedCategories.isEmpty 
                                          ? "Категории" 
                                          : "Категории (${_selectedCategories.length})"),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.keyboard_arrow_down, size: 18),
                                      ],
                                    ),
                                    selected: _selectedCategories.isNotEmpty,
                                    onSelected: (_) => _openCategoryFilter(),
                                    backgroundColor: Colors.white,
                                    selectedColor: greenPrimary.withAlpha(50),
                                    labelStyle: TextStyle(
                                      color: _selectedCategories.isNotEmpty ? greenPrimary : Colors.black,
                                      fontWeight: _selectedCategories.isNotEmpty ? FontWeight.bold : FontWeight.normal
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                                    showCheckmark: false,
                                  ),
                                ),

                                // Date filter
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FilterChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_selectedDate == null 
                                          ? "Дата" 
                                          : DateFormat('dd.MM').format(_selectedDate!)),
                                        
                                        if (_selectedDate == null) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.keyboard_arrow_down, size: 18),
                                        ]
                                      ],
                                    ),
                                    
                                    // Pick date on tap
                                    onSelected: (_) => _pickDate(context),

                                    // When delete icon is tapped, clear the selected date
                                    onDeleted: _selectedDate != null 
                                        ? () {
                                            setState(() {
                                              _selectedDate = null;
                                            });
                                          }
                                        : null,
                                    
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    deleteIconColor: greenPrimary, 

                                    selected: _selectedDate != null,
                                    backgroundColor: Colors.white,
                                    selectedColor: greenPrimary.withAlpha(51),
                                    labelStyle: TextStyle(
                                      color: _selectedDate != null ? greenPrimary : Colors.black,
                                      fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                                    showCheckmark: false,
                                  ),
                                ),

                                // Saved Filter
                                FilterChip(
                                  label: const Text("Запазени"),
                                  avatar: Icon(
                                    _showSavedOnly ? Icons.bookmark : Icons.bookmark_border, 
                                    color: _showSavedOnly ? greenPrimary : Colors.grey,
                                    size: 20,
                                  ),
                                  selected: _showSavedOnly,
                                  onSelected: (val) {
                                    setState(() {
                                      _showSavedOnly = val;
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: greenPrimary.withAlpha(30),
                                  labelStyle: TextStyle(
                                    color: _showSavedOnly ? greenPrimary : Colors.black,
                                    fontWeight: _showSavedOnly ? FontWeight.bold : FontWeight.normal
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                                  showCheckmark: false,
                                ),
                              ]
                            )
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
            );
          }
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