import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:logger/logger.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';

class SharedItemService {
  static const String COLLECTION = "shared_items";
  final Logger logger = Logger();
  final GeoHasher geoHasher = GeoHasher();

  final GeoFlutterFire geo = GeoFlutterFire();
  FirebaseFirestore db = FirebaseFirestore.instance;

  SharedItemService();

  SharedItemService.withCustomFirestore({required this.db});

  Future<bool> postSharedItem(
      GeoPoint userLocation, SharedItem sharedItem) async {
    // TODO: Check whether an item with the same ref is already exists, if yes then false
    var collection = db.collection(COLLECTION);
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

  List<SharedItem?> createSharedItemList(
      List<DocumentSnapshot<Object?>> docList) {
    return docList.map((e) {
      if (e.exists) {
        logger.d(
            'Converting shared item data: ${e.data() as Map<String, dynamic>}');
        return SharedItem.fromJson(e.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    }).toList();
  }

  Stream<List<DocumentSnapshot>> getSharedItemsWithinRadius(
      {required GeoPoint userLocation,
      required double radiusInKm,
      required String userId,
      String? category}) {
    logger.d('Start querying for shared item');

    var collection = db.collection(COLLECTION);
    if (category != null) {
      collection.where("category", isEqualTo: category);
    }

    return geo.collection(collectionRef: collection).within(
        center: GeoFirePoint(userLocation.latitude, userLocation.longitude),
        radius: radiusInKm,
        field: "location",
        strictMode: true);
  }

  Future<Iterable<SharedItem>> getSharedItemOfUser(String userId) {
    return db
        .collection(COLLECTION)
        .where('user', isEqualTo: userId)
        .get()
        .then((querySnapshot) =>
            querySnapshot.docs.map((doc) => SharedItem.fromJson(doc.data())));
  }
}
