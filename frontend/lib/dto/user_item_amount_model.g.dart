// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_item_amount_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
