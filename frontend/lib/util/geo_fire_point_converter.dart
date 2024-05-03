import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeoFirePointConverter
    extends JsonConverter<GeoFirePoint, Map<String, dynamic>> {
  const GeoFirePointConverter();

  @override
  GeoFirePoint fromJson(Map<String, dynamic> json) {
    return GeoFirePoint(
        json['geopoint']!.latitude, json['geopoint'].longitude as double);
  }

  @override
  Map<String, dynamic> toJson(object) {
    return object.data;
  }
}
