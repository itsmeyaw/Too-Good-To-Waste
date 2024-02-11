// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserItem _$UserItemFromJson(Map<String, dynamic> json) => UserItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      boughtTime: json['buy_date'] as int,
      expireTime: json['expiry_date'] as int,
      quantityType: json['quantity_type'] as String,
      quantityNum: (json['quantity_num'] as num).toDouble(),
      consumeState: (json['consume_state'] as num).toDouble(),
      state: json['state'] as String,
    );

Map<String, dynamic> _$UserItemToJson(UserItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'buy_date': instance.boughtTime,
      'expiry_date': instance.expireTime,
      'quantity_type': instance.quantityType,
      'quantity_num': instance.quantityNum,
      'state': instance.state,
      'consume_state': instance.consumeState,
    };
