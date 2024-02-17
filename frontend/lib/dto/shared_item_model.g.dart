// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedItem _$SharedItemFromJson(Map<String, dynamic> json) => SharedItem(
      amount: UserItemAmount.fromJson(json['amount'] as Map<String, dynamic>),
      buyDate: json['buy_date'] as int,
      expireDate: json['expire_date'] as int,
      itemRef: json['item_ref'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      user: json['user'] as String,
    )
      ..location = const GeoFirePointConverter()
          .fromJson(json['location'] as Map<String, dynamic>)
      ..distance = (json['distance'] as num?)?.toDouble() ?? double.infinity;

Map<String, dynamic> _$SharedItemToJson(SharedItem instance) =>
    <String, dynamic>{
      'amount': instance.amount.toJson(),
      'buy_date': instance.buyDate,
      'expire_date': instance.expireDate,
      'item_ref': instance.itemRef,
      'name': instance.name,
      'category': instance.category,
      'user': instance.user,
      'location': const GeoFirePointConverter().toJson(instance.location),
    };
