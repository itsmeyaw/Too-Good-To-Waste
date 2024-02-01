import 'package:dart_geohash/dart_geohash.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeoPointConverter extends JsonConverter<GeoPoint, String> {
  final GeoFlutterFire geo = GeoFlutterFire();

  GeoPointConverter();

  @override
  GeoPoint fromJson(String json) {
    final GeoHash myGeoHash = GeoHash(json);
    return GeoPoint(myGeoHash.latitude(), myGeoHash.longitude());
  }

  @override
  String toJson(GeoPoint obj) {
    return geo.point(latitude: obj.latitude, longitude: obj.longitude).hash;
  }
}
