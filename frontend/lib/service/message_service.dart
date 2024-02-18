import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../dto/message_model.dart';

class MessageService {
  final String COLLECTION = "users";
  final String SUB_COLLECTION = "chats";
  final String MESSAGE_COLLECTION = "messages";

  Logger logger = Logger();
  FirebaseFirestore db = FirebaseFirestore.instance;
  late final User user;

  MessageService() {
    final User? userOrNull = FirebaseAuth.instance.currentUser;

    if (userOrNull == null) {
      throw Exception("Calling this object must be authenticated");
    }
    user = userOrNull;
  }

  MessageService.withCustomFirestore({required this.db}) {
    final User? userOrNull = FirebaseAuth.instance.currentUser;

    if (userOrNull == null) {
      throw Exception("Calling this object must be authenticated");
    }
    user = user;
    db = db;
  }

  Future<bool> getChatroomIdBasedOnPartner(String secondUserId) async {
    final DocumentSnapshot chatroomSnapshot = await db
        .collection(COLLECTION)
        .doc(user.uid)
        .collection(SUB_COLLECTION)
        .doc(secondUserId)
        .get();

    return chatroomSnapshot.exists;
  }

  Stream<List<String>> getMessageThreadStream() {
    return db
        .collection(COLLECTION)
        .doc(user.uid)
        .collection(SUB_COLLECTION)
        .snapshots()
        .map<List<String>>(
            (QuerySnapshot event) => event.docs.map((doc) => doc.id).toList());
  }

  Stream<List<Message>> getMessageStream(String secondUserId) {
    CollectionReference ref = db
        .collection(COLLECTION)
        .doc(user.uid)
        .collection(SUB_COLLECTION)
        .doc(secondUserId)
        .collection(MESSAGE_COLLECTION);

    return ref.snapshots().map<List<Message>>((QuerySnapshot event) {
      logger.d("Received event: ${event.size} events");
      return event.docs
          .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> sendMessage(
      String secondUserId, String message, String? sharedItemId) async {
    final DateTime time = DateTime.now();

    Message messageObj =
        Message(message: message, timestamp: time, sender: user.uid);

    if (sharedItemId != null) {
      messageObj = Message(
          message: message,
          timestamp: time,
          sender: user.uid,
          sharedItemId: sharedItemId);
    }

    // Add message to the chat of first user
    await db
        .collection(COLLECTION)
        .doc(user.uid)
        .collection(SUB_COLLECTION)
        .doc(secondUserId)
        .collection(MESSAGE_COLLECTION)
        .add(messageObj.toJson());

    // Add message to the chat of second user
    await db
        .collection(COLLECTION)
        .doc(secondUserId)
        .collection(SUB_COLLECTION)
        .doc(user.uid)
        .collection(MESSAGE_COLLECTION)
        .add(messageObj.toJson());
  }
}
