import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/util/geo_fire_point_converter.dart';

import './user_item_amount_model.dart';

part 'shared_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SharedItem {
  @JsonKey(includeToJson: false)
  String? id;
  final UserItemAmount amount;
  final int buyDate;
  final int expireDate;
  final String name;
  final String? imageUrl;
  final ItemCategory category;
  final String user;

  @JsonKey(defaultValue: true)
  bool isAvailable = true;

  @GeoFirePointConverter()
  GeoFirePoint location = GeoFirePoint(0.0, 0.0);

  @JsonKey(includeToJson: false, defaultValue: double.infinity)
  double distance = double.infinity;

  SharedItem(
      {this.id,
      required this.amount,
      required this.buyDate,
      required this.expireDate,
      required this.imageUrl,
      required this.name,
      required this.category,
      required this.user,
      required this.isAvailable});

  factory SharedItem.fromJson(Map<String, dynamic> json) =>
      _$SharedItemFromJson(json);

  Map<String, dynamic> toJson() => _$SharedItemToJson(this);
}
