import 'package:json_annotation/json_annotation.dart';

import './user_item_amount_model.dart';

part 'shared_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SharedItem {
  final UserItemAmount amount;
  final DateTime buyDate;
  final String itemRef;
  final String name;
  final String category;
  final String user;

  @JsonKey(includeToJson: false, defaultValue: {})
  Map<String, dynamic> location = {};

  @JsonKey(includeToJson: false, defaultValue: double.infinity)
  double distance = double.infinity;

  SharedItem(
      {required this.amount,
      required this.buyDate,
      required this.itemRef,
      required this.name,
      required this.category,
      required this.user});

  factory SharedItem.fromJson(Map<String, dynamic> json) =>
      _$SharedItemFromJson(json);

  Map<String, dynamic> toJson() => _$SharedItemToJson(this);
}
