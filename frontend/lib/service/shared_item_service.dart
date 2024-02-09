import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../dto/shared_item_model.dart';

class SharedItemService {
  static const String COLLECTION = "shared_items";

  final Logger logger = Logger();
  FirebaseFirestore db = FirebaseFirestore.instance;

  SharedItemService.withCustomFirestore({required this.db});

  Future<SharedItem?> getSharedItembyGEO(String sharedItemUid) async {
    try {
      await db
          .collection(COLLECTION)
          .doc(sharedItemUid)
          .get()
          .then((querySnapshot) {
        return SharedItem.fromJson(querySnapshot.data() as Map<String, dynamic>);
        });
    } catch (e) {
      logger.e('Got error when getting shared item $sharedItemUid with detail: $e');
      return null;
    }
    return null;
}


  Future<bool> updateSharedItem(
      String userUid, String sharedItemUid, SharedItem newItemData) async {
    logger.d(
        'Updating shared item $sharedItemUid for user $userUid with data ${newItemData.toJson()}');
    return await db
        .collection(COLLECTION)
        .doc(sharedItemUid)
        .set(newItemData.toJson())
        .then((_) {
      logger.d('Successfully updated item $sharedItemUid for user $userUid');
      return true;
    }).catchError((err) {
      logger.e('Got error when updating item $sharedItemUid for user $userUid with detail: $err');
      return false;
    });
  }

  Future<bool> deleteSharedItem(String userUid, String sharedItemUid) async {
    logger.d('Deleting item $sharedItemUid for user $userUid');
    return await db
        .collection(COLLECTION)
        .doc(sharedItemUid)
        .delete()
        .then((_) {
      logger.d('Successfully deleted shared item $sharedItemUid for user $userUid');
      return true;
    }).catchError((err) {
      logger.e('Got error when deleting shared item $sharedItemUid for user $userUid with detail: $err');
      return false;
    });
  }

  Future<SharedItem?> addSharedItem(String userUid, SharedItem newItemData) async {
    logger.d('Adding new shared item for user $userUid');
    return await db
        .collection(COLLECTION)
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