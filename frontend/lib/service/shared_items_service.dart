import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:logger/logger.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/shared_item_reservation_model.dart';
import 'package:tooGoodToWaste/dto/user_preference_model.dart';

class SharedItemService {
  static const String SHARED_ITEM_COLLECTION = "shared_items";
  final Logger logger = Logger();
  final GeoHasher geoHasher = GeoHasher();

  final GeoFlutterFire geo = GeoFlutterFire();
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  SharedItemService();

  SharedItemService.withCustomFirestore({required this.db});

  Future<bool> postSharedItem(
      GeoPoint userLocation, SharedItem sharedItem) async {
    analytics.logEvent(name: "Share Item");

    // TODO: Check whether an item with the same ref is already exists, if yes then false
    var collection = db.collection(SHARED_ITEM_COLLECTION);
    final GeoFirePoint location = geo.point(
        latitude: userLocation.latitude, longitude: userLocation.longitude);
    sharedItem.location = location;

    return geo
        .collection(collectionRef: collection)
        .add(sharedItem.toJson())
        .then((value) {
      logger.d("Successfully added shared item $value");
      return true;
    }).catchError((error) {
      logger.e("Got error when adding item $error");
      return false;
    });
  }

  SharedItem? createSharedItem(DocumentSnapshot<Object?> doc) {
    if (doc.exists) {
      logger.d(
          'Converting shared item ${doc.id} data: ${doc.data() as Map<String, dynamic>}');
      SharedItem sharedItem =
      SharedItem.fromJson(doc.data() as Map<String, dynamic>);
      sharedItem.id = doc.id;
      logger.d('Shared item is ${sharedItem.id}');
      return sharedItem;
    } else {
      return null;
    }
  }

  List<SharedItem?> createSharedItemList(
      List<DocumentSnapshot<Object?>> docList) {
    return docList.map((e) => createSharedItem(e)).toList();
  }

  Future<SharedItem?> getSharedItem(String sharedItemId) async {
    return db.collection(SHARED_ITEM_COLLECTION).doc(sharedItemId).get().then(
        (querySnapshot) => querySnapshot.exists
            ? SharedItem.fromJson(querySnapshot.data() as Map<String, dynamic>)
            : null);
  }

  Stream<SharedItem?> streamSharedItem(String sharedItemId) {
    return db
        .collection(SHARED_ITEM_COLLECTION)
        .doc(sharedItemId)
        .snapshots()
        .map((event) =>
            event.exists ? createSharedItem(event) : null);
  }

  Stream<List<DocumentSnapshot>> getSharedItemsWithinRadius({
    required GeoPoint userLocation,
    required double radiusInKm,
    required String userId,
    ItemCategory? category,
    FoodPreference? foodPreference,
  }) {
    logger.d('Start querying for shared item');
    analytics.logEvent(name: "Search Item");

    Query collection = db.collection(SHARED_ITEM_COLLECTION);

    if (category != null && foodPreference == null) {
      collection = collection.where("category", isEqualTo: category.name);
    } else if (foodPreference != null) {
      switch (foodPreference) {
        case FoodPreference.Vegetarian:
          collection = collection.where("category", whereIn: [
            ItemCategory.Egg,
            ItemCategory.Vegetable,
            ItemCategory.Fruit,
            ItemCategory.Diaries
          ].map((e) => e.name));
        case FoodPreference.Vegan:
          collection = collection.where("category", whereIn: [
            ItemCategory.Vegetable,
            ItemCategory.Fruit,
          ].map((e) => e.name));
      }
    }

    return geo.collection(collectionRef: collection).within(
        center: GeoFirePoint(userLocation.latitude, userLocation.longitude),
        radius: radiusInKm,
        field: "location",
        strictMode: true);

  }

  Future<Iterable<SharedItem>> getSharedItemOfUser(String userId) {
    return db
        .collection(SHARED_ITEM_COLLECTION)
        .where('user', isEqualTo: userId)
        .get()
        .then((querySnapshot) {
      logger.d("Got ${querySnapshot.size} shared items of user $userId");
      return querySnapshot.docs.map((doc) => SharedItem.fromJson(doc.data()));
    });
  }

  Future<Iterable<SharedItem>> getLikedSharedItemOfUser(
      {required String userId}) {
    logger.d('Start querying for shared item');
    analytics.logEvent(name: "Search Item");

    return db
        .collection(SHARED_ITEM_COLLECTION)
        .where('liked_by', arrayContains: userId)
        .get()
        .then((querySnapshot) {
      logger.d("Got ${querySnapshot.size} liked shared items of user $userId");
      return querySnapshot.docs.map((doc) => SharedItem.fromJson(doc.data()));
    });
  }

  Future<Iterable<SharedItem>> getSharedItemOfUserWithReservation(
      String userId) {
    return db
        .collection(SHARED_ITEM_COLLECTION)
        .where('user', isEqualTo: userId)
        .where('shared_item_reservation.reserver', isNotEqualTo: null)
        .get()
        .then((querySnapshot) {
      logger.d(
          "Got ${querySnapshot.size} shared items of user $userId with reservation");
      return querySnapshot.docs.map((doc) => SharedItem.fromJson(doc.data()));
    });
  }

  Future<void> deleteSharedItem(String sharedItemId) async {
    await db.collection(SHARED_ITEM_COLLECTION).doc(sharedItemId).delete();
  }

  Future<bool> setLikedBy(String sharedItemId, String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> sharedItemDoc =
        await db.collection(SHARED_ITEM_COLLECTION).doc(sharedItemId).get();

    if (!sharedItemDoc.exists) {
      throw Error();
    } else {
      final SharedItem sharedItem = SharedItem.fromJson(sharedItemDoc.data()!);

      bool isLiked = sharedItem.likedBy.contains(userId);

      List<String> likedBy = sharedItem.likedBy;
      if (isLiked) {
        likedBy.remove(userId);
        isLiked = false;
      } else {
        likedBy.add(userId);
        isLiked = true;
      }

      await db
          .collection(SHARED_ITEM_COLLECTION)
          .doc(sharedItemId)
          .update({'liked_by': likedBy});

      return isLiked;
    }
  }

  /// Return previous state of is_available
  Future<bool> setSharedItemIsAvailable(
      String sharedItemId, bool isAvailable) async {
    final bool oldIsAvailable = await db
        .collection(SHARED_ITEM_COLLECTION)
        .doc(sharedItemId)
        .get()
        .then((snapshot) async {
      if (!snapshot.exists) {
        throw Exception('Cannot find shared item id $sharedItemId');
      }

      SharedItem sharedItem =
          SharedItem.fromJson(snapshot.data() as Map<String, dynamic>);

      return sharedItem.isAvailable;
    });

    await db
        .collection(SHARED_ITEM_COLLECTION)
        .doc(sharedItemId)
        .update({'is_available': isAvailable});

    return oldIsAvailable;
  }

  Future<bool> reserveItem(String sharedItemId) async {
    final DocumentSnapshot<Map<String, dynamic>> sharedItemDoc =
        await db.collection(SHARED_ITEM_COLLECTION).doc(sharedItemId).get();

    if (!sharedItemDoc.exists) {
      throw Error();
    } else {
      final SharedItem sharedItem = SharedItem.fromJson(sharedItemDoc.data()!);

      if (!sharedItem.isAvailable) {
        logger.w("Shared item $sharedItemId is not available");
        return false;
      }

      if (sharedItem.sharedItemReservation != null) {
        logger.w("Shared item $sharedItemId has reservation");
        return false;
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;

      analytics.logEvent(name: "Reserve Shared Item");
      await db.collection(SHARED_ITEM_COLLECTION).doc(sharedItemId).update({
        "shared_item_reservation": SharedItemReservation(
                reserver: userId,
                reservationTime: DateTime.now().millisecondsSinceEpoch)
            .toJson()
      });
    }

    return true;
  }

  Future<bool> cancelReserveItem(String sharedItemId) async {
    final DocumentSnapshot<Map<String, dynamic>> sharedItemDoc =
        await db.collection(SHARED_ITEM_COLLECTION).doc(sharedItemId).get();

    if (!sharedItemDoc.exists) {
      throw Error();
    } else {
      final SharedItem sharedItem = SharedItem.fromJson(sharedItemDoc.data()!);

      if (sharedItem.sharedItemReservation == null) {
        logger.w("Shared item $sharedItemId is not reserved");
        return false;
      }

      analytics.logEvent(name: "Cancel Shared Item Reservation");
      await db
          .collection(SHARED_ITEM_COLLECTION)
          .doc(sharedItemId)
          .update({"shared_item_reservation": null});

      return true;
    }
  }

  Future<bool> confirmPickUp(String sharedItemId) async {
    final DocumentSnapshot<Map<String, dynamic>> sharedItemDoc =
        await db.collection(SHARED_ITEM_COLLECTION).doc(sharedItemId).get();

    if (!sharedItemDoc.exists) {
      throw Error();
    } else {
      final SharedItem sharedItem = SharedItem.fromJson(sharedItemDoc.data()!);

      if (sharedItem.sharedItemReservation == null) {
        logger.w("Shared item $sharedItemId is not reserved");
        return false;
      }

      analytics.logEvent(name: "Confirm Shared Item Pickup");
      await db
          .collection(SHARED_ITEM_COLLECTION)
          .doc(sharedItemId)
          .update({"is_available": false, "picked_up": true});

      return true;
    }
  }
}
