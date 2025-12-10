import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:volunteer_app/services/database.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/models/campaign_data.dart';
import 'package:volunteer_app/shared/constants.dart';


class CreateCampaignStepThree extends StatefulWidget {
  final CampaignData data;
  final GlobalKey<FormState> formKey;

  const CreateCampaignStepThree({
    super.key,
    required this.data,
    required this.formKey,
  });

  @override
  State<CreateCampaignStepThree> createState() => _CreateCampaignStepThreeState();
}

class _CreateCampaignStepThreeState extends State<CreateCampaignStepThree> {
  
  final GlobalKey<FormFieldState> _volunteerCountKey = GlobalKey<FormFieldState>();

  // State for image handling
  File? _displayImage; 
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Function to handle Picking and Uploading
  Future<void> _handleImageUpload() async {
    try {
      // 1. Pick Image
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return; // User cancelled

      setState(() {
        _isUploading = true;
        _displayImage = File(pickedFile.path); // Set local preview
      });

      // 2. Upload to Firebase Storage
      // We create a unique path folder so filenames don't collide
      // Path result: campaign_uploads/1689234000000/image.jpg
      String uniquePath = 'campaign_uploads/${DateTime.now().millisecondsSinceEpoch}';
      
      String? downloadUrl = await DatabaseService().uploadImage(uniquePath, pickedFile);

      // 3. Update Campaign Data
      if (downloadUrl != null) {
        setState(() {
          widget.data.imageUrl = downloadUrl;
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Снимката е качена успешно!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('Upload failed');
      }

    } catch (e) {
      setState(() {
        _isUploading = false;
        _displayImage = null; // Clear preview on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Грешка при качване: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 40.0, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form (
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Heading
            Text('Стъпка 3: Детайли', style: mainHeadingStyle, textAlign: TextAlign.center),
            SizedBox(height: 30.0),
            
            // Required Volunteers
            // TODO: Make it a field with increment/decrement buttons
            Text('Необходим брой доброволци', style: textFormFieldHeading),
            SizedBox(height: 10.0),
            TextFormField(
              key: _volunteerCountKey,
              decoration: textInputDecoration.copyWith(labelText: 'Брой доброволци', hintText: 'Въведете брой'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Моля, въведете брой доброволци';
                }
                if (int.tryParse(val) == null || int.parse(val) <= 0) {
                  return 'Моля, въведете валиден положителен брой';
                }
                return null;
              },
              onChanged: (val) {
                widget.data.requiredVolunteers = int.tryParse(val) ?? 0;
                _volunteerCountKey.currentState?.validate();
              },
            ),

            SizedBox(height: 20.0),

            // Instructions (optional)
            Text('Инструкции (опционално)', style: textFormFieldHeading),
            SizedBox(height: 10.0),
            TextFormField(
              decoration: textInputDecoration.copyWith(labelText: 'Допълнителни инструкции', hintText: 'Например: носете ръкавици и чували'),
              onChanged: (val) => widget.data.instructions = val,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),

            SizedBox(height: 20.0),

            // Upload image (optional)
            Text('Изображение за кампанията', style: textFormFieldHeading),
            SizedBox(height: 10.0),
            ElevatedButton.icon(
              icon: Icon(_isUploading ? Icons.timer : Icons.upload_file, color: Colors.white),
              label: Text(
                _isUploading ? 'Качване...' : (_displayImage == null ? 'Качете изображение' : 'Смени изображение'), 
                style: const TextStyle(color: Colors.white)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _isUploading ? null : _handleImageUpload, 
            ),
          ]
        ),
      )
    );
  }
}