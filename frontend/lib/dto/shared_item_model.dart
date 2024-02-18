import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/util/geo_fire_point_converter.dart';

import './user_item_amount_model.dart';

part 'shared_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SharedItem {
  String? id;
  final UserItemAmount amount;
  final int buyDate;
  final int expireDate;
  final String itemRef;
  final String name;
  final ItemCategory category;
  final String user;

  @GeoFirePointConverter()
  GeoFirePoint location = GeoFirePoint(0.0, 0.0);

  @JsonKey(includeToJson: false, defaultValue: double.infinity)
  double distance = double.infinity;

  SharedItem(
      {this.id,
      required this.amount,
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
