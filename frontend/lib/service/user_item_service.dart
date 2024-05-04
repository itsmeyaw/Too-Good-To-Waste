import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

import '../dto/user_item_model.dart';

class UserItemService {
  static const String COLLECTION = "users";
  static const String SUB_COLLECTION = "items";

  final Logger logger = Logger();
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  UserItemService.withCustomFirestore({required this.db});

  UserItemService();

  Future<Iterable<UserItem>> getUserItems(String userUid) async {
    return await db
        .collection(COLLECTION)
        .doc(userUid)
        .collection(SUB_COLLECTION)
        .get()
        .then((querySnapshot) {
      logger.d('Got ${querySnapshot.size} items, converting to item');
      return querySnapshot.docs.map((doc) => UserItem.fromJson(doc.data()));
    });
  }

  Future<bool> updateUserItem(
      String userUid, String itemUid, UserItem newItemData) async {
    logger.d(
        'Updating item $itemUid for user $userUid with data ${newItemData.toJson()}');
    return await db
        .collection(COLLECTION)
        .doc(userUid)
        .collection(SUB_COLLECTION)
        .doc(itemUid)
        .set(newItemData.toJson())
        .then((_) {
      logger.d('Successfully updated item $itemUid for user $userUid');
      return true;
    }).catchError((err) {
      logger.e(
          'Got error when updating item $itemUid for user $userUid with detail: $err');
      return false;
    });
  }

  Future<bool> deleteUserItem(String userUid, String itemUid) async {
    logger.d('Deleting item $itemUid for user $userUid');
    return await db
        .collection(COLLECTION)
        .doc(userUid)
        .collection(SUB_COLLECTION)
        .doc(itemUid)
        .delete()
        .then((_) {
      logger.d('Successfully deleted item $itemUid for user $userUid');
      return true;
    }).catchError((err) {
      logger.e(
          'Got error when deleting item $itemUid for user $userUid with detail: $err');
      return false;
    });
  }

  Future<String?> addUserItem(String userUid, UserItem newItemData) async {
    logger.d('Adding new item for user $userUid');
    return await db
        .collection(COLLECTION)
        .doc(userUid)
        .collection(SUB_COLLECTION)
        .add(newItemData.toJson())
        .then((docRef) {
      logger.d('Successfully added item ${docRef.path}');
      analytics.logEvent(name: 'Add USer Item');
      return docRef.id;
    }).catchError((err) {
      logger
          .e('Got error when adding item for user $userUid with detail: $err');
      return null;
    });
  }
}
