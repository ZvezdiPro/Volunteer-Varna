import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:volunteer_app/screens/main/helper_screens/video_player_screen.dart';
import 'package:volunteer_app/shared/colors.dart';

// Main widget for displaying individual chat messages
class ChatBubble extends StatelessWidget {
  final String message;
  final String? fileUrl;
  final String type;
  final String? fileName;
  final String? fileSize;
  final bool isMe;
  final String senderName;
  final DateTime timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    this.fileUrl,
    required this.type,
    this.fileName,
    this.fileSize,
    required this.isMe,
    required this.senderName,
    required this.timestamp,
  });

  // Opens links found within the text message
  Future<void> _onOpenLink(LinkableElement link) async {
    final Uri url = Uri.parse(link.url);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Custom border radius to distinguish sender vs receiver
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
      bottomRight: isMe ? Radius.zero : const Radius.circular(16),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? greenPrimary : Colors.white,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Renders different content based on the message type
            if (type == 'video' && fileUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: VideoThumbnailPlaceholder(videoUrl: fileUrl!),
              )
            else if (type == 'image' && fileUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  fileUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 150,
                    child: Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              )
            else if (type == 'file' && fileUrl != null)
              FileBubble(
                fileName: fileName ?? 'Document',
                fileSize: fileSize ?? '',
                fileUrl: fileUrl!,
                isMe: isMe,
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Displays sender name for received messages
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  
                  // Text message with clickable links
                  if (message.isNotEmpty)
                    Linkify(
                      onOpen: _onOpenLink,
                      text: message,
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                      linkStyle: TextStyle(
                        color: isMe ? Colors.white : Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),

                  const SizedBox(height: 4),
                  // Message timestamp
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying file attachments
class FileBubble extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String fileUrl;
  final bool isMe;

  const FileBubble({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileUrl,
    required this.isMe,
  });

  // Opens the file URL in an external application
  Future<void> _openFile() async {
    final Uri url = Uri.parse(fileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $fileUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openFile,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.black.withOpacity(0.1) : Colors.grey[100],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withOpacity(0.2) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insert_drive_file,
                color: isMe ? Colors.white : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.white : Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileSize,
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder widget for video messages
class VideoThumbnailPlaceholder extends StatelessWidget {
  final String videoUrl;

  const VideoThumbnailPlaceholder({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Navigates to the video player screen on tap
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(videoUrl: videoUrl),
          ),
        );
      },
      child: Container(
        height: 160,
        width: double.infinity,
        color: Colors.black87,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 50),
            Positioned(
              bottom: 10,
              child: Text(
                "Video",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Widget to display date separators between messages
class DateChip extends StatelessWidget {
  final DateTime date;
  const DateChip({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black54
            ),
          ),
        ),
      ),
    );
  }

  // Formats the date string (Today, Yesterday, or specific date)
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0 && now.day == date.day) return "TODAY";
    if (difference == 1 || (difference == 0 && now.day != date.day)) return "YESTERDAY";
    return DateFormat('MMMM d, y').format(date);
  }
}