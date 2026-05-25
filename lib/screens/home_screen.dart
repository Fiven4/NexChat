import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';
import '../services/chat_service.dart';
import '../services/encryption_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String searchQuery = "";
  bool _isSearching = false;

  void logout() {
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Поиск...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
        )
            : const Text('Чаты'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                searchQuery = "";
              });
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: logout),
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF00A884)));
        return ListView.separated(
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const Divider(color: Color(0xFF1F2C34), height: 1, indent: 76),
          itemBuilder: (context, index) {
            return _buildUserListItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (_auth.currentUser!.email == data['email']) return const SizedBox.shrink();
    if (searchQuery.isNotEmpty && !data['email'].toString().toLowerCase().contains(searchQuery)) return const SizedBox.shrink();

    String username = data['email'].toString().split('@')[0];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF6A7175),
        child: Text(username.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
      title: Text(username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
      subtitle: _buildLastMessage(data['uid']),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(receiverUserEmail: data['email'], receiverUserID: data['uid'])));
      },
    );
  }

  Widget _buildLastMessage(String receiverId) {
    return StreamBuilder<QuerySnapshot>(
      stream: ChatService().getLastMessage(_auth.currentUser!.uid, receiverId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text('Нет сообщений', style: TextStyle(color: Colors.white38));

        var doc = snapshot.data!.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String decryptedMsg = EncryptionService.decryptMessage(data['message']);
        bool isMine = data['senderId'] == _auth.currentUser!.uid;
        bool isRead = data['isRead'] ?? false;
        DateTime time = (data['timestamp'] as Timestamp).toDate();
        String formattedTime = DateFormat('HH:mm').format(time);

        return Row(
          children: [
            if (isMine) Icon(isRead ? Icons.done_all : Icons.check, size: 16, color: isRead ? const Color(0xFF53BDEB) : Colors.white54),
            if (isMine) const SizedBox(width: 4),
            Expanded(
              child: Text(
                decryptedMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: (!isMine && !isRead) ? Colors.white : Colors.white54, fontWeight: (!isMine && !isRead) ? FontWeight.w600 : FontWeight.normal),
              ),
            ),
            Text(formattedTime, style: TextStyle(fontSize: 12, color: (!isMine && !isRead) ? const Color(0xFF00A884) : Colors.white54)),
            if (!isMine && !isRead)
              Container(
                margin: const EdgeInsets.only(left: 6),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: Color(0xFF00A884), shape: BoxShape.circle),
              )
          ],
        );
      },
    );
  }
}