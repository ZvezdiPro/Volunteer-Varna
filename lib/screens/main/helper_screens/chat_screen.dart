import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart'; 
import 'package:share_plus/share_plus.dart';
import 'package:volunteer_app/models/campaign.dart';
import 'package:volunteer_app/models/volunteer.dart';
import 'package:volunteer_app/shared/colors.dart';
import 'package:volunteer_app/widgets/chat_bubbles.dart';

// --- ОСНОВЕН ЕКРАН ---
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
  // State variables
  Map<String, String>? _replyMessage;
  bool _isUploading = false;
  bool _isSharing = false; 

  // --- ПРОВЕРКА ЗА ПРАВА ---
  bool get _isOrganizer => widget.campaign.organizerId == widget.currentUser.uid;

  // --- HELPER FUNCTIONS ---
  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 Б";
    const suffixes = ["Б", "КБ", "МБ", "ГБ", "ТБ"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // --- SAVE / DOWNLOAD LOGIC (НОВО) ---
  Future<void> _downloadAndSaveFile(String fileUrl, String? fileName, String type) async {
    if (fileUrl.isEmpty) return;

    try {
      setState(() => _isSharing = true); // Използваме същия лоудър

      // 1. Ако е iOS -> Използваме Share менюто, защото iOS не позволява директен запис лесно
      if (Platform.isIOS) {
        await _shareMessageContent(null, fileUrl, type);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Изберете 'Save to Files' или 'Save Image' от менюто.")));
        }
        return;
      }

      // 2. Логика за ANDROID
      if (Platform.isAndroid) {
        // Проверка на правата (за по-стари Андроиди)
        final plugin = DeviceInfoPlugin();
        final androidInfo = await plugin.androidInfo;
        
        // Ако е под Android 10 (SDK 29), искаме разрешение. За по-новите не е нужно за Download папката.
        if (androidInfo.version.sdkInt < 29) {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
            if (!status.isGranted) {
              throw Exception("Няма права за запис.");
            }
          }
        }

        // Сваляне на байтовете
        final http.Response response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode != 200) throw Exception("Грешка при сваляне.");

        // Определяне на името
        String finalName = fileName ?? "file_${DateTime.now().millisecondsSinceEpoch}";
        // Добавяме разширение, ако липсва
        if (!finalName.contains('.')) {
          if (type == 'image') finalName += ".jpg";
          else if (type == 'video') finalName += ".mp4";
          else if (type == 'audio') finalName += ".m4a";
          else finalName += ".bin";
        }

        // Път към публичната папка Downloads
        // Забележка: /storage/emulated/0/Download/ е стандартният път за повечето Android устройства
        final Directory downloadDir = Directory('/storage/emulated/0/Download/VolunteerApp');
        
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final File file = File('${downloadDir.path}/$finalName');
        
        // Уникално име, ако файлът съществува
        String uniquePath = file.path;
        int counter = 1;
        while (await File(uniquePath).exists()) {
           uniquePath = '${downloadDir.path}/(${counter++})_$finalName';
        }

        // Записване
        await File(uniquePath).writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Запазено в Downloads/VolunteerApp"),
              backgroundColor: Colors.green,
            )
          );
        }
      }
    } catch (e) {
      debugPrint("Save Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Грешка при запазване: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // --- PIN MESSAGE LOGIC ---
  Future<void> _pinMessage(String messageId, String text, String type) async {
    if (!_isOrganizer) return;
    try {
      await FirebaseFirestore.instance.collection('campaigns').doc(widget.campaign.id).update({
        'pinnedMessage': {
          'id': messageId,
          'text': text,
          'type': type,
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Съобщението е закачено!")));
    } catch (e) {
      debugPrint("Pin Error: $e");
    }
  }

  Future<void> _unpinMessage() async {
    if (!_isOrganizer) return;
    try {
      await FirebaseFirestore.instance.collection('campaigns').doc(widget.campaign.id).update({
        'pinnedMessage': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint("Unpin Error: $e");
    }
  }

  // --- SEND LOGIC ---
  void _handleSendText(String text) {
    _sendMessage(text: text);
  }

  void _handleSendAudio(String path) async {
    await _uploadAndSend(File(path), 'chat_audio', 'audio', 'm4a');
  }

  Future<void> _uploadAndSend(File file, String folder, String type, String ext) async {
    setState(() => _isUploading = true);
    try {
      String fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";
      Reference storageRef = FirebaseStorage.instance.ref().child('$folder/${widget.campaign.id}/$fileName');
      
      await storageRef.putFile(file);
      String downloadUrl = await storageRef.getDownloadURL();

      _sendMessage(
        fileUrl: downloadUrl,
        type: type,
        fileName: type == 'file' ? file.path.split('/').last : null,
      );
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Грешка при качване: $e")));
    } finally {
      if(mounted) setState(() => _isUploading = false);
    }
  }

  void _sendMessage({
    String? text,
    String? fileUrl,
    String type = 'text',
    String? fileName,
    String? fileSize,
    String? contactName,
    String? contactPhone,
  }) async {
    final replyData = _replyMessage;
    if (_replyMessage != null) {
      setState(() {
        _replyMessage = null;
      });
    }

    try {
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
        'contactName': contactName ?? '',
        'contactPhone': contactPhone ?? '',
        'senderId': widget.currentUser.uid,
        'senderName': widget.currentUser.firstName,
        'timestamp': FieldValue.serverTimestamp(),
        'reactions': {},
        'replyToName': replyData?['name'],
        'replyToText': replyData?['text'],
        'replyToId': replyData?['id'],
      });
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  // --- ATTACHMENTS HANDLING ---
  void _handleAttachment(String type) async {
    final ImagePicker picker = ImagePicker();
    try {
      if (type == 'gallery') {
         final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
         if (image != null) _uploadAndSend(File(image.path), 'chat_images', 'image', 'jpg');
      } else if (type == 'video') {
         final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
         if (video != null) _uploadAndSend(File(video.path), 'chat_videos', 'video', 'mp4');
      } else if (type == 'file') {
         FilePickerResult? result = await FilePicker.platform.pickFiles();
         if (result != null && result.files.single.path != null) {
            File file = File(result.files.single.path!);
            String size = _formatBytes(result.files.single.size, 1);
            
            setState(() => _isUploading = true);
            Reference ref = FirebaseStorage.instance.ref().child('chat_files/${widget.campaign.id}/${result.files.single.name}');
            await ref.putFile(file);
            String url = await ref.getDownloadURL();
            _sendMessage(fileUrl: url, type: 'file', fileName: result.files.single.name, fileSize: size);
            setState(() => _isUploading = false);
         }
      } else if (type == 'contact') {
        if (await FlutterContacts.requestPermission(readonly: true)) {
          final Contact? contact = await FlutterContacts.openExternalPick();
          if (contact != null && contact.phones.isNotEmpty) {
            _sendMessage(type: 'contact', contactName: contact.displayName, contactPhone: contact.phones.first.number);
          }
        }
      }
    } catch (e) {
      if(mounted) setState(() => _isUploading = false);
    }
  }

  // --- SHARE LOGIC ---
  Future<void> _shareMessageContent(String? text, String? fileUrl, String type) async {
    if ((fileUrl == null || fileUrl.isEmpty) && text != null && text.isNotEmpty) {
      await Share.share(text);
      return;
    }

    if (fileUrl != null && fileUrl.isNotEmpty) {
      try {
        setState(() => _isSharing = true);

        final http.Response response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode != 200) throw Exception("Грешка при сваляне");

        final Directory tempDir = await getTemporaryDirectory();
        
        String extension = 'bin';
        String mimeType = '*/*';

        if (type == 'image') { extension = 'jpg'; mimeType = 'image/jpeg'; }
        else if (type == 'video') { extension = 'mp4'; mimeType = 'video/mp4'; }
        else if (type == 'audio') { extension = 'm4a'; mimeType = 'audio/mp4'; }
        else if (type == 'file') {
          if (fileUrl.toLowerCase().contains('.pdf')) { extension = 'pdf'; mimeType = 'application/pdf'; }
          else { extension = 'file'; }
        }

        final String cleanFileName = 'share_${DateTime.now().millisecondsSinceEpoch}.$extension';
        final File file = File('${tempDir.path}/$cleanFileName');
        
        await file.writeAsBytes(response.bodyBytes);

        if (!await file.exists()) throw Exception("File write failed");

        final XFile xFile = XFile(file.path, mimeType: mimeType);
        
        await Future.delayed(const Duration(milliseconds: 100));
        await Share.shareXFiles([xFile], text: (text != null && text.isNotEmpty) ? text : null);

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Неуспешно споделяне на файл.")));
        }
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
    }
  }

  // --- MESSAGE ACTIONS ---
  Future<void> _toggleReaction(String docId, String emoji, Map<String, dynamic> currentReactions) async {
    final uid = widget.currentUser.uid;
    final docRef = FirebaseFirestore.instance.collection('campaigns').doc(widget.campaign.id).collection('messages').doc(docId);
    if (currentReactions[uid] == emoji) {
       await docRef.update({'reactions.$uid': FieldValue.delete()});
    } else {
       await docRef.update({'reactions.$uid': emoji});
    }
  }

  // МЕНЮ ПРИ ЗАДЪРЖАНЕ (ОБНОВЕНО С SAVE)
  void _handleMessageLongPress(String docId, bool isMe, String messageText, String senderName, String? fileUrl, String type, Map<String, dynamic> currentReactions, String? fileName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ["👍", "❤️", "😂", "😮", "😢", "🙏"].map((emoji) {
                    return GestureDetector(
                      onTap: () { Navigator.pop(context); _toggleReaction(docId, emoji, currentReactions); },
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),
              
              // БУТОН ОТГОВОРИ
              ListTile(
                leading: const Icon(Icons.reply, color: Colors.blue),
                title: const Text('Отговори'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyMessage = {'id': docId, 'name': senderName, 'text': messageText.isEmpty ? (type == 'text' ? '' : 'Медия') : messageText};
                  });
                },
              ),

              // БУТОН ЗАПАЗИ (НОВО)
              if (fileUrl != null && fileUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: Colors.purple),
                  title: const Text('Запази в устройството'),
                  onTap: () {
                    Navigator.pop(context);
                    // Извикваме новата функция за запазване
                    _downloadAndSaveFile(fileUrl, fileName, type);
                  },
                ),

              // БУТОН СПОДЕЛИ
              ListTile(
                leading: const Icon(Icons.share, color: Colors.green),
                title: const Text('Сподели / Препрати'),
                onTap: () {
                  Navigator.pop(context);
                  String contentToShare = messageText;
                  if (type == 'contact') contentToShare = "$messageText"; 
                  _shareMessageContent(contentToShare, fileUrl, type);
                },
              ),

              // БУТОН ЗАКАЧИ (САМО ОРГ)
              if (_isOrganizer)
                ListTile(
                  leading: const Icon(Icons.push_pin, color: Colors.orange),
                  title: const Text('Закачи съобщение'),
                  onTap: () {
                    Navigator.pop(context);
                    String pinText = messageText;
                    if (pinText.isEmpty) {
                      if (type == 'image') pinText = '📷 Снимка';
                      else if (type == 'audio') pinText = '🎤 Гласово съобщение';
                      else if (type == 'video') pinText = '🎥 Видео';
                      else if (type == 'file') pinText = '📄 Файл';
                      else if (type == 'contact') pinText = '👤 Контакт';
                    }
                    _pinMessage(docId, pinText, type);
                  },
                ),

              if (messageText.isNotEmpty && type == 'text')
                ListTile(
                  leading: const Icon(Icons.copy, color: Colors.grey),
                  title: const Text('Копирай текста'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: messageText));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Копирано!")));
                  },
                ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Изтрий', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    FirebaseFirestore.instance.collection('campaigns').doc(widget.campaign.id).collection('messages').doc(docId).delete();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowDate(List<QueryDocumentSnapshot> docs, int index) {
    if (index == docs.length - 1) return true;
    final currentMsgTime = (docs[index]['timestamp'] as Timestamp?)?.toDate();
    final previousMsgTime = (docs[index + 1]['timestamp'] as Timestamp?)?.toDate();
    if (currentMsgTime == null || previousMsgTime == null) return false;
    return currentMsgTime.day != previousMsgTime.day;
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
      body: Stack(
        children: [
          Column(
            children: [
              
              // --- ЛЕНТА ЗА ЗАКАЧЕНО СЪОБЩЕНИЕ ---
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('campaigns').doc(widget.campaign.id).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
                  
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data == null || !data.containsKey('pinnedMessage')) return const SizedBox.shrink();
                  
                  final pinned = data['pinnedMessage'] as Map<String, dynamic>;
                  final String text = pinned['text'] ?? '';

                  return Container(
                    width: double.infinity,
                    color: Colors.amber.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.push_pin, size: 18, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Закачено съобщение", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 11)),
                              Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            ],
                          ),
                        ),
                        if (_isOrganizer)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.black54),
                            onPressed: _unpinMessage,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  );
                },
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('campaigns')
                      .doc(widget.campaign.id)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("Започнете разговора!", style: TextStyle(color: Colors.grey[400])));

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final isMe = data['senderId'] == widget.currentUser.uid;
                        final String? fileUrl = data['fileUrl'] ?? data['imageUrl'];
                        final String type = data['type'] ?? (data['imageUrl'] != null ? 'image' : 'text');
                        
                        String msgContent = data['text'] ?? '';
                        if (type == 'contact') {
                           msgContent = "${data['contactName']} (${data['contactPhone']})";
                        }

                        Map<String, dynamic> reactions = data['reactions'] != null ? Map<String, dynamic>.from(data['reactions']) : {};

                        return Column(
                          children: [
                            if (_shouldShowDate(docs, index))
                               DateChip(date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now()),
                            ChatBubble(
                              message: data['text'] ?? '',
                              fileUrl: fileUrl,
                              type: type,
                              fileName: data['fileName'],
                              fileSize: data['fileSize'],
                              contactName: data['contactName'],
                              contactPhone: data['contactPhone'],
                              duration: data['duration'],
                              isMe: isMe,
                              senderName: data['senderName'] ?? 'Потребител',
                              timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
                              reactions: reactions,
                              replyToName: data['replyToName'],
                              replyToText: data['replyToText'],
                              onLongPress: () => _handleMessageLongPress(
                                docs[index].id, 
                                isMe, 
                                msgContent, 
                                data['senderName'] ?? '',
                                fileUrl,
                                type,
                                reactions,
                                data['fileName'] // Подаваме името на файла за Save функцията
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              
              if (_isUploading) const LinearProgressIndicator(minHeight: 2, color: greenPrimary),

              if (_replyMessage != null)
                 Container(
                   color: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: greenPrimary, width: 4))),
                      child: Row(children: [
                        const Icon(Icons.reply, color: greenPrimary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("Отговор на ${_replyMessage!['name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: greenPrimary)),
                          Text(_replyMessage!['text']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54))
                        ])),
                        IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: () => setState(() => _replyMessage = null))
                      ]),
                   ),
                 ),

              ChatInputArea(
                onSendText: _handleSendText,
                onSendAudio: _handleSendAudio,
                onAttachmentTap: _handleAttachment,
              ),
            ],
          ),

          if (_isSharing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text("Обработка...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}

// --- WIDGET ЗА ВЪВЕЖДАНЕ (Без промяна) ---
class ChatInputArea extends StatefulWidget {
  final Function(String) onSendText;
  final Function(String) onSendAudio;
  final Function(String) onAttachmentTap;

  const ChatInputArea({
    super.key,
    required this.onSendText,
    required this.onSendAudio,
    required this.onAttachmentTap,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final TextEditingController _controller = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  bool _showSendButton = false;
  bool _isRecording = false;

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() => _isRecording = true);
        HapticFeedback.mediumImpact();
      } else {
        await Permission.microphone.request();
      }
    } catch (e) {
      debugPrint("Rec Error: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final String? path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        widget.onSendAudio(path); 
      }
    } catch (e) {
      debugPrint("Stop Error: $e");
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachmentOption(icon: Icons.image, label: "Галерия", color: Colors.blue, onTap: () { Navigator.pop(ctx); widget.onAttachmentTap('gallery'); }),
              _AttachmentOption(icon: Icons.videocam, label: "Видео", color: Colors.red, onTap: () { Navigator.pop(ctx); widget.onAttachmentTap('video'); }),
              _AttachmentOption(icon: Icons.insert_drive_file, label: "Файл", color: Colors.orange, onTap: () { Navigator.pop(ctx); widget.onAttachmentTap('file'); }),
              _AttachmentOption(icon: Icons.person, label: "Контакт", color: Colors.purple, onTap: () { Navigator.pop(ctx); widget.onAttachmentTap('contact'); }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8), 
      color: Colors.white,
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
             AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: _isRecording ? 0 : 48,
                  child: !_isRecording 
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.grey, size: 28),
                          onPressed: _showAttachmentOptions,
                        ),
                      )
                    : null,
                ),
              ),

              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _isRecording ? Colors.red : Colors.grey[300]!)
                  ),
                  child: _isRecording
                      ? const SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              Icon(Icons.fiber_manual_record, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              DefaultTextStyle(
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                                child: Text("Записване..."),
                              ),
                            ],
                          ),
                        )
                      : TextField(
                          controller: _controller,
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (text) {
                            final shouldShow = text.trim().isNotEmpty;
                            if (_showSendButton != shouldShow) {
                              setState(() {
                                _showSendButton = shouldShow;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "Напишете съобщение...",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 8),

              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GestureDetector(
                  onTap: _showSendButton 
                    ? () {
                        widget.onSendText(_controller.text.trim());
                        _controller.clear();
                        setState(() => _showSendButton = false);
                      }
                    : null,
                  
                  onLongPressStart: !_showSendButton ? (_) => _startRecording() : null,
                  onLongPressEnd: !_showSendButton ? (_) => _stopRecording() : null,

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : greenPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(color: (_isRecording ? Colors.red : greenPrimary).withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))
                      ]
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _showSendButton ? Icons.send_rounded : Icons.mic,
                          key: ValueKey(_showSendButton),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachmentOption({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 25, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 28)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))]));
  }
}