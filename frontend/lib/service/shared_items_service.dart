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

  SharedItemService.withCustomFirestore({required this.db});

  Iterable<SharedItem> _convertDocRefToSharedItem(List<DocumentSnapshot<Object?>> geoRef) {
    final
  }

  Stream<List<SharedItem>> getSharedItemWithinRadius(
      GeoPoint userLocation, double radiusInKm, String category) {
    GeoFirePoint center = geo.point(
        latitude: userLocation.latitude, longitude: userLocation.longitude);

    var ref = db.collection(COLLECTION).where('category', isEqualTo: category);

    return geo
        .collection(collectionRef: ref)
        .withinAsSingleStreamSubscription(center: center, radius: radiusInKm, field: 'location')
        .expand((docRefList) {

    });
  }
}
