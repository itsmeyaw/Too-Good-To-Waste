// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserItem _$UserItemFromJson(Map<String, dynamic> json) => UserItem(
      name: json['name'] as String,
      category: json['category'] as String,
      boughttime: json['boughttime'] as int,
      expiretime: json['expiretime'] as int,
      quantitytype: json['quantitytype'] as String,
      quantitynum: (json['quantitynum'] as num).toDouble(),
      consumestate: (json['consumestate'] as num).toDouble(),
      state: json['state'] as String,
    );

Map<String, dynamic> _$UserItemToJson(UserItem instance) => <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'boughttime': instance.boughttime,
      'expiretime': instance.expiretime,
      'quantitytype': instance.quantitytype,
      'quantitynum': instance.quantitynum,
      'state': instance.state,
      'consumestate': instance.consumestate,
    };
