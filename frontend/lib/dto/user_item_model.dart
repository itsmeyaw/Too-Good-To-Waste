import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserItem {
  String name;
  String category;
  int boughtTime;
  int expireTime;
  String quantityType;
  double quantityNum;
  String state;
  double consumeState;

  UserItem(
      {
      required this.name,
      required this.category,
      required this.boughtTime,
      required this.expireTime,
      required this.quantityType,
      required this.quantityNum,
      required this.consumeState,
      required this.state});

  factory UserItem.fromJson(Map<String, dynamic> json) =>
      _$UserItemFromJson(json);

  Map<String, dynamic> toJson() => _$UserItemToJson(this);
}
