import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../dto/shared_item_model.dart';

class MessageService {
  final String COLLECTION = "chatrooms";

  Logger logger = Logger();
  FirebaseFirestore db = FirebaseFirestore.instance;
  final Uuid uuid = const Uuid();
  late final User user;

  MessageService() {
    final User? userOrNull = FirebaseAuth.instance.currentUser;

    if (userOrNull == null) {
      throw Exception("Calling this object must be authenticated");
    }
    user = user;
  }

  MessageService.withCustomFirestore({required this.db}) {
    final User? userOrNull = FirebaseAuth.instance.currentUser;

    if (userOrNull == null) {
      throw Exception("Calling this object must be authenticated");
    }
    user = user;
    db = db;
  }

  Future<String?> getChatroomIdBasedOnPartner(String stringId) async {
    return null;
  }

  Future<int> startChat(String secondUserId, SharedItem sharedItem, String firstMessage) async {
    throw UnimplementedError();
  }
}
