// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRating _$UserRatingFromJson(Map<String, dynamic> json) => UserRating(
      ratingFrom: json['rating_from'] as String,
      ratingValue: (json['rating_value'] as num).toDouble(),
    );

Map<String, dynamic> _$UserRatingToJson(UserRating instance) =>
    <String, dynamic>{
      'rating_from': instance.ratingFrom,
      'rating_value': instance.ratingValue,
    };
