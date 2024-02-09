import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/cupertino.dart';
import 'package:tooGoodToWaste/dto/public_user_model.dart';

import './user_item_amount_model.dart';
import '../util/geo_point_converter.dart';

part 'shared_item_model.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class SharedItem {
  final UserItemAmount amount;
  final int buyDate;
  final int expiryDate;
  final String itemRef;
  @GeoPointConverter()
  final GeoPoint geoPoint;
  final String name;
  final String category;
  final PublicUser user;

  @JsonKey(includeToJson: false, defaultValue: {})
  Map<String, dynamic> location = {};

  @JsonKey(includeToJson: false, defaultValue: double.infinity)
  double distance = double.infinity;

  SharedItem(
      {required this.amount,
      required this.buyDate,
      required this.expiryDate,
      required this.itemRef,
      required this.geoPoint,
      required this.name,
      required this.category,
      required this.user});

  factory SharedItem.fromJson(Map<String, dynamic> json) =>
      _$SharedItemFromJson(json);

  Map<String, dynamic> toJson() => _$SharedItemToJson(this);
}