import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName; 
  final String? senderAvatarURL; 
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarURL,
    required this.text,
    required this.timestamp,
  });

  // Factory to create from Firestore
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'],
      senderName: data['senderName'],
      senderAvatarURL: data['senderAvatar'],
      text: data['text'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to convert to Map for sending to Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatarURL,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}