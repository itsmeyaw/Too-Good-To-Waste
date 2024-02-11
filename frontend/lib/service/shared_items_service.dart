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
    var location = geo.point(
        latitude: userLocation.latitude, longitude: userLocation.longitude);
    sharedItem.location = location.data;

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

  Iterable<SharedItem> _createSharedItemList(
      List<DocumentSnapshot<Object?>> docList) sync* {
    for (var obj in docList) {
      if (obj.exists) {
        yield SharedItem.fromJson(obj.data() as Map<String, dynamic>);
      }
    }
  }

  Stream<SharedItem> getSharedItemsWithinRadius(
      {required GeoPoint userLocation,
      required double radiusInKm,
      required String userId,
      String? category}) {
    logger.d('Start querying for shared item');

    var collection = db.collection(COLLECTION);
    if (category != null) {
      collection.where("category", isEqualTo: category);
    }

    return geo
        .collection(collectionRef: collection)
        .within(
            center: GeoFirePoint(userLocation.latitude, userLocation.longitude),
            radius: radiusInKm,
            field: "location",
            strictMode: true)
        .expand((docList) {
          logger.d('Got results: ${docList.length}');
          return _createSharedItemList(docList);
    });
  }
}
