import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/services/database.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_app/shared/constants.dart';
import 'package:volunteer_app/shared/loading.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final Campaign campaign;
  final bool showRegisterButton;

  const CampaignDetailsScreen({
    super.key, 
    required this.campaign, 
    this.showRegisterButton = true
  });

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEE, d MMM y, HH:mm', 'bg_BG');
    return formatter.format(date);
  }

  Widget _buildIconAndText(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Icon(icon, size: 20.0, color: color),
        const SizedBox(width: 4.0),
        Flexible(
          child: Text(
            text, 
            style: const TextStyle(fontSize: 18.0, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _onBookmarkTap(BuildContext context, VolunteerUser? user, bool currentStatus) async {
    if (user == null) return;

    bool newStatus = !currentStatus;
    String message = newStatus ? 'Добавено в запазени кампании' : 'Премахнато от запазени кампании';
    
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text(message, style: TextStyle(fontWeight: FontWeight.bold))),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: greenPrimary,
        )
      );
    }

    // Update in the database
    try {
      await DatabaseService(uid: user.uid).toggleCampaignBookmark(widget.campaign.id, currentStatus);
    } catch (e) {
      print("Error bookmarking: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Center(child: Text('Грешка при свързване с базата данни.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<VolunteerUser?>(context);

    if (authUser == null) {
      return const Scaffold(body: Center(child: Loading()));
    }

    return StreamBuilder<VolunteerUser?>(
      stream: DatabaseService(uid: authUser.uid).volunteerUserData,
      builder: (context, snapshot) {
        VolunteerUser? user = snapshot.data ?? authUser;
        bool isBookmarked = user.bookmarkedCampaignsIds.contains(widget.campaign.id);
        return Scaffold(
      backgroundColor: backgroundGrey,

      // Button for registering
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          decoration: const BoxDecoration(color: backgroundGrey),
          child: Builder(
            builder: (context) {
              bool isAlreadyRegistered = widget.campaign.registeredVolunteersUids.contains(user.uid);

              if (!widget.showRegisterButton) return const SizedBox.shrink();

              return SizedBox(
                height: 50.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAlreadyRegistered ? Colors.grey[400] : greenPrimary, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0,
                  ),

                  onPressed: isAlreadyRegistered ? null : () async {
                    try {
                      await DatabaseService(uid: user.uid).registerUserForCampaign(widget.campaign.id);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: greenPrimary,
                            content: Center(child: Text('Успешно се записахте за кампанията!', style: TextStyle(fontWeight: FontWeight.bold))),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: Colors.red, content: Center(child: Text('Грешка при записване!'))),
                        );
                      }
                    }
                  },
                  
                  child: Text(
                    isAlreadyRegistered ? 'Вече сте записан за кампанията' : 'Запиши се за кампанията',
                    style: TextStyle(
                      fontSize: 16.0, 
                      color: isAlreadyRegistered ? Colors.black : Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              );
            },
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
                (widget.campaign.imageUrl.isNotEmpty) ?
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12.0),
                      bottomRight: Radius.circular(12.0),
                    ),
                    child: Image.network(
                      widget.campaign.imageUrl,
                      height: 250.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        Container(
                          height: 250.0,
                          color: Colors.red[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.error_outline, size: 40.0, color: Colors.red),
                              SizedBox(height: 8.0),
                              Text('Грешка при зареждане на изображението', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                    ),
                  )
                :
                // Header without image
                Container(
                  height: 100.0,
                  color: backgroundGrey,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24.0),
                            onPressed: () => Navigator.pop(context),
                          ),
                      
                          const Text(
                            'Детайли за кампанията',
                            style: appBarHeadingStyle,
                            textAlign: TextAlign.center
                          ),
                      
                          IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border, 
                              color: Colors.black,
                              size: 24.0
                            ),
                            onPressed: () => _onBookmarkTap(context, user, isBookmarked),
                          ),
                        ]
                      ),
                    ),
                  ),
                ),
                
                // Campaign details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.campaign.title,
                        style: mainHeadingStyle,
                      ),

                      const SizedBox(height: 16.0),
                      _buildIconAndText(Icons.calendar_today, 'Начало: ${_formatDate(widget.campaign.startDate)}', blueSecondary),
                      const SizedBox(height: 8.0),
                      _buildIconAndText(Icons.calendar_today, 'Край: ${_formatDate(widget.campaign.endDate)}', blueSecondary),
                      const SizedBox(height: 8.0),
                      _buildIconAndText(Icons.location_on, widget.campaign.location, blueSecondary),
                      const SizedBox(height: 8.0),
                      _buildIconAndText(Icons.group, 'Записани са ${widget.campaign.registeredVolunteersUids.length} от необходими ${widget.campaign.requiredVolunteers}', blueSecondary),
                      const SizedBox(height: 24.0),

                      Text(
                        'Описание:',
                        style: TextStyle(fontSize: 18.0, color: Colors.grey[800], fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        widget.campaign.description,
                        style: const TextStyle(fontSize: 16.0, color: Colors.black),
                      ),

                      const SizedBox(height: 24.0),

                      if (widget.campaign.instructions.isNotEmpty) ...[
                        Text(
                          'Допълнителни инструкции:',
                          style: TextStyle(fontSize: 18.0, color: Colors.grey[800], fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          widget.campaign.instructions,
                          style: const TextStyle(fontSize: 16.0, color: Colors.black),
                        ),
                      ]
                    ],
                  ),
                ),
              ]
            )
          ),

          // Back button (Image mode)
          if (widget.campaign.imageUrl.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea( 
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(150),
                      border: Border.all(color: Colors.grey.shade400, width: 2.0),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24.0),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(4.0),
                    ),
                  ),
                ),
              ),
            ),

          // Bookmark button (Image mode)
          if (widget.campaign.imageUrl.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea( 
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(150),
                      border: Border.all(color: Colors.grey.shade400, width: 2.0),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border, 
                        color: Colors.white, 
                        size: 24.0
                      ),
                      onPressed: () => _onBookmarkTap(context, user, isBookmarked),
                    )
                  )
                )
              )
            )
        ]
      )
    );
  });
    
  }
}