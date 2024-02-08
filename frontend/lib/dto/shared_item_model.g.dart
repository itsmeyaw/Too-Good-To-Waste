// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedItem _$SharedItemFromJson(Map<String, dynamic> json) => SharedItem(
      amount: UserItemAmount.fromJson(json['amount'] as Map<String, dynamic>),
      buyDate: json['buy_date'] as int,
      expiryDate: json['expiry_date'] as int,
      itemRef: json['item_ref'] as String,
      geoPoint: const GeoPointConverter()
          .fromJson(json['geo_point'] as Map<String, dynamic>),
      name: json['name'] as String,
      category: json['category'] as String,
      user: PublicUser.fromJson(json['user'] as Map<String, dynamic>),
    )
      ..location = json['location'] as Map<String, dynamic>? ?? {}
      ..distance = (json['distance'] as num?)?.toDouble() ?? double.infinity;

Map<String, dynamic> _$SharedItemToJson(SharedItem instance) =>
    <String, dynamic>{
      'amount': instance.amount.toJson(),
      'buy_date': instance.buyDate,
      'expiry_date': instance.expiryDate,
      'item_ref': instance.itemRef,
      'geo_point': const GeoPointConverter().toJson(instance.geoPoint),
      'name': instance.name,
      'category': instance.category,
      'user': instance.user.toJson(),
    };
