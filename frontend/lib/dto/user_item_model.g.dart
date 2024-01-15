// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserItem _$UserItemFromJson(Map<String, dynamic> json) => UserItem(
      name: json['name'] as String,
      buyDate: DateTime.parse(json['buy_date'] as String),
      category: json['category'] as String,
      amount: UserItemAmount.fromJson(json['amount'] as Map<String, dynamic>),
      expiry: UserItemExpiry.fromJson(json['expiry'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserItemToJson(UserItem instance) => <String, dynamic>{
      'buy_date': instance.buyDate.toIso8601String(),
      'name': instance.name,
      'category': instance.category,
      'amount': instance.amount,
      'expiry': instance.expiry,
    };
