import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';
import '../services/encryption_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatScreen({super.key, required this.receiverUserEmail, required this.receiverUserID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    String username = widget.receiverUserEmail.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF6A7175),
              child: Text(username.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverUserID, _auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF00A884)));

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isSender = (data['senderId'] == _auth.currentUser!.uid);
    bool isRead = data['isRead'] ?? false;
    String chatRoomId = _getChatRoomId(_auth.currentUser!.uid, widget.receiverUserID);

    if (!isSender && !isRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chatService.markMessageAsRead(chatRoomId, document.id);
      });
    }

    String decryptedMessage = EncryptionService.decryptMessage(data['message']);
    DateTime time = (data['timestamp'] as Timestamp).toDate();
    String formattedTime = DateFormat('HH:mm').format(time);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 8),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xFF005C4B) : const Color(0xFF202C33),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          alignment: WrapAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 2),
              child: Text(decryptedMessage, style: const TextStyle(fontSize: 15, color: Colors.white)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formattedTime, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
                if (isSender) const SizedBox(width: 4),
                if (isSender) Icon(isRead ? Icons.done_all : Icons.check, size: 14, color: isRead ? const Color(0xFF53BDEB) : Colors.white60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.white54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Сообщение',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00A884),
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          )
        ],
      ),
    );
  }
}