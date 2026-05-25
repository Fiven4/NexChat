import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'encryption_service.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    _firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email,
    });

    return userCredential;
  }

  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final String encryptedMessage = EncryptionService.encryptMessage(message);

    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': encryptedMessage,
      'timestamp': timestamp,
      'isRead': false,
    };

    String chatRoomId = _getChatRoomId(currentUserId, receiverId);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    String chatRoomId = _getChatRoomId(userId, otherUserId);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getLastMessage(String userId, String otherUserId) {
    String chatRoomId = _getChatRoomId(userId, otherUserId);
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  Future<void> markMessageAsRead(String chatRoomId, String messageId) async {
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }
}