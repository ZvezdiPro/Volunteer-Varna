import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/widgets/chat_bubbles.dart';

// Screen responsible for handling campaign-specific chat interactions
class CampaignChatScreen extends StatefulWidget {
  final Campaign campaign;
  final VolunteerUser currentUser;

  const CampaignChatScreen({
    super.key,
    required this.campaign,
    required this.currentUser,
  });

  @override
  State<CampaignChatScreen> createState() => _CampaignChatScreenState();
}

class _CampaignChatScreenState extends State<CampaignChatScreen> {
  // Controller for the text input field
  final TextEditingController _messageController = TextEditingController();
  // Image picker instance for selecting media
  final ImagePicker _picker = ImagePicker();
  // State to track upload progress
  bool _isUploading = false;

  // Utility method to convert file bytes into a human-readable string
  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // Handles sending messages (text, image, video, or file) to Firestore
  void _sendMessage({
    String? text,
    String? fileUrl,
    String type = 'text',
    String? fileName,
    String? fileSize,
  }) async {
    // prevent sending empty messages
    if ((text == null || text.trim().isEmpty) && fileUrl == null) return;
    
    // Clear the input field immediately for better UX
    if (text != null) _messageController.clear();

    try {
      // Add the message object to the specific campaign's subcollection
      await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(widget.campaign.id)
          .collection('messages')
          .add({
        'text': text ?? '',
        'fileUrl': fileUrl ?? '',
        'type': type,
        'fileName': fileName ?? '',
        'fileSize': fileSize ?? '',
        'senderId': widget.currentUser.uid,
        'senderName': widget.currentUser.firstName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // Handles picking images or videos from the gallery or camera and uploading them
  Future<void> _pickAndUploadMedia(ImageSource source, {bool isVideo = false}) async {
    try {
      // Select the file based on whether it is a video or an image
      final XFile? file = isVideo 
          ? await _picker.pickVideo(source: source, maxDuration: const Duration(minutes: 5))
          : await _picker.pickImage(source: source, imageQuality: 70);
      
      // User canceled the picker
      if (file == null) return;

      setState(() => _isUploading = true);

      // Prepare file metadata and storage path
      String ext = isVideo ? 'mp4' : 'jpg';
      String folder = isVideo ? 'chat_videos' : 'chat_images';
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('$folder/${widget.campaign.id}/$fileName');

      // Upload file to Firebase Storage
      await storageRef.putFile(File(file.path));
      String downloadUrl = await storageRef.getDownloadURL();

      // Send the message with the generated download URL
      _sendMessage(fileUrl: downloadUrl, type: isVideo ? 'video' : 'image');

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // Handles picking generic files from the device storage
  Future<void> _pickAndUploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);

        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        String fileSize = _formatBytes(result.files.single.size, 1);

        // Upload file to the specific chat files folder
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_files/${widget.campaign.id}/$fileName');

        await storageRef.putFile(file);
        String downloadUrl = await storageRef.getDownloadURL();

        // Send message with file metadata
        _sendMessage(
          fileUrl: downloadUrl,
          type: 'file',
          fileName: fileName,
          fileSize: fileSize,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // Displays a bottom sheet with options to attach different media types
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _AttachmentOption(
              icon: Icons.camera_alt,
              label: "Camera",
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadMedia(ImageSource.camera);
              }
            ),
            _AttachmentOption(
              icon: Icons.image,
              label: "Gallery",
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadMedia(ImageSource.gallery);
              }
            ),
            _AttachmentOption(
              icon: Icons.videocam,
              label: "Video",
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadMedia(ImageSource.gallery, isVideo: true);
              }
            ),
            _AttachmentOption(
              icon: Icons.insert_drive_file,
              label: "File",
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadFile();
              }
            ),
          ],
        ),
      ),
    );
  }

  // Logic to determine if a date separator should be shown between messages
  bool _shouldShowDate(List<QueryDocumentSnapshot> docs, int index) {
    // Always show date for the very first message (last in list)
    if (index == docs.length - 1) return true;
    
    final currentMsgTime = (docs[index]['timestamp'] as Timestamp?)?.toDate();
    final previousMsgTime = (docs[index + 1]['timestamp'] as Timestamp?)?.toDate();
    
    if (currentMsgTime == null || previousMsgTime == null) return false;

    // Check if the day, month, or year has changed
    return currentMsgTime.day != previousMsgTime.day || 
           currentMsgTime.month != previousMsgTime.month || 
           currentMsgTime.year != previousMsgTime.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text(widget.campaign.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            // Listen to real-time updates from the messages collection
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('campaigns')
                  .doc(widget.campaign.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("Start the conversation!", style: TextStyle(color: Colors.grey[400])),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Start from the bottom
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == widget.currentUser.uid;
                    
                    // Extract message data safely
                    final String? fileUrl = data['fileUrl'] ?? data['imageUrl'];
                    final String type = data['type'] ?? (data['imageUrl'] != null ? 'image' : 'text');
                    final String? fileName = data['fileName'];
                    final String? fileSize = data['fileSize'];

                    return Column(
                      children: [
                        // Show date separator if the day has changed
                        if (_shouldShowDate(docs, index))
                           DateChip(date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now()),
                        
                        // Render the actual chat bubble
                        ChatBubble(
                          message: data['text'] ?? '',
                          fileUrl: fileUrl,
                          type: type,
                          fileName: fileName,
                          fileSize: fileSize,
                          isMe: isMe,
                          senderName: data['senderName'] ?? 'User',
                          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          
          // Show progress indicator when uploading files
          if (_isUploading) const LinearProgressIndicator(minHeight: 2, color: greenPrimary),

          // Input area at the bottom
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 28),
                    onPressed: _showAttachmentOptions,
                  ),
                  
                  // Text input field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!)
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  // Send button
                  GestureDetector(
                    onTap: () => _sendMessage(text: _messageController.text.trim()),
                    child: const CircleAvatar(
                      backgroundColor: greenPrimary,
                      radius: 22,
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for rendering individual attachment options in the bottom sheet
class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}