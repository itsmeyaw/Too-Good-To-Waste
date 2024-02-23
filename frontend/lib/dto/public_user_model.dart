import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import './user_name_model.dart';

part 'public_user_model.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class PublicUser {
  final UserName name;
  @JsonKey(defaultValue: 0)
  final double rating;

  const PublicUser({required this.name, required this.rating});

  factory PublicUser.fromJson(Map<String, dynamic> json) =>
      _$PublicUserFromJson(json);

  Map<String, dynamic> toJson() => _$PublicUserToJson(this);
}
