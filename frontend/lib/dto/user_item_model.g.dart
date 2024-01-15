// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserItem _$UserItemFromJson(Map<String, dynamic> json) => UserItem(
      name: json['name'] as String,
      buyDate: DateTime.parse(json['buyDate'] as String),
      category: json['category'] as String,
      amount: UserItemAmount.fromJson(json['amount'] as Map<String, dynamic>),
      expiry: UserItemExpiry.fromJson(json['expiry'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserItemToJson(UserItem instance) => <String, dynamic>{
      'buyDate': instance.buyDate.toIso8601String(),
      'name': instance.name,
      'category': instance.category,
      'amount': instance.amount,
      'expiry': instance.expiry,
    };

UserItemAmount _$UserItemAmountFromJson(Map<String, dynamic> json) =>
    UserItemAmount(
      nominal: (json['nominal'] as num).toDouble(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$UserItemAmountToJson(UserItemAmount instance) =>
    <String, dynamic>{
      'nominal': instance.nominal,
      'unit': instance.unit,
    };

UserItemExpiry _$UserItemExpiryFromJson(Map<String, dynamic> json) =>
    UserItemExpiry(
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      source: $enumDecode(_$UserItemExpirySourceEnumMap, json['source']),
    );

Map<String, dynamic> _$UserItemExpiryToJson(UserItemExpiry instance) =>
    <String, dynamic>{
      'expiryDate': instance.expiryDate.toIso8601String(),
      'source': _$UserItemExpirySourceEnumMap[instance.source]!,
    };

const _$UserItemExpirySourceEnumMap = {
  UserItemExpirySource.AI: 'AI',
  UserItemExpirySource.Manual: 'Manual',
};
