import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import './public_user_model.dart';
import './user_name_model.dart';

part 'user_rating.g.dart';

@JsonSerializable(explicitToJson: true)
class UserRating {
  final String ratingFrom;
  final double ratingValue;
  final String sharedItemId;

  const UserRating({required this.ratingFrom, required this.ratingValue, required this.sharedItemId});

  factory UserRating.fromJson(Map<String, dynamic> json) => _$UserRatingFromJson(json);

  Map<String, dynamic> toJson() => _$UserRatingToJson(this);
}
