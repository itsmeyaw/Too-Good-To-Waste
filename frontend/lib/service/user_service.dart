
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

  Future<bool> updateUserData(String userUid, TGTWUser newUser) async{
    logger.d(
        'Updating user $userUid information with data ${newUser.toJson()}');
    return db
        .collection(COLLECTION)
        .doc(userUid)
        .set(newUser.toJson())
        .then((_) {
      logger.d('Successfully updated user $userUid information');
      return true;
    }).catchError((err) {
      logger.e('Got error when updating user $userUid with detail: $err');
      return false;
    });
  }
}
