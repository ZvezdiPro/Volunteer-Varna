import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/services/database.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_app/shared/constants.dart';

class CampaignDetailsScreen extends StatelessWidget {

  final Campaign campaign;  
  const CampaignDetailsScreen({super.key, required this.campaign});

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEE, d MMM y, HH:mm', 'en_US');
    return formatter.format(date);
  }

  Widget _buildIconAndText(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Icon(icon, size: 20.0, color: color),
        SizedBox(width: 4.0),
        Flexible(
          child: Text(
            text, 
            style: TextStyle(fontSize: 18.0, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,

      // Button for registering for the campaign
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundGrey
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: greenPrimary, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 0,
              ),
              // When pressed, register the user for the campaign
              onPressed: () async {
                VolunteerUser? volunteer = Provider.of<VolunteerUser?>(context, listen: false)!;

                try {
                  DatabaseService(uid: volunteer.uid).registerUserForCampaign(campaign.id);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: greenPrimary,
                      content: Container(
                        alignment: Alignment.center,
                        height: 45,
                        child: Text('Успешно се записахте за кампанията!', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Container(
                        alignment: Alignment.center,
                        height: 45,
                        child: Text('Грешка при записването за кампанията. Моля, опитайте отново!', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },

              child: Text(
                'Запиши се за кампанията',
                style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),

      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Campaign image (if available)
                (campaign.imageUrl.isNotEmpty) ?
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                    ),
                    child: Image.network(
                      campaign.imageUrl,
                      height: 250.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        Container(
                          height: 250.0,
                          color: Colors.red[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 40.0, color: Colors.red),
                              SizedBox(height: 8.0),
                              Text('Грешка при зареждане на изображението', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                    ),
                  )
                :
                // Else build a something like an AppBar without a campaign image, just some text
                Container(
                  height: 100.0,
                  color: backgroundGrey,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.0, right: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Go back button
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.0),
                            onPressed: () => Navigator.pop(context),
                          ),
                      
                          // Heading text
                          Text(
                            'Детайли за кампанията',
                            style: appBarHeadingStyle,
                            textAlign: TextAlign.center
                          ),
                      
                          IconButton(
                            icon: Icon(Icons.bookmark_border, color: Colors.black, size: 24.0),
                            onPressed: () {
                              // TODO (low priority): Bookmark logic
                            },
                          ),
                        ]
                      ),
                    ),
                  ),
                ),
                
                // The campaign details
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campaign title
                      Text(
                        campaign.title,
                        style: mainHeadingStyle,
                      ),

                      SizedBox(height: 16.0),

                      // Campaign start DateTime
                      _buildIconAndText(Icons.calendar_today, 'Начало: ${_formatDate(campaign.startDate)}', blueSecondary),
                      SizedBox(height: 8.0),

                      // Campaign end DateTime
                      _buildIconAndText(Icons.calendar_today, 'Край: ${_formatDate(campaign.endDate)}', blueSecondary),
                      SizedBox(height: 8.0),

                      // Campaign location
                      _buildIconAndText(Icons.location_on, campaign.location, blueSecondary),
                      SizedBox(height: 8.0),

                      // Campaign required volunteers
                      _buildIconAndText(Icons.group, 'Записани са ${campaign.registeredVolunteersUids.length} от необходими ${campaign.requiredVolunteers}', blueSecondary),
                      SizedBox(height: 24.0),

                      // Campaign description
                      Text(
                        'Описание:',
                        style: TextStyle(fontSize: 18.0, color: Colors.grey[800], fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        campaign.description,
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),

                      SizedBox(height: 24.0),

                      // Additional instructions
                      if (campaign.instructions.isNotEmpty) ...[
                        Text(
                          'Допълнителни инструкции:',
                          style: TextStyle(fontSize: 18.0, color: Colors.grey[800], fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          campaign.instructions,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                        ),
                      ]
                    ],
                  ),
                ),
              ]
            )
          ),

          // Button to go back (only visible when there is an image)
          if (campaign.imageUrl.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea( 
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(150),
                      border: Border.all(color: Colors.grey.shade400, width: 2.0),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.0),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(4.0),
                    ),
                  ),
                ),
              ),
            ),

          // Button to bookmark the campaign (only visible when there is an image)
          if (campaign.imageUrl.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea( 
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(150),
                      border: Border.all(color: Colors.grey.shade400, width: 2.0),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.bookmark_border, color: Colors.white, size: 24.0),
                      onPressed: () {
                        // TODO (low priority): Bookmark logic
                      }
                    )
                  )
                )
              )
            )
        ]
      )
    );
  }

}