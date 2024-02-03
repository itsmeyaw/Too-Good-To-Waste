import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../dto/user_item_model.dart';
import '../dto/user_model.dart';

class UserService {
  static const String COLLECTION = "users";
  static const String ITEMS_SUB_COLLECTION = "items";

  final Logger logger = Logger();
  FirebaseFirestore db = FirebaseFirestore.instance;

  UserService();

  UserService.withCustomFirestore({required this.db});

  Future<TGTWUser> getUserData(String userUid) {
    return db
        .collection(COLLECTION)
        .doc(userUid)
        .get()
        .then((querySnapshot) {
      if (!querySnapshot.exists) {
        throw Exception('Cannot find user $userUid');
      }
      logger.d('Got data ${querySnapshot.data()}');
      return TGTWUser.fromJson(querySnapshot.data()!);
    });
  }

  Future<Iterable<UserItem>> getUserItems(String userUid) async {
    return await db
        .collection(COLLECTION)
        .doc(userUid)
        .collection(ITEMS_SUB_COLLECTION)
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
        .collection(ITEMS_SUB_COLLECTION)
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
        .collection(ITEMS_SUB_COLLECTION)
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

  Future<UserItem?> addUserItem(String userUid, UserItem newItemData) async {
    logger.d('Adding new item for user $userUid');
    return await db
        .collection(COLLECTION)
        .doc(userUid)
        .collection(ITEMS_SUB_COLLECTION)
        .add(newItemData.toJson())
        .then((docRef) {
      logger.d('Successfully added item ${docRef.id} for user $userUid');
      return newItemData;
    }).catchError((err) {
      logger
          .e('Got error when adding item for user $userUid with detail: $err');
      return null;
    });
  }
}
