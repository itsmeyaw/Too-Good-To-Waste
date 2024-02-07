import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/cupertino.dart';
import 'package:tooGoodToWaste/dto/public_user_model.dart';

import './user_name_model.dart';
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
  final GeoPoint location;
  final String name;
  final String category;
  final PublicUser user;

  const SharedItem(
      {required this.amount,
      required this.buyDate,
      required this.expiryDate,
      required this.itemRef,
      required this.location,
      required this.name,
      required this.category,
      required this.user});

  factory SharedItem.fromJson(Map<String, dynamic> json) =>
      _$SharedItemFromJson(json);

  Map<String, dynamic> toJson() => _$SharedItemToJson(this);
}
