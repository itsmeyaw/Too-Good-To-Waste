import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import './user_item_amount_model.dart';
import './user_item_expiry_model.dart';

part 'user_item_model.g.dart';

@immutable
@JsonSerializable()
class UserItem {
  final DateTime buyDate;
  final String name;
  final String category;
  final UserItemAmount amount;
  final UserItemExpiry expiry;

  const UserItem(
      {required this.name,
      required this.buyDate,
      required this.category,
      required this.amount,
      required this.expiry});

  factory UserItem.fromJson(Map<String, dynamic> json) => _$UserItemFromJson(json);

  Map<String, dynamic> toJson() => _$UserItemToJson(this);
}