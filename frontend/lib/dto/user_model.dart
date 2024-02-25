import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import './public_user_model.dart';
import './user_name_model.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TGTWUser extends PublicUser {
  final UserAddress address;
  final String phoneNumber;
  final List<String> allergies;
  @JsonKey(defaultValue: [])
  final List<String> pickupProcesses;
  @JsonKey(defaultValue: [])
  final List<String> givingProcesses;
  final int goodPoints;
  final double reducedCarbonKg;

  TGTWUser({
    required super.name,
    required super.rating,
    required this.phoneNumber,
    required this.address,
    required this.allergies,
    required this.goodPoints,
    required this.reducedCarbonKg,
    this.pickupProcesses = const [],
    this.givingProcesses = const []
  });

  factory TGTWUser.fromJson(Map<String, dynamic> json) => _$TGTWUserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TGTWUserToJson(this);
}

@immutable
@JsonSerializable()
class UserAddress {
  final String city;
  final String country;
  final String line1;
  final String line2;
  final String zipCode;

  const UserAddress({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.zipCode,
  });

  factory UserAddress.fromJson(Map<String, Object?> json) =>
      _$UserAddressFromJson(json);

  Map<String, Object?> toJson() => _$UserAddressToJson(this);
}
