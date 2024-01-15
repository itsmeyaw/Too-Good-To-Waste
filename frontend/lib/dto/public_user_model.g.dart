// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicUser _$PublicUserFromJson(Map<String, dynamic> json) => PublicUser(
      name: UserName.fromJson(json['name'] as Map<String, dynamic>),
      rating: (json['rating'] as num).toDouble(),
    );

Map<String, dynamic> _$PublicUserToJson(PublicUser instance) =>
    <String, dynamic>{
      'name': instance.name,
      'rating': instance.rating,
    };
