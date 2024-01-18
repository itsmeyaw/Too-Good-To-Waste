import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeoPointConverter extends JsonConverter<GeoPoint, Map<String, dynamic>> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Map<String, dynamic> json) {
    return GeoPoint(json['latitude']! as double, json['longitude']! as double);
  }

  @override
  Map<String, dynamic> toJson(obj) {
    return {'latitude': obj.latitude, 'longitude': obj.longitude};
  }
}
