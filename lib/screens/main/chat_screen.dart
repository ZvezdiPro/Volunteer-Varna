import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/shared/colors.dart';

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
  final TextEditingController _messageController = TextEditingController();

  // This function creates the 'messages' sub-collection automatically
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Reference to the specific campaign document
      final campaignRef = FirebaseFirestore.instance
          .collection('campaigns')
          .doc(widget.campaign.id);

      // Add a new document to the 'messages' sub-collection
      await campaignRef.collection('messages').add({
        'text': messageText,
        'senderId': widget.currentUser.uid,
        'senderName': widget.currentUser.firstName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensure the layout moves up when the keyboard opens
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(
        title: Text(widget.campaign.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
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
                  return const Center(child: Text("Say hello!"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgData = messages[index].data() as Map<String, dynamic>;
                    final isMe = msgData['senderId'] == widget.currentUser.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe ? greenPrimary : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                msgData['senderName'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: Colors.grey[800], 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            Text(
                              msgData['text'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: greenPrimary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}