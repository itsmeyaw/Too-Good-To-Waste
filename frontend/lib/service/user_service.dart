import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/dto/user_preference_model.dart';
import 'package:tooGoodToWaste/dto/user_rating.dart';

import '../dto/user_item_model.dart';
import '../dto/user_model.dart';

class UserService {
  static const String COLLECTION = "users";
  static const String ITEMS_SUB_COLLECTION = "items";
  static const String RATING_SUB_COLLECTION = "ratings";

  final Logger logger = Logger();
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  UserService();

  UserService.withCustomFirestore({required this.db});

  Future<TGTWUser> getUserData(String userUid) {
    return db.collection(COLLECTION).doc(userUid).get().then((querySnapshot) {
      if (!querySnapshot.exists) {
        throw Exception('Cannot find user $userUid');
      }
      logger.d('Got data ${querySnapshot.data()}');
      return TGTWUser.fromJson(querySnapshot.data()!);
    });
  }

  Future<bool> updateUserData(String userUid, TGTWUser newUser) async {
    logger
        .d('Updating user $userUid information with data ${newUser.toJson()}');
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

  /// Rate a user with id @param userId and with the value of @param rating
  /// Rating is 0 - 5;
  Future<void> rateUser(
      String userId, double rating, String sharedItemId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in but want to rate user");
    }

    if (rating < 0 || rating > 5) {
      throw Exception("Value $rating is not between (incl.) 0 and 5");
    }

    logger.d('Start rating user $userId with value $rating');
    analytics.logEvent(name: 'Rate User');

    await db
        .collection(COLLECTION)
        .doc(userId)
        .collection(RATING_SUB_COLLECTION)
        .doc(sharedItemId)
        .set(UserRating(
                ratingFrom: user!.uid,
                ratingValue: rating,
                sharedItemId: sharedItemId)
            .toJson());

    logger.d('Updated the user rating in the collection');

    final double calculatedRating = await db
        .collection(COLLECTION)
        .doc(userId)
        .collection(RATING_SUB_COLLECTION)
        .get()
        .then((QuerySnapshot querySnapshot) {
      Iterable<UserRating> userRatings = querySnapshot.docs.map(
          (QueryDocumentSnapshot docSnapshot) =>
              UserRating.fromJson(docSnapshot.data() as Map<String, dynamic>));

      double total = userRatings.fold(
          0, (previousValue, element) => previousValue + element.ratingValue);
      return total / userRatings.length;
    });

    await db
        .collection(COLLECTION)
        .doc(userId)
        .update({'rating': calculatedRating});
  }

  Future<void> setUserFoodPreference(FoodPreference? foodPreference) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in but want to rate user");
    }

    analytics.logEvent(name: "Set Food Preference");

    TGTWUser tgtwUser = await getUserData(user.uid);
    Map<String, dynamic> modifiedUser = tgtwUser.toJson();
    (modifiedUser['user_preference']
            as Map<String, dynamic>)['food_preference'] =
        FoodPreferenceEnumMap[foodPreference];

    await db.collection(COLLECTION).doc(user.uid).update(modifiedUser);
  }

  Future<void> updateUserPoints(TGTWUser counterparty, double points, bool isBuy) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in but want to use points");
    }

    analytics.logEvent(name: "Points Transfer");

    double userPoints = await db.collection(COLLECTION).doc(user.uid).get().then((querySnapshot) {
      if (!querySnapshot.exists) {
        throw Exception('Cannot find user $user.uid');
      }
      logger.d('Got data ${querySnapshot.data()}');
      return querySnapshot.data()!['points'] as double;
    });

    
    if (isBuy) {
      if (userPoints < points) {
        throw Exception("User $user.uid does not have enough points to buy");
      }
      else {
        await db.collection(COLLECTION).doc(user.uid).update({
          'points': FieldValue.increment(-points),
        });
      
        // await db.collection(COLLECTION).doc(counterpartyUserId).update({
        //   'points': FieldValue.increment(points),
        // });
      }
    } else {
      if (counterparty.points < points) {
        throw Exception("User ${counterparty.name.first} ${counterparty.name.last} does not have enough points to give");
      }
      else {
        await db.collection(COLLECTION).doc(user.uid).update({
          'points': FieldValue.increment(points),
        });
        // await db.collection(COLLECTION).doc(counterpartyUserId).update({
        //   'points': FieldValue.increment(-points),
        // });
      }
    }
  }
}
