import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_item_amount_model.g.dart';

@immutable
@JsonSerializable()
class UserItemAmount {
  final double nominal;
  final String unit;

  const UserItemAmount({required this.nominal, required this.unit});

  factory UserItemAmount.fromJson(Map<String, dynamic> json) =>
   _$UserItemAmountFromJson(json);

  Map<String, dynamic> toJson() => _$UserItemAmountToJson(this);
}
