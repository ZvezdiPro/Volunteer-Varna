import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Send Message
  Future<void> sendMessage(String campaignId, VolunteerUser currentUser, String messageText) async {
    if (messageText.trim().isEmpty) return;

    // Add message to 'messages' sub-collection under the specific campaign
    await _db
        .collection('campaigns')
        .doc(campaignId)
        .collection('messages') // Subcollection strategy
        .add({
      'senderId': currentUser.uid,
      'senderName': '${currentUser.firstName} ${currentUser.lastName}',
      'senderAvatar': currentUser.avatarUrl,
      'text': messageText.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get Messages Stream
  Stream<List<ChatMessage>> getMessages(String campaignId) {
    
    // Listen to 'messages' sub-collection under the specific campaign
    return _db
        .collection('campaigns')
        .doc(campaignId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }
}