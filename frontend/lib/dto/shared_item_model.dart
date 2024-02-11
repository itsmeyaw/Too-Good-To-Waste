import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tooGoodToWaste/util/geo_point_converter.dart';

import './user_item_amount_model.dart';

part 'shared_item_model.g.dart';

@JsonSerializable()
class SharedItem {
  final UserItemAmount amount;
  final int buyDate;
  final int expireDate;
  final String itemRef;
  final String name;
  final String category;
  final String user;

  @JsonKey(includeToJson: false)
  SharedItemLocation location = SharedItemLocation.defaultValue();

  @JsonKey(includeToJson: false, defaultValue: double.infinity)
  double distance = double.infinity;

  SharedItem(
      {required this.amount,
      required this.buyDate,
      required this.expireDate,
      required this.itemRef,
      required this.name,
      required this.category,
      required this.user});

  factory SharedItem.fromJson(Map<String, dynamic> json) =>
      _$SharedItemFromJson(json);

  Map<String, dynamic> toJson() => _$SharedItemToJson(this);
}

class SharedItemLocation {
  final String geohash;
  final GeoPoint geopoint;

  factory SharedItemLocation.defaultValue() =>
      SharedItemLocation(geohash: '', geopoint: const GeoPoint(0, 0));

  SharedItemLocation({required this.geohash, required this.geopoint});

  factory SharedItemLocation.fromJson(Map<String, dynamic> json) =>
      SharedItemLocation(
          geohash: json['geohash'] as String,
          geopoint: json['geopoint'] as GeoPoint);
}
