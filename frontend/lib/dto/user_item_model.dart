import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

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

@immutable
@JsonSerializable()
class UserItemExpiry {
  final DateTime expiryDate;
  final UserItemExpirySource source;

  const UserItemExpiry({required this.expiryDate, required this.source});

  factory UserItemExpiry.fromJson(Map<String, dynamic> json) =>
      _$UserItemExpiryFromJson(json);

  Map<String, dynamic> toJson() => _$UserItemExpiryToJson(this);
}

enum UserItemExpirySource {
  AI,
  Manual;
}
