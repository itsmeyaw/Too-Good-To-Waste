import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../dto/shared_item_model.dart';

class SharedItemService {
  static const String COLLECTION = "shared_items";
  static const String SUB_COLLECTION = "items";

  final Logger logger = Logger();
  FirebaseFirestore db = FirebaseFirestore.instance;

  SharedItemService.withCustomFirestore({required this.db});

  Future<Iterable<SharedItem?>> getSharedItem(String userUid) async {
    return await db
          .collection(COLLECTION)
          .doc(userUid)
          .collection(SUB_COLLECTION)
          .get()
          .then((querySnapshot) {
      logger.d('Got ${querySnapshot.size} shared items, converting to item');
        return querySnapshot.docs.map((doc) => SharedItem.fromJson(doc.data()));
      });
}


  Future<bool> updateSharedItem(
      String userUid, String itemUid, SharedItem newItemData) async {
    logger.d(
        'Updating shared item $itemUid for user $userUid with data ${newItemData.toJson()}');
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
      logger.e('Got error when updating item $itemUid for user $userUid with detail: $err');
      return false;
    });
  }

  Future<bool> deleteSharedItem(String userUid, String itemUid) async {
    logger.d('Deleting item $itemUid for user $userUid');
    return await db
        .collection(COLLECTION)
        .doc(userUid)
        .collection(SUB_COLLECTION)
        .doc(itemUid)
        .delete()
        .then((_) {
      logger.d('Successfully deleted shared item $itemUid for user $userUid');
      return true;
    }).catchError((err) {
      logger.e('Got error when deleting shared item $itemUid for user $userUid with detail: $err');
      return false;
    });
  }

  Future<SharedItem?> addSharedItem(String userUid, SharedItem newItemData) async {
    logger.d('Adding new shared item for user $userUid');
    return await db
        .collection(COLLECTION)
        // .doc(userUid)
        // .collection(SUB_COLLECTION)
        .add(newItemData.toJson())
        .then((docRef) {
      logger.d('Successfully added shared item ${docRef.id} for user $userUid');
      return newItemData;
    }).catchError((err) {
      logger.e('Got error when adding shared item for user $userUid with detail: $err');
      return newItemData;
    });
  }
}