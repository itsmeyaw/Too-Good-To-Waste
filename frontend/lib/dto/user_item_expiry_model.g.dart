// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_expiry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserItemExpiry _$UserItemExpiryFromJson(Map<String, dynamic> json) =>
    UserItemExpiry(
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      source: $enumDecode(_$UserItemExpirySourceEnumMap, json['source']),
    );

Map<String, dynamic> _$UserItemExpiryToJson(UserItemExpiry instance) =>
    <String, dynamic>{
      'expiry_date': instance.expiryDate.toIso8601String(),
      'source': _$UserItemExpirySourceEnumMap[instance.source]!,
    };

const _$UserItemExpirySourceEnumMap = {
  UserItemExpirySource.AI: 'AI',
  UserItemExpirySource.Manual: 'Manual',
};
