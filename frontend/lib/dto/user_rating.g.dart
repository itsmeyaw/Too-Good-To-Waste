// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRating _$UserRatingFromJson(Map<String, dynamic> json) => UserRating(
      ratingFrom: json['rating_from'] as String,
      ratingValue: (json['rating_value'] as num).toDouble(),
      sharedItemId: json['shared_item_id'] as String,
    );

Map<String, dynamic> _$UserRatingToJson(UserRating instance) =>
    <String, dynamic>{
      'rating_from': instance.ratingFrom,
      'rating_value': instance.ratingValue,
      'shared_item_id': instance.sharedItemId,
    };
