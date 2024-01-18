import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'user_item_expiry_model.g.dart';

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
